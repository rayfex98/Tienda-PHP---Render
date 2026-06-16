<script setup>
import { ref, computed, watch } from 'vue';
import { store } from '../store.js';
import { ArrowLeft, Star, ShoppingCart, ShieldCheck, HelpCircle, Truck, Calendar, AlertCircle } from 'lucide-vue-next';

const props = defineProps({
  id: { type: String, required: true }
});

// Retrieve product and reviews from store
const product = computed(() => {
  return store.state.products.find(p => p.id === props.id);
});

const productReviews = computed(() => {
  return store.state.reviews.filter(r => r.productId === props.id);
});

// Form states for creating custom review
const revName = ref('');
const revRating = ref(5);
const revComment = ref('');
const errors = ref({});
const submitAttempted = ref(false);

const liveRating = computed(() => {
  if (productReviews.value.length === 0) return product.value ? product.value.rating : 5.0;
  const sum = productReviews.value.reduce((acc, r) => acc + r.rating, 0);
  return parseFloat((sum / productReviews.value.length).toFixed(1));
});

// Find related items (same category, different id)
const relatedProducts = computed(() => {
  if (!product.value) return [];
  return store.state.products
    .filter(p => p.category === product.value.category && p.id !== product.value.id)
    .slice(0, 3);
});

const formatPrice = (val) => {
  return new Intl.NumberFormat('es-AR', {
    style: 'currency',
    currency: 'ARS'
  }).format(val);
};

const onAddToCart = (prod) => {
  store.addToCart(prod);
};

const validateReview = () => {
  const tempErrors = {};
  if (revName.value.trim().length < 3) {
    tempErrors.name = 'El nombre de usuario debe tener al menos 3 letras.';
  }
  if (revComment.value.trim().length < 10) {
    tempErrors.comment = 'La valoración debe ser de mínimo 10 caracteres explicativos.';
  }
  errors.value = tempErrors;
  return Object.keys(tempErrors).length === 0;
};

// Live review form validation once attempt is made
watch([revName, revComment], () => {
  if (submitAttempted.value) {
    validateReview();
  }
});

const handleReviewSubmit = (e) => {
  e.preventDefault();
  submitAttempted.value = true;

  if (validateReview()) {
    const payload = {
      productId: props.id,
      userName: revName.value.trim(),
      rating: revRating.value,
      comment: revComment.value.trim()
    };

    store.addReview(payload);

    // Reset Review Composer
    revName.value = '';
    revRating.value = 5;
    revComment.value = '';
    errors.value = {};
    submitAttempted.value = false;
  }
};
</script>

