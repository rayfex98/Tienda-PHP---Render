<script setup>
import { ref, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { ShoppingCart, Search, Menu, X, Settings, Laptop } from 'lucide-vue-next';
import { store } from '../store.js';

const router = useRouter();
const route = useRoute();
const isMobileMenuOpen = ref(false);

const cartCount = computed(() => {
  return store.state.cart.reduce((sum, item) => sum + item.quantity, 0);
});

const handleSearchSubmit = (e) => {
  e.preventDefault();
  if (route.path !== '/catalogo') {
    router.push('/catalogo');
  }
};

const toggleAdminMode = () => {
  store.state.isAdminMode = !store.state.isAdminMode;
};

const toggleCart = () => {
  store.state.isCartOpen = !store.state.isCartOpen;
};
</script>

<template>
  <header id="header-container" class="sticky top-0 z-40 w-full bg-white border-b border-slate-100 shadow-xs backdrop-blur-md/95">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16 md:h-20 gap-4">
        
        <!-- Logo -->
        <router-link 
          id="logo-brand" 
          to="/" 
          class="flex items-center cursor-pointer shrink-0 transition-transform active:scale-95 animate-fade-in"
        >
          <div class="p-2.5 bg-blue-600 rounded-xl text-white mr-2.5 shadow-sm shadow-blue-100">
            <Laptop class="w-5 h-5 sm:w-6 sm:h-6" />
          </div>
          <div class="flex flex-col text-left">
            <span class="text-lg sm:text-xl font-bold tracking-tight text-slate-800 leading-none">
              Electro<span class="text-blue-600 font-extrabold">Mart</span>
            </span>
            <span class="text-[10px] text-slate-405 font-bold tracking-widest mt-0.5 font-sans">MINIMAL TECH</span>
          </div>
        </router-link>

        <!-- Desktop Navigation -->
        <nav id="desktop-nav" class="hidden md:flex items-center space-x-1 lg:space-x-2">
          <router-link
            id="nav-btn-home"
            to="/"
            :class="[
              'px-4 py-2 rounded-xl text-sm font-semibold transition-all duration-205 cursor-pointer',
              route.path === '/'
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-650 hover:text-blue-600 hover:bg-slate-50'
            ]"
          >
            Inicio
          </router-link>
          <router-link
            id="nav-btn-catalogo"
            to="/catalogo"
            :class="[
              'px-4 py-2 rounded-xl text-sm font-semibold transition-all duration-205 cursor-pointer',
              route.path === '/catalogo' || route.path.startsWith('/producto/')
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-650 hover:text-blue-600 hover:bg-slate-50'
            ]"
          >
            Catálogo
          </router-link>
          <router-link
            id="nav-btn-sobre-nosotros"
            to="/nosotros"
            :class="[
              'px-4 py-2 rounded-xl text-sm font-semibold transition-all duration-205 cursor-pointer',
              route.path === '/nosotros'
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-650 hover:text-blue-600 hover:bg-slate-50'
            ]"
          >
            Sobre Nosotros
          </router-link>
        </nav>

        <!-- Search Bar - Desktop -->
        <form id="desktop-search-form" @submit="handleSearchSubmit" class="hidden lg:flex items-center relative max-w-xs w-full">
          <div class="relative w-full">
            <input
              id="header-search-input"
              type="text"
              placeholder="Buscar productos..."
              v-model="store.state.searchQuery"
              class="w-full pl-9 pr-4 py-2 rounded-xl text-sm border border-slate-200 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all bg-slate-50/50"
            />
            <Search class="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          </div>
        </form>

        <!-- Right Controls -->
        <div id="header-right-controls" class="flex items-center gap-2 sm:gap-3">
          <!-- Search Input for Mobile/Tablet -->
          <form @submit="handleSearchSubmit" class="flex lg:hidden items-center relative max-w-[140px] sm:max-w-[180px]">
            <div class="relative w-full">
              <input
                id="header-search-input-mobile"
                type="text"
                placeholder="Buscar..."
                v-model="store.state.searchQuery"
                class="w-full pl-8 pr-3 py-1.5 rounded-lg text-xs border border-slate-200 focus:outline-none bg-slate-50/50 focus:bg-white"
              />
              <Search class="w-3.5 h-3.5 text-slate-404 absolute left-2.5 top-2.5" />
            </div>
          </form>

          <!-- Admin Toggle Button -->
          <div class="flex items-center">
            <button
              id="admin-toggle-button"
              @click="toggleAdminMode"
              :class="[
                'flex items-center gap-1.5 px-3 py-1.5 sm:py-2.5 rounded-xl text-xs sm:text-sm font-semibold border transition-all duration-202 cursor-pointer',
                store.state.isAdminMode
                  ? 'bg-[#1D0D49]/10 border-[#1D0D49]/20 text-[#1D0D49] shadow-xs shadow-[#1D0D49]/10'
                  : 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100'
              ]"
              :title="store.state.isAdminMode ? 'Desactivar Modo Administrador' : 'Activar Modo Administrador'"
            >
              <Settings :class="['w-3.5 h-3.5', store.state.isAdminMode ? 'animate-spin text-[#1D0D49]' : 'text-slate-500']" />
              <span class="hidden sm:inline">Admin</span>
            </button>
          </div>

          <!-- Shopping Cart Trigger -->
          <button
            id="cart-trigger-button"
            @click="toggleCart"
            class="relative p-2.5 text-slate-700 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all cursor-pointer active:scale-90"
            aria-label="Ver carrito de compras"
          >
            <ShoppingCart class="w-5 h-5" />
            <span v-if="cartCount > 0" class="absolute -top-1 -right-1 bg-blue-600 text-white text-[11px] font-bold h-5 w-5 rounded-full flex items-center justify-center border-2 border-white shadow-xs">
              {{ cartCount }}
            </span>
          </button>

          <!-- Mobile Menu Icon -->
          <button
            id="mobile-menu-toggle"
            @click="isMobileMenuOpen = !isMobileMenuOpen"
            class="p-2.5 text-slate-650 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all md:hidden cursor-pointer"
            aria-label="Abrir menú"
          >
            <X v-if="isMobileMenuOpen" class="w-5 h-5" />
            <Menu v-else class="w-5 h-5" />
          </button>
        </div>

      </div>
    </div>

    <!-- Mobile Menu Overlay -->
    <div v-if="isMobileMenuOpen" id="mobile-menu" class="md:hidden border-t border-slate-100 bg-white shadow-xl animate-fade-in">
      <div class="px-4 pt-2.5 pb-5 space-y-2">
        <router-link
          id="mobile-nav-home"
          to="/"
          @click="isMobileMenuOpen = false"
          :class="[
            'block w-full text-left px-4 py-3 rounded-xl text-base font-semibold transition-all cursor-pointer',
            route.path === '/'
              ? 'bg-blue-50 text-blue-600'
              : 'text-slate-700 hover:bg-slate-50'
          ]"
        >
          Inicio
        </router-link>
        <router-link
          id="mobile-nav-catalogo"
          to="/catalogo"
          @click="isMobileMenuOpen = false"
          :class="[
            'block w-full text-left px-4 py-3 rounded-xl text-base font-semibold transition-all cursor-pointer',
            route.path === '/catalogo' || route.path.startsWith('/producto/')
              ? 'bg-blue-50 text-blue-600'
              : 'text-slate-700 hover:bg-slate-50'
          ]"
        >
          Catálogo de Productos
        </router-link>
        <router-link
          id="mobile-nav-sobre-nosotros"
          to="/nosotros"
          @click="isMobileMenuOpen = false"
          :class="[
            'block w-full text-left px-4 py-3 rounded-xl text-base font-semibold transition-all cursor-pointer',
            route.path === '/nosotros'
              ? 'bg-blue-50 text-blue-600'
              : 'text-slate-700 hover:bg-slate-50'
          ]"
        >
          Sobre Nosotros
        </router-link>
      </div>
    </div>
  </header>
</template>
