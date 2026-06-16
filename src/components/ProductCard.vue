<script setup>
import { computed } from 'vue';
import { Star, ShoppingCart, Eye, Edit, Trash2 } from 'lucide-vue-next';

const props = defineProps({
  product: { type: Object, required: true },
  isAdminMode: { type: Boolean, default: false }
});

const emit = defineEmits(['add-to-cart', 'edit', 'delete']);

const formattedPrice = computed(() => {
  return new Intl.NumberFormat('es-AR', {
    style: 'currency',
    currency: 'ARS'
  }).format(props.product.price);
});

const shortDescription = computed(() => {
  const desc = props.product.description || '';
  return desc.length > 75 ? `${desc.slice(0, 75)}...` : desc;
});

const handleEdit = (e) => {
  e.stopPropagation();
  emit('edit', props.product);
};

const handleDelete = (e) => {
  e.stopPropagation();
  if (confirm(`¿Está seguro de eliminar "${props.product.name}" de la tienda comercial?`)) {
    emit('delete', props.product.id);
  }
};

const handleAddToCart = (e) => {
  e.stopPropagation();
  emit('add-to-cart', props.product);
};
</script>

<template>
  <div
    :id="`product-card-${product.id}`"
    class="group flex flex-col justify-between bg-white rounded-2xl border border-slate-200 hover:border-slate-300 hover:shadow-lg transition-all duration-300 overflow-hidden h-full"
  >
    <!-- Product Image Panel -->
    <div class="relative aspect-4/3 bg-slate-50 overflow-hidden shrink-0">
      <img
        :src="product.image"
        :alt="product.name"
        class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        loading="lazy"
        referrerPolicy="no-referrer"
      />

      <!-- Category Tag -->
      <span class="absolute top-3 left-3 bg-white/95 backdrop-blur-xs text-[10px] tracking-wider uppercase font-extrabold px-2.5 py-1 rounded-lg text-slate-650 shadow-xs border border-slate-200">
        {{ product.category }}
      </span>

      <!-- Admin floating action bar -->
      <div v-if="isAdminMode" class="absolute top-3 right-3 flex gap-1.5 z-10">
        <button
          :id="`edit-btn-${product.id}`"
          @click="handleEdit"
          class="p-1.5 bg-white hover:bg-blue-50 border border-slate-200 text-blue-600 rounded-lg shadow-xs hover:text-blue-700 transition cursor-pointer"
          title="Editar producto"
        >
          <Edit class="w-3.5 h-3.5" />
        </button>
        <button
          :id="`delete-btn-${product.id}`"
          @click="handleDelete"
          class="p-1.5 bg-white hover:bg-[#1D0D49]/10 border border-slate-200 text-[#1D0D49] rounded-lg shadow-xs transition cursor-pointer"
          title="Eliminar producto"
        >
          <Trash2 class="w-3.5 h-3.5" />
        </button>
      </div>

      <!-- Quick View Cover Overlay -->
      <div class="absolute inset-0 bg-slate-900/10 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-all duration-300">
        <router-link
          :to="`/producto/${product.id}`"
          class="flex items-center gap-1.5 px-4 py-2 bg-white text-xs font-bold rounded-xl text-slate-800 shadow-sm border border-slate-200 transform translate-y-3 group-hover:translate-y-0 transition duration-300 hover:bg-slate-50 cursor-pointer"
        >
          <Eye class="w-3.5 h-3.5 text-blue-600" /> Ver detalles
        </router-link>
      </div>
    </div>

    <!-- Product Content Details -->
    <div class="p-4 sm:p-5 flex flex-col flex-1 text-left">
      <!-- Rating and Stock Header -->
      <div class="flex items-center justify-between gap-2 mb-2">
        <!-- Live Star Rating -->
        <div class="flex items-center gap-0.5">
          <template v-for="i in 5">
            <!-- Full Star -->
            <Star v-if="i <= Math.floor(product.rating)" :key="`full-${i}`" class="w-3.5 h-3.5 fill-amber-400 text-amber-400 shrink-0" />
            
            <!-- Half Star -->
            <div v-else-if="i === Math.ceil(product.rating) && product.rating % 1 >= 0.4" :key="`half-${i}`" class="relative inline-block shrink-0">
              <Star class="w-3.5 h-3.5 text-slate-200" />
              <div class="absolute top-0 left-0 overflow-hidden w-[50%]">
                <Star class="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
              </div>
            </div>

            <!-- Empty Star -->
            <Star v-else :key="`empty-${i}`" class="w-3.5 h-3.5 text-slate-200 shrink-0" />
          </template>
        </div>

        <!-- Stock condition badges -->
        <span v-if="product.stock === 0" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-100">
          Agotado
        </span>
        <span v-else-if="product.stock <= 5" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-100 animate-pulse">
          Últimas {{ product.stock }} un.
        </span>
        <span v-else class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100">
          En Stock ({{ product.stock }})
        </span>
      </div>

      <!-- Main Info -->
      <div class="mb-4 flex-1">
        <router-link
          :to="`/producto/${product.id}`"
          class="text-base sm:text-lg font-bold text-slate-800 hover:text-blue-600 transition cursor-pointer line-clamp-1 mb-1.5 block"
          :title="product.name"
        >
          {{ product.name }}
        </router-link>
        <p class="text-slate-500 text-xs sm:text-sm line-clamp-2 leading-relaxed font-normal">
          {{ shortDescription }}
        </p>
      </div>

      <!-- Price and Add button footer -->
      <div class="flex items-center justify-between gap-2 pt-3 border-t border-slate-100 shrink-0">
        <div class="flex flex-col">
          <span class="text-[10px] text-slate-400 font-bold uppercase tracking-wider">Precio</span>
          <span class="text-base sm:text-lg font-black text-slate-900">{{ formattedPrice }}</span>
        </div>

        <button
          :id="`add-to-cart-btn-${product.id}`"
          @click="handleAddToCart"
          :disabled="product.stock === 0"
          :class="['flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all cursor-pointer',
            product.stock === 0
              ? 'bg-slate-100 text-slate-400 cursor-not-allowed border border-slate-200'
              : 'bg-blue-600 hover:bg-blue-700 text-white shadow-sm hover:shadow-md transform active:scale-95']"
        >
          <ShoppingCart class="w-3.5 h-3.5 sm:w-4 sm:h-4" />
          <span>Añadir</span>
        </button>
      </div>
    </div>
  </div>
</template>
