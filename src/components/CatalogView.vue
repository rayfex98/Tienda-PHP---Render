<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { store } from '../store.js';
import ProductCard from './ProductCard.vue';
import { 
  SlidersHorizontal, Plus, Search, RotateCcw, Laptop, 
  Watch, Smartphone, Headphones, Tv, AlertCircle 
} from 'lucide-vue-next';

const route = useRoute();
const router = useRouter();

// Retrieve reactive list of products from store
const products = computed(() => store.state.products);
const isAdminMode = computed(() => store.state.isAdminMode);
const searchQuery = computed(() => store.state.searchQuery);

// Filters and States
const selectedCategory = ref('todos');
const maxPrice = ref(2550);
const sortBy = ref('relevancia');
const showMobileFilters = ref(false);

const CATEGORIES = [
  { id: 'todos', name: 'Todos los productos', icon: 'All' },
  { id: 'laptops', name: 'Laptops y Computadores', icon: 'Laptop' },
  { id: 'smartphones', name: 'Smartphones de Alta Gama', icon: 'Smartphone' },
  { id: 'audio', name: 'Audio y Sonido Pro', icon: 'Headphones' },
  { id: 'wearables', name: 'Smartwatches & Moda', icon: 'Watch' },
  { id: 'televisiones', name: 'Televisión & Video', icon: 'Tv' },
];

const dynamicMaxBound = computed(() => {
  if (products.value.length === 0) return 2500;
  return Math.max(...products.value.map(p => p.price));
});

// Watch query parameters from vue-router for immediate filtering
watch(() => route.query.category, (newCategory) => {
  if (newCategory) {
    selectedCategory.value = newCategory;
  } else {
    selectedCategory.value = 'todos';
  }
}, { immediate: true });

// Align maximum price limit initially
onMounted(() => {
  maxPrice.value = dynamicMaxBound.value;
});

// Watch changes to adjust price bounds if needed
watch(dynamicMaxBound, (newMax) => {
  if (maxPrice.value > newMax || maxPrice.value === 2550 || maxPrice.value === 2500) {
    maxPrice.value = newMax;
  }
});

// Combined search, category, pricing, and sort computing
const filteredAndSortedProducts = computed(() => {
  let result = [...products.value];

  // 1. Search Query filter (from global search)
  if (searchQuery.value.trim()) {
    const queryStr = searchQuery.value.toLowerCase().trim();
    result = result.filter(p => {
      const specMatch = p.specs ? p.specs.some(s => s.toLowerCase().includes(queryStr)) : false;
      return p.name.toLowerCase().includes(queryStr) ||
             p.description.toLowerCase().includes(queryStr) ||
             p.category.toLowerCase().includes(queryStr) ||
             specMatch;
    });
  }

  // 2. Category selection
  if (selectedCategory.value !== 'todos') {
    result = result.filter(p => p.category === selectedCategory.value);
  }

  // 3. Price limit
  result = result.filter(p => p.price <= maxPrice.value);

  // 4. Sort selection
  switch (sortBy.value) {
    case 'precio-asc':
      result.sort((a, b) => a.price - b.price);
      break;
    case 'precio-desc':
      result.sort((a, b) => b.price - a.price);
      break;
    case 'calificacion':
      result.sort((a, b) => b.rating - a.rating);
      break;
    case 'relevancia':
    default:
      result.sort((a, b) => {
        if (a.featured && !b.featured) return -1;
        if (!a.featured && b.featured) return 1;
        return a.name.localeCompare(b.name);
      });
      break;
  }

  return result;
});

const handleResetFilters = () => {
  selectedCategory.value = 'todos';
  store.state.searchQuery = '';
  maxPrice.value = dynamicMaxBound.value;
  sortBy.value = 'relevancia';
  router.replace({ path: '/catalogo', query: {} });
};

const getCategoryIconComp = (iconName) => {
  switch (iconName) {
    case 'Laptop': return Laptop;
    case 'Smartphone': return Smartphone;
    case 'Headphones': return Headphones;
    case 'Watch': return Watch;
    case 'Tv': return Tv;
    default: return SlidersHorizontal;
  }
};

const formatPrice = (val) => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(val);
};