<template>
  <div v-if="!product" id="product-not-found" class="bg-white border border-slate-200 p-12 text-center rounded-3xl max-w-xl mx-auto space-y-4 my-8 animate-fade-in text-slate-800">
    <AlertCircle class="w-12 h-12 text-rose-500 mx-auto" />
    <h2 class="text-xl font-bold text-slate-800 font-sans">¡Producto No Encontrado!</h2>
    <p class="text-sm text-slate-500 font-normal">
      Lo sentimos, pero el código del producto solicitado no existe o fue removido del inventario por un encargado del sistema.
    </p>
    <router-link
      to="/catalogo"
      class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-sm transition shadow-xs cursor-pointer font-sans inline-block"
    >
      Regresar al Catálogo
    </router-link>
  </div>

  <div v-else id="product-details-container" class="space-y-12 sm:space-y-16 pb-16 animate-fade-in text-slate-800">
    
    <!-- 1. BACK CONTROLLER BAR -->
    <div id="details-top-bar" class="flex items-center">
      <router-link
        to="/catalogo"
        class="flex items-center gap-1.5 px-4 py-2 bg-white hover:bg-slate-50 text-xs sm:text-sm font-bold text-slate-700 rounded-xl border border-slate-200 shadow-2xs transition active:scale-95 cursor-pointer"
      >
        <ArrowLeft class="w-4 h-4" /> Regresar al Catálogo
      </router-link>
    </div>

    <!-- 2. PRODUCT DATA SHEET GRID -->
    <section id="product-data-sheet" class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start bg-white border border-slate-200 p-6 sm:p-8 rounded-3xl shadow-sm text-left">
      
      <!-- Left Side Image Gallery Cover -->
      <div class="col-span-1 lg:col-span-5 h-[320px] sm:h-[450px] bg-slate-50 rounded-2xl overflow-hidden border border-slate-200 shadow-inner">
        <img
          :src="product.image"
          :alt="product.name"
          class="w-full h-full object-cover transition-transform duration-500 hover:scale-105"
          referrerPolicy="no-referrer"
        />
      </div>

      <!-- Right Side Core Stats Sheet -->
      <div class="col-span-1 lg:col-span-7 space-y-6">
        <div class="space-y-2">
          <span class="inline-block px-3 py-1 bg-blue-50 border border-blue-100 text-[10px] tracking-widest font-bold text-blue-700 uppercase rounded-lg">
            {{ product.category }}
          </span>
          <h1 class="text-2xl sm:text-3xl font-bold text-slate-800 tracking-tight leading-tight">
            {{ product.name }}
          </h1>
          
          <!-- Live custom ratings board -->
          <div class="flex items-center gap-3">
            <div class="flex items-center gap-0.5">
              <Star
                v-for="s in 5"
                :key="`star-indicator-${s}`"
                :class="['w-4 h-4 shrink-0', s <= Math.round(liveRating) ? 'fill-amber-400 text-amber-400' : 'text-slate-200']"
              />
            </div>
            <span class="text-xs font-bold text-slate-750 font-mono bg-amber-50 border border-amber-200 px-2 py-0.5 rounded-md">
              {{ liveRating }} / 5.0
            </span>
            <span class="text-xs text-slate-400 font-medium">({{ productReviews.length }} reseñas registradas)</span>
          </div>
        </div>

        <!-- Pricing Block & Stock Banner -->
        <div class="border-y border-slate-150 py-4.5 flex flex-wrap items-center justify-between gap-4">
          <div class="space-y-0.5">
            <span class="text-xs font-bold text-slate-400 uppercase tracking-wide block font-sans">Precio al Contado</span>
            <span class="text-2xl sm:text-3xl font-black text-slate-900">{{ formatPrice(product.price) }}</span>
          </div>

          <div class="text-right">
            <span v-if="product.stock === 0" class="inline-flex px-3 py-1 bg-rose-50 border border-rose-100 text-rose-700 text-xs font-bold rounded-lg font-sans">
              Sin Existencias / Solicitud a Pedido
            </span>
            <div v-else class="space-y-0.5">
              <span class="inline-flex px-3 py-1 bg-emerald-50 border border-emerald-100 text-emerald-700 text-xs font-bold rounded-lg font-sans">
                ✓ Disponible ({{ product.stock }} unidades)
              </span>
              <p class="text-[10px] text-slate-400 tracking-wide font-normal">Despacho listo desde almacén central</p>
            </div>
          </div>
        </div>

        <!-- Description Excerpt -->
        <div class="space-y-2">
          <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest font-sans">Descripción del Producto</h3>
          <p class="text-slate-600 text-xs sm:text-sm leading-relaxed whitespace-pre-line font-normal text-justify">
            {{ product.description }}
          </p>
        </div>

        <!-- Action Add to Cart -->
        <div>
          <button
            @click="onAddToCart(product)"
            :disabled="product.stock === 0"
            :class="['w-full sm:w-auto px-8 py-3.5 rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-2 shadow-xs transition cursor-pointer',
              product.stock === 0
                ? 'bg-slate-100 border border-slate-200 text-slate-400 cursor-not-allowed'
                : 'bg-blue-600 hover:bg-blue-700 text-white transform active:scale-95 hover:shadow-md'
            ]"
          >
            <ShoppingCart class="w-4 h-4 sm:w-5 sm:h-5 text-current" /> Adicionar al Carrito
          </button>
        </div>

        <!-- Technical Specs list -->
        <div class="bg-slate-50 border border-slate-200 rounded-2xl p-5 space-y-3">
          <h3 class="text-xs font-bold text-slate-500 uppercase tracking-widest font-sans">Ficha Técnica Oficial</h3>
          <ul class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
            <li v-for="(spec, index) in product.specs" :key="`spec-${index}`" class="flex items-center gap-2 text-xs text-slate-600 truncate" :title="spec">
              <div class="h-1.5 w-1.5 rounded-full bg-blue-600 shrink-0" />
              <span class="font-normal text-slate-600">{{ spec }}</span>
            </li>
          </ul>
        </div>

      </div>
    </section>

    <!-- 3. REVIEWS MANAGEMENT (LIST & COMPOSER FORM) -->
    <section id="reviews-section" class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start text-left">
      
      <!-- Left side: List of reviews -->
      <div class="lg:col-span-7 bg-white border border-slate-200 p-6 rounded-3xl space-y-6 shadow-sm">
        <h2 class="text-lg font-bold text-slate-805 tracking-tight pb-3 border-b border-slate-100 font-sans">
          Opiniones de la Comunidad ({{ productReviews.length }})
        </h2>

        <div v-if="productReviews.length === 0" id="no-reviews" class="text-center py-10 space-y-2">
          <Star class="w-8 h-8 text-slate-200 mx-auto" />
          <p class="text-xs sm:text-sm font-bold text-slate-700 font-sans">Aún no hay valoraciones para este gadget</p>
          <p class="text-xs text-slate-405 font-normal">Sé el primero en compartir tu experiencia técnica con el producto.</p>
        </div>

        <div v-else class="divide-y divide-slate-100 max-h-96 overflow-y-auto pr-2 space-y-4">
          <div v-for="rev in productReviews" :key="rev.id" class="pt-4 first:pt-0 space-y-1.5 animate-fade-in">
            <div class="flex items-center justify-between">
              <h4 class="text-xs sm:text-sm font-bold text-slate-800">{{ rev.userName }}</h4>
              <span class="text-[10px] text-slate-400 font-medium font-sans shrink-0">{{ rev.date }}</span>
            </div>
            <div class="flex items-center gap-0.5">
              <Star
                v-for="s in 5"
                :key="`rev-star-${rev.id}-${s}`"
                :class="['w-3.5 h-3.5 shrink-0', s <= rev.rating ? 'fill-amber-400 text-amber-400' : 'text-slate-200']"
              />
            </div>
            <p class="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              {{ rev.comment }}
            </p>
          </div>
        </div>
      </div>

      <!-- Right column: Composer Form -->
      <div id="reviews-composer" class="lg:col-span-5 bg-white border border-slate-200 p-6 rounded-3xl shadow-sm space-y-4">
        <h2 class="text-lg font-bold text-slate-800 border-b border-slate-100 pb-3 font-sans">Escribir una Reseña</h2>
        
        <form @submit="handleReviewSubmit" class="space-y-4">
          <!-- Input Name -->
          <div>
            <label for="rev-user-name" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wide mb-1.5 font-sans">
              Tu Nombre Completo *
            </label>
            <input
              id="rev-user-name"
              type="text"
              placeholder="Ej. Sofía Garza"
              v-model="revName"
              :class="['w-full px-4 py-2.5 border text-xs sm:text-sm rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-100',
                errors.name ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500'
              ]"
            />
            <p v-if="errors.name" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
              <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.name }}
            </p>
          </div>

          <!-- Clickable Star Selecting mechanism -->
          <div>
            <span class="block text-[11px] font-bold text-slate-500 uppercase tracking-wide mb-1.5 font-sans">
              Calificación *
            </span>
            <div class="flex items-center gap-1.5 p-2 bg-slate-50 border border-slate-200 rounded-xl shadow-xs">
              <button
                v-for="starIndex in 5"
                :key="`star-click-${starIndex}`"
                type="button"
                @click="revRating = starIndex"
                class="p-0.5 hover:scale-110 active:scale-95 transition cursor-pointer"
                :title="`Votar ${starIndex} estrellas`"
              >
                <Star
                  :class="['w-6 h-6 stroke-[1.5]', starIndex <= revRating ? 'fill-amber-400 text-amber-400' : 'text-slate-350']"
                />
              </button>
            </div>
          </div>

          <!-- Comments Area -->
          <div>
            <label for="rev-comment-text" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wide mb-1.5 font-sans">
              Tu Comentario / Valoración Técnica *
            </label>
            <textarea
              id="rev-comment-text"
              rows="4"
              placeholder="Cuéntanos los pro y contras del producto, duración real de baterías, rendimiento..."
              v-model="revComment"
              :class="['w-full px-4 py-2.5 border text-xs sm:text-sm rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-100 resize-none',
                errors.comment ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500'
              ]"
            ></textarea>
            <p v-if="errors.comment" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans font-sans">
              <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.comment }}
            </p>
          </div>

          <button
            type="submit"
            class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs sm:text-sm rounded-xl shadow-xs transition active:scale-95 cursor-pointer font-sans"
          >
            Publicar Opinión
          </button>
        </form>
      </div>
    </section>

    <!-- 4. RECOMMENDATIONS / RELATED PRODUCTS ROW -->
    <section v-if="relatedProducts.length > 0" id="related-products" class="space-y-6 pt-6 border-t border-slate-200 text-left">
      <div>
        <h2 class="text-xl font-bold text-slate-805 tracking-tight font-sans">Otros Productos Recomendados</h2>
        <p class="text-xs sm:text-sm text-slate-500 font-normal">
          Alternativas interesantes dentro de la categoría "{{ product.category }}".
        </p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <router-link
          v-for="rel in relatedProducts"
          :key="`related-card-${rel.id}`"
          :to="`/producto/${rel.id}`"
          class="group cursor-pointer bg-white border border-slate-200 hover:border-blue-300 rounded-2xl overflow-hidden p-4 sm:p-5 flex flex-col justify-between shadow-2xs hover:shadow-xs transition text-left block"
        >
          <div class="aspect-video bg-slate-50 rounded-xl overflow-hidden mb-3 border border-slate-100">
            <img :src="rel.image" :alt="rel.name" class="w-full h-full object-cover transition group-hover:scale-105" />
          </div>
          <div>
            <h3 class="text-sm font-bold text-slate-800 truncate group-hover:text-blue-600 transition">
              {{ rel.name }}
            </h3>
            <p class="text-[10px] text-slate-405 capitalize font-bold tracking-wide mt-0.5 font-sans">{{ rel.category }}</p>
          </div>
          <div class="flex items-center justify-between mt-3 pt-2.5 border-t border-slate-100">
            <span class="text-sm font-bold text-slate-900">{{ formatPrice(rel.price) }}</span>
            <button
              @click.stop="onAddToCart(rel)"
              class="px-3.5 py-1.5 bg-blue-50 border border-blue-100 hover:bg-blue-600 hover:text-white rounded-lg text-[10px] font-bold text-blue-700 transition cursor-pointer"
            >
              Añadir
            </button>
          </div>
        </router-link>
      </div>
    </section>

  </div>
</template>
