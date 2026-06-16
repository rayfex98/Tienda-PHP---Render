<script setup>
import { computed } from 'vue';
import { store } from './store.js';
import Header from './components/Header.vue';
import Footer from './components/Footer.vue';
import CartModal from './components/CartModal.vue';
import ProductFormModal from './components/ProductFormModal.vue';
import { AlertCircle, Bell, Sparkles } from 'lucide-vue-next';

const isCartOpen = computed(() => store.state.isCartOpen);
const isFormModalOpen = computed(() => store.state.isFormModalOpen);
const productToEdit = computed(() => store.state.productToEdit);
const toast = computed(() => store.state.toast);

const cartCount = computed(() => {
  return store.state.cart.reduce((sum, item) => sum + item.quantity, 0);
});

const handleSaveProduct = (updatedProduct) => {
  const isEdit = store.state.products.some(p => p.id === updatedProduct.id);
  if (isEdit) {
    store.updateProduct(updatedProduct);
  } else {
    store.addProduct(updatedProduct);
  }
  // Close modal
  store.state.isFormModalOpen = false;
  store.state.productToEdit = null;
};

const handleCloseFormModal = () => {
  store.state.isFormModalOpen = false;
  store.state.productToEdit = null;
};
</script>

<template>
  <div id="app-root-container" class="min-h-screen bg-slate-50 flex flex-col justify-between font-sans antialiased text-slate-800">
    
    <!-- HEADER COMPONENT (PROPS & ACTIONS) -->
    <Header
      :cartCount="cartCount"
      @cartToggle="store.state.isCartOpen = true"
    />

    <!-- CORE CHANNELS WINDOW -->
    <main id="app-main-content-window" class="max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-grow">
      <!-- Vue Router Dynamic Stage transitions -->
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- FOOTER COMPONENT -->
    <Footer />

    <!-- SHOPPING DRAWER OVERLAY -->
    <CartModal />

    <!-- PRODUCT FORM INVENTORY CONTROLS MODAL -->
    <ProductFormModal
      :isOpen="isFormModalOpen"
      :productToEdit="productToEdit"
      @close="handleCloseFormModal"
      @save="handleSaveProduct"
    />

    <!-- POPUP FLOAT TOAST ALERTS SYSTEM -->
    <div v-if="toast" id="system-floating-toast" class="transition-all">
      <div
        :class="['fixed bottom-6 right-6 z-50 flex items-center gap-2.5 px-5 py-3.5 rounded-2xl shadow-xl border text-xs sm:text-sm font-bold text-slate-900 bg-white/95 backdrop-blur-xs animate-slide-up',
          toast.type === 'warn'
            ? 'border-amber-200 text-amber-900 shadow-amber-50/40'
            : toast.type === 'info'
            ? 'border-indigo-200 text-indigo-900 shadow-indigo-50/40'
            : 'border-emerald-200 text-emerald-900 shadow-emerald-50/40'
        ]"
      >
        <div
          :class="['p-1.5 rounded-lg shrink-0',
            toast.type === 'warn'
              ? 'bg-amber-55 bg-amber-50 text-amber-600'
              : toast.type === 'info'
              ? 'bg-indigo-55 bg-indigo-55 bg-indigo-50 text-indigo-650'
              : 'bg-emerald-55 bg-emerald-50 text-emerald-600'
          ]"
        >
          <!-- Dynamic Icons -->
          <AlertCircle v-if="toast.type === 'warn'" class="w-4 h-4" />
          <Bell v-else-if="toast.type === 'info'" class="w-4 h-4 animate-swing" />
          <Sparkles v-else class="w-4 h-4" />
        </div>
        <span>{{ toast.message }}</span>
      </div>
    </div>
  </div>
</template>

<style>
/* Smooth View Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease-in-out;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
