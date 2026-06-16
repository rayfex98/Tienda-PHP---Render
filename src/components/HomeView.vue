<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { store } from '../store.js';
import { 
  Smartphone, Laptop, Headphones, Tv, Watch, ShieldCheck, 
  Truck, LifeBuoy, CreditCard, Star, ChevronLeft, ChevronRight, ArrowRight 
} from 'lucide-vue-next';

const router = useRouter();

const HERO_SLIDES = [
  {
    title: 'Estaciones de Trabajo de Siguiente Nivel',
    subtitle: 'Laptops y Tabletas Profesionales',
    tagline: 'Hasta 12 Meses Sin Intereses con bancos participantes',
    image: 'https://images.unsplash.com/photo-1547082299-de196ea013d6?w=1000&auto=format&fit=crop&q=80',
    color: 'from-slate-900 via-blue-950 to-slate-800',
    categoryTarget: 'laptops'
  },
  {
    title: 'El Audio Más Puro e Inmersivo',
    subtitle: 'Sony WH-1000XM5 & Altavoces Premium',
    tagline: 'Envío gratuito asegurado en compras mayores a $1,500 MXN',
    image: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=1000&auto=format&fit=crop&q=80',
    color: 'from-slate-900 via-slate-800 to-slate-950',
    categoryTarget: 'audio'
  },
  {
    title: 'Hogar Inteligente del Mañana',
    subtitle: 'Starter Kits Interactivos de Domótica',
    tagline: 'Instalación remota de asistencia guiada completamente gratis',
    image: 'https://images.unsplash.com/photo-1558002038-1055907df827?w=1000&auto=format&fit=crop&q=80',
    color: 'from-slate-900 via-blue-900 to-slate-900',
    categoryTarget: 'hogar-inteligente'
  }
];

const CATEGORIES = [
  { id: 'laptops', name: 'Laptops y Computadores', icon: 'Laptop' },
  { id: 'smartphones', name: 'Smartphones de Alta Gama', icon: 'Smartphone' },
  { id: 'audio', name: 'Audio y Sonido Pro', icon: 'Headphones' },
  { id: 'wearables', name: 'Smartwatches & Moda', icon: 'Watch' },
  { id: 'televisiones', name: 'Televisión & Video', icon: 'Tv' },
];

const currentSlide = ref(0);
let slideTimer = null;

// Filter featured products (from raw store data)
const featuredProducts = computed(() => {
  return store.state.products.filter(p => p.featured || p.rating >= 4.6);
});

const formatPrice = (val) => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(val);
};

const handleSlideClick = (categoryTarget) => {
  // Navigate to catalog
  store.state.searchQuery = '';
  router.push({ path: '/catalogo', query: { category: categoryTarget } });
};

const handleCategoryClick = (categoryId) => {
  router.push({ path: '/catalogo', query: { category: categoryId } });
};

const handleViewDetails = (productId) => {
  router.push(`/producto/${productId}`);
};

const onAddToCart = (product) => {
  store.addToCart(product);
};

const getCategoryIconComp = (iconName) => {
  switch (iconName) {
    case 'Laptop': return Laptop;
    case 'Smartphone': return Smartphone;
    case 'Headphones': return Headphones;
    case 'Watch': return Watch;
    case 'Tv': return Tv;
    default: return Laptop;
  }
};

const prevSlide = () => {
  currentSlide.value = (currentSlide.value - 1 + HERO_SLIDES.length) % HERO_SLIDES.length;
};

const nextSlide = () => {
  currentSlide.value = (currentSlide.value + 1) % HERO_SLIDES.length;
};

onMounted(() => {
  slideTimer = setInterval(() => {
    nextSlide();
  }, 5000);
});

onUnmounted(() => {
  if (slideTimer) clearInterval(slideTimer);
});
</script>