// Admin operations
const onAddProductClick = () => {
  store.state.productToEdit = null;
  store.state.isFormModalOpen = true;
};

const onEditProductClick = (product) => {
  store.state.productToEdit = { ...product };
  store.state.isFormModalOpen = true;
};

const onDeleteProduct = (productId) => {
  store.deleteProduct(productId);
};

const onAddToCart = (product) => {
  store.addToCart(product);
};

const handleCategoryPillClick = (catId) => {
  selectedCategory.value = catId;
  router.replace({ path: '/catalogo', query: { category: catId } });
};
</script>

<template>
  <div id="catalog-view-root" class="space-y-6 sm:space-y-8 animate-fade-in text-slate-800">
    
    <!-- Search and general status header -->
    <div id="catalog-header-panel" class="bg-white border border-slate-200 rounded-3xl p-5 sm:p-6 flex flex-col md:flex-row items-start md:items-center justify-between gap-4 shadow-sm animate-fade-in">
      <div class="space-y-1 text-left">
        <h1 class="text-xl sm:text-2xl font-bold text-slate-800 tracking-tight flex items-center gap-2">
          Catálogo de Tecnología
          <span v-if="isAdminMode" class="inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold bg-rose-100 text-rose-700 uppercase tracking-widest leading-none border border-rose-200">
            ADMIN INVENTARIO
          </span>
        </h1>
        <p class="text-xs sm:text-sm text-slate-500 font-normal">
          {{ searchQuery
            ? `Resultados para la búsqueda "${searchQuery}" (${filteredAndSortedProducts.length} encontrados)`
            : `Explorando ${selectedCategory === 'todos' ? 'todos los productos' : selectedCategory} (${filteredAndSortedProducts.length} productos)`
          }}
        </p>
      </div>

      <!-- Buttons/Actions -->
      <div id="catalog-header-actions" class="flex items-center gap-2 w-full md:w-auto shrink-0">
        <button
          @click="showMobileFilters = !showMobileFilters"
          class="flex-1 md:flex-none py-2.5 px-4 bg-slate-50 border border-slate-200 hover:bg-slate-100 text-slate-700 rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-1.5 transition lg:hidden cursor-pointer"
        >
          <SlidersHorizontal class="w-4 h-4" />
          <span>Filtros</span>
        </button>

        <button
          v-if="isAdminMode"
          id="catalog-add-product-btn"
          @click="onAddProductClick"
          class="flex-1 md:flex-none py-2.5 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-1.5 shadow-sm hover:shadow-md transition active:scale-95 cursor-pointer animate-scale-in"
        >
          <Plus class="w-4 h-4" />
          <span>Añadir Producto</span>
        </button>
      </div>
    </div>

    <!-- Main catalog body layout - Sidebar Left + Grid Right -->
    <div id="catalog-main" class="grid grid-cols-1 lg:grid-cols-4 gap-6 sm:gap-8 items-start">
      
      <!-- FILTERS PANEL: Desktop sidebar (visible) & Mobile collapsible -->
      <aside
        id="catalog-filters-sidebar"
        :class="['col-span-1 bg-white border border-slate-200 rounded-3xl p-5 sm:p-6 space-y-6 shadow-sm text-left',
          showMobileFilters ? 'block animate-slide-up' : 'hidden lg:block']"
      >
        <!-- Header specific for mobile -->
        <div class="flex items-center justify-between lg:hidden border-b border-slate-150 pb-3">
          <h3 class="text-sm font-bold text-slate-805 uppercase tracking-wider font-sans">Filtros Avanzados</h3>
          <button
            @click="showMobileFilters = false"
            class="p-1 px-2.5 bg-slate-50 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-slate-900 text-xs font-bold cursor-pointer"
          >
            Cerrar
          </button>
        </div>

        <!-- Categories select list -->
        <div class="space-y-3">
          <h3 class="text-xs font-bold text-slate-400 preset-sans uppercase tracking-widest font-sans">Categorías</h3>
          <div class="flex flex-col gap-1.5">
            <button
              v-for="cat in CATEGORIES"
              :key="`sidebar-cat-${cat.id}`"
              @click="handleCategoryPillClick(cat.id)"
              :class="['flex items-center justify-between px-3.5 py-2.5 rounded-xl text-left text-xs sm:text-sm font-semibold transition cursor-pointer',
                selectedCategory === cat.id
                  ? 'bg-blue-600 text-white shadow-xs'
                  : 'text-slate-600 hover:bg-blue-50/15 hover:text-blue-600']"
            >
              <div class="flex items-center gap-2">
                <component :is="getCategoryIconComp(cat.icon)" class="w-4 h-4 shrink-0" />
                <span>{{ cat.name }}</span>
              </div>
            </button>
          </div>
        </div>

        <!-- Price Range Filter Slider -->
        <div class="border-t border-slate-100 pt-5 space-y-3">
          <div class="flex items-center justify-between">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest font-sans">Precio Máximo</h3>
            <span class="text-xs font-black text-blue-600 bg-blue-50/55 px-2 py-0.5 rounded-md">
              {{ formatPrice(maxPrice) }}
            </span>
          </div>
          <input
            id="price-range-slider"
            type="range"
            min="100"
            :max="dynamicMaxBound || 2500"
            step="50"
            v-model.number="maxPrice"
            class="w-full justify-self-center accent-blue-600 cursor-pointer h-1.5 bg-slate-100 rounded-lg"
          />
          <div class="flex justify-between text-[10px] text-slate-400 font-bold font-sans">
            <span>$100.00</span>
            <span>{{ formatPrice(dynamicMaxBound) }}</span>
          </div>
        </div>

        <!-- Sort By selection -->
        <div class="border-t border-slate-100 pt-5 space-y-3">
          <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest font-sans">Ordenar por</h3>
          <select
            id="catalog-sort-select"
            v-model="sortBy"
            class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm font-bold text-slate-700 focus:outline-none focus:border-blue-500 bg-slate-50/50 cursor-pointer"
          >
            <option value="relevancia">Destacados & Alfabético</option>
            <option value="precio-asc">Precio: Menor a Mayor</option>
            <option value="precio-desc">Precio: Mayor a Menor</option>
            <option value="calificacion">Calificación y Estrellas</option>
          </select>
        </div>

        <!-- Reset Filters button -->
        <div class="border-t border-slate-100 pt-5">
          <button
            @click="handleResetFilters"
            class="w-full py-2.5 border border-blue-200 text-blue-700 hover:bg-blue-50 rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-1.5 transition active:scale-95 cursor-pointer"
          >
            <RotateCcw class="w-3.5 h-3.5" />
            <span>Limpiar Filtros</span>
          </button>
        </div>
      </aside>

      <!-- PRODUCTS GRID -->
      <div id="catalog-products-container" class="col-span-1 lg:col-span-3">
        <!-- Empty state block -->
        <div v-if="filteredAndSortedProducts.length === 0" id="no-results-panel" class="bg-white border border-slate-200 rounded-3xl p-12 text-center flex flex-col items-center justify-center space-y-4">
          <div class="w-14 h-14 bg-amber-50 text-amber-500 border border-amber-100 rounded-full flex items-center justify-center animate-pulse">
            <AlertCircle class="w-7 h-7" />
          </div>
          <div class="space-y-1 max-w-sm">
            <h4 class="text-base sm:text-lg font-bold text-slate-800">Ningún producto coincide con el filtro</h4>
            <p class="text-xs sm:text-sm text-slate-500 leading-relaxed font-normal">
              Sugerimos ajustar tu rango de precio máximo, vaciar el buscador o seleccionar otra de las categorías tecnológicas.
            </p>
          </div>
          <button
            @click="handleResetFilters"
            class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold shadow-sm transition active:scale-95 cursor-pointer animate-fade-in"
          >
            Limpiar Parámetros de Búsqueda
          </button>
        </div>

        <!-- Active products catalog list grid -->
        <div v-else id="catalog-grid" class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6 sm:gap-7">
          <ProductCard
            v-for="product in filteredAndSortedProducts"
            :key="product.id"
            :product="product"
            :isAdminMode="isAdminMode"
            @add-to-cart="onAddToCart"
            @edit="onEditProductClick"
            @delete="onDeleteProduct"
          />
        </div>
      </div>

    </div>

  </div>
</template>