<template>
  <div id="home-view-container" class="space-y-12 sm:space-y-16 pb-16 animate-fade-in text-slate-800">
    
    <!-- 1. INTERACTIVE HERO CAROUSEL -->
    <section id="hero-carousel-section" class="relative h-[360px] sm:h-[460px] rounded-3xl overflow-hidden shadow-md group">
      <!-- Carousel slides -->
      <div
        v-for="(slide, index) in HERO_SLIDES"
        :key="`slide-${index}`"
        @click="handleSlideClick(slide.categoryTarget)"
        :class="['absolute inset-0 flex items-center transition-all duration-700 ease-in-out cursor-pointer',
          index === currentSlide ? 'opacity-100 z-10' : 'opacity-0 z-0 pointer-events-none']"
      >
        <!-- Background gradient cover -->
        <div :class="['absolute inset-0 bg-gradient-to-r opacity-90 z-10', slide.color]"></div>
        
        <!-- Background cover image -->
        <img
          :src="slide.image"
          :alt="slide.title"
          class="absolute inset-0 w-full h-full object-cover mix-blend-overlay scale-110"
          referrerPolicy="no-referrer"
        />

        <!-- Slide content container -->
        <div class="relative z-20 max-w-2xl px-6 sm:px-12 text-white space-y-3 sm:space-y-4 text-left">
          <span class="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] sm:text-xs font-bold bg-white/10 backdrop-blur-xs border border-white/20 text-white tracking-widest uppercase">
            PROMO ESPECIAL
          </span>
          <p class="text-sm font-bold tracking-widest text-slate-300 uppercase font-sans mb-1 block">
            {{ slide.subtitle }}
          </p>
          <h1 class="text-2xl sm:text-4xl md:text-5xl font-extrabold tracking-tight leading-tight">
            {{ slide.title }}
          </h1>
          <p class="text-xs sm:text-sm text-slate-100 font-medium">
            {{ slide.tagline }}
          </p>
          <div class="pt-2">
            <button
              @click.stop="handleSlideClick(slide.categoryTarget)"
              class="px-5 py-2.5 bg-white hover:bg-slate-50 text-blue-900 rounded-xl font-bold text-xs sm:text-sm flex items-center gap-1.5 shadow-sm transition group-hover:translate-x-1 cursor-pointer"
            >
              Ver Ofertas <ArrowRight class="w-4 h-4 text-blue-600 transition duration-250 group-hover:translate-x-1" />
            </button>
          </div>
        </div>
      </div>

      <!-- Carousel controls -->
      <button
        id="hero-carousel-prev"
        @click.stop="prevSlide"
        class="absolute left-4 top-1/2 -translate-y-1/2 p-2 rounded-full bg-white/20 hover:bg-white/40 text-white z-20 transition md:opacity-0 md:group-hover:opacity-100 cursor-pointer"
      >
        <ChevronLeft class="w-5 h-5" />
      </button>
      <button
        id="hero-carousel-next"
        @click.stop="nextSlide"
        class="absolute right-4 top-1/2 -translate-y-1/2 p-2 rounded-full bg-white/20 hover:bg-white/40 text-white z-20 transition md:opacity-0 md:group-hover:opacity-100 cursor-pointer"
      >
        <ChevronRight class="w-5 h-5" />
      </button>

      <!-- Indicator dots -->
      <div class="absolute bottom-5 left-1/2 -translate-x-1/2 flex space-x-2 z-20">
        <button
          v-for="(_, index) in HERO_SLIDES"
          :key="`dot-${index}`"
          @click.stop="currentSlide = index"
          :class="['h-2 rounded-full transition-all duration-300 cursor-pointer',
            index === currentSlide ? 'w-6 bg-white' : 'w-2 bg-white/40']"
        />
      </div>
    </section>

    <!-- 2. VALUE PROPOSITION ROW (Grid of features) -->
    <section id="trust-banners-section" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-left">
      <div class="bg-white p-4 sm:p-5 rounded-2xl border border-slate-200 flex items-start gap-4 shadow-sm">
        <div class="p-3 bg-emerald-50 text-emerald-600 rounded-xl shrink-0">
          <Truck class="w-5 h-5 sm:w-6 sm:h-6" />
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-800">Envío Exprés Gratis</h4>
          <p class="text-xs text-slate-500 mt-1 leading-normal font-normal">
            Sin costo en compras de tecnología superando los $1,500 MXN.
          </p>
        </div>
      </div>

      <div class="bg-white p-4 sm:p-5 rounded-2xl border border-slate-200 flex items-start gap-4 shadow-sm">
        <div class="p-3 bg-blue-50 text-blue-600 rounded-xl shrink-0">
          <ShieldCheck class="w-5 h-5 sm:w-6 sm:h-6" />
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-800 font-sans">Garantía Certificada</h4>
          <p class="text-xs text-slate-500 mt-1 leading-normal font-normal">
            Hasta 2 años de cobertura oficial directa con fabricantes.
          </p>
        </div>
      </div>

      <div class="bg-white p-4 sm:p-5 rounded-2xl border border-slate-200 flex items-start gap-4 shadow-sm">
        <div class="p-3 bg-rose-50 text-rose-600 rounded-xl shrink-0">
          <CreditCard class="w-5 h-5 sm:w-6 sm:h-6" />
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-800 font-sans">Financiamiento Fácil</h4>
          <p class="text-xs text-slate-500 mt-1 leading-normal font-normal">
            Paga a plazos cómodos con tarjetas de crédito de tu preferencia.
          </p>
        </div>
      </div>

      <div class="bg-white p-4 sm:p-5 rounded-2xl border border-slate-200 flex items-start gap-4 shadow-sm">
        <div class="p-3 bg-amber-50 text-amber-600 rounded-xl shrink-0">
          <LifeBuoy class="w-5 h-5 sm:w-6 sm:h-6" />
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-800">Soporte Tecnólogo</h4>
          <p class="text-xs text-slate-500 mt-1 leading-normal font-normal">
            Expertos certificados listos para guiar tu configuración.
          </p>
        </div>
      </div>
    </section>

    <!-- 3. BENTO PRODUCTS BY CATEGORY EXPLORATION -->
    <section id="explore-categories-section" class="space-y-6">
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-slate-200 pb-4">
        <div class="text-left animate-fade-in">
          <h2 class="text-xl sm:text-2xl font-bold text-slate-800 tracking-tight font-sans">Buscar por Categoría</h2>
          <p class="text-xs sm:text-sm text-slate-500 font-normal">
            Filtros inmediatos para ubicar los mejores componentes y accesorios oficiales.
          </p>
        </div>
        <button
          @click="handleCategoryClick('todos')"
          class="text-xs sm:text-sm font-bold text-blue-600 hover:text-blue-700 flex items-center gap-1 hover:underline shrink-0 cursor-pointer"
        >
          Ver catálogo completo <ArrowRight class="w-4 h-4" />
        </button>
      </div>

      <!-- Categories Grid -->
      <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
        <button
          v-for="category in CATEGORIES"
          :key="category.id"
          @click="handleCategoryClick(category.id)"
          class="group bg-white hover:bg-blue-50/20 border border-slate-200 hover:border-blue-300 p-5 rounded-2xl flex flex-col items-center justify-center text-center gap-2.5 transition duration-300 shadow-2xs hover:shadow-xs cursor-pointer"
        >
          <div class="p-3.5 bg-slate-50 group-hover:bg-blue-600 group-hover:text-white rounded-xl text-slate-500 transition duration-300">
            <component :is="getCategoryIconComp(category.icon)" class="w-6 h-6" />
          </div>
          <span class="text-xs sm:text-sm font-bold text-slate-850 leading-tight group-hover:text-blue-600">
            {{ category.name }}
          </span>
        </button>
      </div>
    </section>

    <!-- 4. FEATURED PRODUCTS (PRODUCT CARDS ROW) -->
    <section id="featured-products-section" class="space-y-6">
      <div class="border-b border-slate-200 pb-4 text-left">
        <h2 class="text-xl sm:text-2xl font-bold text-slate-800 tracking-tight font-sans">Destacados del Mes 🔥</h2>
        <p class="text-xs sm:text-sm text-slate-500 font-normal">
          Nuestros dispositivos electrónicos mejor calificados por nuestra comunidad cibernauta.
        </p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div
          v-for="product in featuredProducts.slice(0, 4)"
          :key="`featured-${product.id}`"
          :id="`featured-card-${product.id}`"
          @click="handleViewDetails(product.id)"
          class="group cursor-pointer bg-white border border-slate-200 hover:border-slate-300 hover:shadow-md rounded-2xl overflow-hidden transition duration-300 flex flex-col justify-between text-left"
        >
          <!-- Image -->
          <div class="relative aspect-4/3 bg-slate-50 overflow-hidden">
            <img
              :src="product.image"
              :alt="product.name"
              class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
              referrerPolicy="no-referrer"
            />
            <span class="absolute top-2.5 left-2.5 px-2.5 py-1 rounded-lg bg-blue-600 text-white text-[9px] font-bold tracking-widest uppercase shadow-xs">
              DESTACADO
            </span>
          </div>

          <!-- Content -->
          <div class="p-4 flex-grow flex flex-col justify-between">
            <div>
              <div class="flex items-center gap-1 text-amber-550 mb-1.5">
                <Star class="w-3.5 h-3.5 fill-amber-400 text-amber-400 shrink-0" />
                <span class="text-xs font-bold text-slate-700 font-sans">{{ product.rating }}</span>
              </div>
              <h3 class="text-sm font-bold text-slate-800 group-hover:text-blue-600 transition truncate">
                {{ product.name }}
              </h3>
              <p class="text-xs text-slate-400 leading-relaxed line-clamp-2 mt-1 font-normal">
                {{ product.description }}
              </p>
            </div>

            <div class="flex items-center justify-between mt-4 pt-3 border-t border-slate-100 shrink-0">
              <span class="text-sm font-black text-slate-900">{{ formatPrice(product.price) }}</span>
              <button
                @click.stop="onAddToCart(product)"
                class="px-3.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-xl text-xs font-bold flex items-center gap-1 transition active:scale-95 cursor-pointer"
              >
                Añadir
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 5. TESTIMONIAL CARDS -->
    <section id="testimonials-section" class="bg-slate-55 bg-slate-100/50 rounded-3xl p-6 sm:p-10 border border-slate-200">
      <div class="text-center max-w-xl mx-auto space-y-2 mb-8">
        <h2 class="text-xl sm:text-2xl font-bold text-slate-800 tracking-tight font-sans">¿Qué dicen nuestros clientes?</h2>
        <p class="text-xs sm:text-sm text-slate-500 font-normal">
          Cientos de entusiastas del hardware y profesionales de la programación confían en ElectroMart.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 text-left">
        <div class="bg-white p-6 rounded-2xl border border-slate-200 flex flex-col justify-between">
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed italic font-normal">
            "Compré mi laptop ZenBook Pro Duo aquí. El envío llegó al día siguiente en Querétaro y la validación de la garantía oficial fue facilísima. ¡Servicio impecable!"
          </p>
          <div class="flex items-center gap-2.5 mt-5">
            <div class="h-8 w-8 rounded-full bg-blue-50 font-bold text-blue-600 flex items-center justify-center text-xs">
              AH
            </div>
            <div>
              <h5 class="text-xs font-bold text-slate-900 font-sans">Alejandro Herrera</h5>
              <span class="text-[10px] text-slate-405 font-bold uppercase font-sans">Desarrollador Full Stack</span>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-2xl border border-slate-200 flex flex-col justify-between">
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed italic font-normal">
            "Buscaba asesoría para equipar mi sala con bocinas inteligentes. Me atendieron en el chat súper rápido y me armaron un kit excelente. El sonido Dolby Atmos es otra dimensión."
          </p>
          <div class="flex items-center gap-2.5 mt-5">
            <div class="h-8 w-8 rounded-full bg-blue-50 font-bold text-blue-600 flex items-center justify-center text-xs">
              MC
            </div>
            <div>
              <h5 class="text-xs font-bold text-slate-900 font-sans">Mariana Casillas</h5>
              <span class="text-[10px] text-slate-405 font-bold uppercase font-sans">Diseñadora UX/UI</span>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-2xl border border-slate-200 flex flex-col justify-between">
          <p class="text-xs sm:text-sm text-slate-600 leading-relaxed italic font-normal">
            "Fascinado. Los precios en audífonos de cancelación de ruido Sony están de locura y te dan facilidades de pago sin intereses que en grandes supermercados no ofrecen."
          </p>
          <div class="flex items-center gap-2.5 mt-5">
            <div class="h-8 w-8 rounded-full bg-emerald-50 font-bold text-emerald-600 flex items-center justify-center text-xs">
              RG
            </div>
            <div>
              <h5 class="text-xs font-bold text-slate-900 font-sans">Ramiro Gómez</h5>
              <span class="text-[10px] text-slate-405 font-bold uppercase font-sans">Ingeniero de Sonido</span>
            </div>
          </div>
        </div>
      </div>
    </section>

  </div>
</template>
