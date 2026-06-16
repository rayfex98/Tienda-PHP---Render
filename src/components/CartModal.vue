<script setup>
import { ref, computed } from 'vue';
import { store } from '../store.js';
import { ShoppingCart, X, Check, MapPin, AlertCircle, CreditCard, Minus, Plus, Trash2, Sparkles } from 'lucide-vue-next';

function formatPrice(val) {
  return new Intl.NumberFormat('es-AR', {
    style: 'currency',
    currency: 'ARS'
  }).format(val);
}

const isOpen = computed(() => store.state.isCartOpen);
const cartItems = computed(() => store.state.cart);

const isCheckoutStep = ref(false);
const purchaseSuccess = ref(false);
const generatedOrderNumber = ref('');

// Checkout Billing info
const fullName = ref('');
const email = ref('');
const address = ref('');
const cardNumber = ref('');
const expiry = ref('');
const cvv = ref('');
const errors = ref({});

// Calculations
const subtotal = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + (item.product.price * item.quantity), 0);
});

const shippingFee = computed(() => {
  if (subtotal.value >= 1500 || subtotal.value === 0) return 0;
  return 99; // Standard rate
});

const total = computed(() => {
  return subtotal.value + shippingFee.value;
});

// Event handlers
const onClose = () => {
  store.state.isCartOpen = false;
  // Reset states safely on drawer close unless they are checking out
  if (purchaseSuccess.value) {
    purchaseSuccess.value = false;
    isCheckoutStep.value = false;
    generatedOrderNumber.value = '';
    fullName.value = '';
    email.value = '';
    address.value = '';
    cardNumber.value = '';
    expiry.value = '';
    cvv.value = '';
  }
};

const onUpdateQuantity = (productId, quantity) => {
  store.updateCartQuantity(productId, quantity);
};

const onRemoveItem = (productId) => {
  store.removeFromCart(productId);
};

const handleCardNumberChange = (e) => {
  let val = e.target.value.replace(/\D/g, '');
  if (val.length > 16) val = val.slice(0, 16);
  // format 4-4-4-4
  const matches = val.match(/\d{4,16}/g);
  const match = (matches && matches[0]) || '';
  const parts = [];
  for (let i = 0, len = match.length; i < len; i += 4) {
    parts.push(match.substring(i, i + 4));
  }
  if (parts.length > 0) {
    cardNumber.value = parts.join(' ');
  } else {
    cardNumber.value = val;
  }
};

const handleExpiryChange = (e) => {
  let val = e.target.value.replace(/\D/g, '');
  if (val.length > 4) val = val.slice(0, 4);
  if (val.length >= 2) {
    expiry.value = val.slice(0, 2) + '/' + val.slice(2);
  } else {
    expiry.value = val;
  }
};

const handleCheckoutSubmit = (e) => {
  e.preventDefault();
  const nextErrors = {};

  if (!fullName.value.trim()) {
    nextErrors.fullName = 'El nombre completo es requerido';
  } else if (fullName.value.split(' ').filter(Boolean).length < 2) {
    nextErrors.fullName = 'Ingrese nombre y apellido';
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!email.value.trim()) {
    nextErrors.email = 'El correo electrónico es requerido';
  } else if (!emailRegex.test(email.value)) {
    nextErrors.email = 'Ingrese un correo electrónico válido';
  }

  if (!address.value.trim()) {
    nextErrors.address = 'La dirección de envío es requerida';
  } else if (address.value.length < 10) {
    nextErrors.address = 'Ingrese una dirección más detallada';
  }

  const cleanCard = cardNumber.value.replace(/\s/g, '');
  if (!cleanCard) {
    nextErrors.cardNumber = 'El número de tarjeta es obligatorio';
  } else if (cleanCard.length < 16) {
    nextErrors.cardNumber = 'Debe contener exactamente 16 dígitos';
  }

  if (!expiry.value.trim()) {
    nextErrors.expiry = 'Fecha requerida';
  } else if (!/^\d{2}\/\d{2}$/.test(expiry.value)) {
    nextErrors.expiry = 'Formato MM/AA';
  }

  if (!cvv.value.trim()) {
    nextErrors.cvv = 'CVV requerido';
  } else if (cvv.value.length < 3) {
    nextErrors.cvv = '3 o 4 dígitos';
  }

  errors.value = nextErrors;

  if (Object.keys(nextErrors).length === 0) {
    // Simulated successful payout
    generatedOrderNumber.value = 'EM-' + Math.floor(100000 + Math.random() * 900000);
    
    // Decrement stocks in store for purchased items
    cartItems.value.forEach(item => {
      const dbProd = store.state.products.find(p => p.id === item.product.id);
      if (dbProd) {
        dbProd.stock = Math.max(0, dbProd.stock - item.quantity);
      }
    });

    purchaseSuccess.value = true;
    store.clearCart();
  }
};
</script>

<template>
  <div v-if="isOpen" id="cart-drawer-overlay" class="fixed inset-0 z-50 flex justify-end bg-black/50 transition-opacity animate-fade-in" @click.self="onClose">
    <div
      id="cart-drawer-panel"
      class="relative bg-white w-full max-w-lg h-full flex flex-col shadow-2xl justify-between animate-slide-left"
    >
      <!-- Drawer Header -->
      <div class="flex items-center justify-between p-5 border-b border-slate-200 shrink-0">
        <div class="flex items-center gap-2">
          <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
            <ShoppingCart class="w-5 h-5" />
          </div>
          <h2 class="text-lg font-bold text-slate-800">
            {{ purchaseSuccess ? '¡Compra Completada!' : isCheckoutStep ? 'Información de Pago' : 'Tu Carrito' }}
          </h2>
        </div>
        <button
          id="close-cart-drawer"
          @click="onClose"
          class="p-1 px-2.5 bg-slate-50 text-slate-400 hover:text-slate-950 rounded-lg hover:bg-slate-100 transition duration-150 cursor-pointer"
        >
          <X class="w-5 h-5" />
        </button>
      </div>

      <!-- Drawer Content -->
      <div class="flex-1 overflow-hidden flex flex-col">
        <!-- SUCCESS VIEW -->
        <div v-if="purchaseSuccess" id="purchase-success-splash" class="flex-1 overflow-y-auto p-6 flex flex-col items-center justify-center text-center space-y-6">
          <div class="w-16 h-16 bg-emerald-50 text-emerald-600 rounded-full flex items-center justify-center border border-emerald-100 shadow-xs animate-scale-in">
            <Check class="w-8 h-8 stroke-[3]" />
          </div>
          <div class="max-w-sm space-y-2">
            <h3 class="text-xl font-bold text-slate-800">¡Muchas Gracias por tu Compra, {{ fullName.split(' ')[0] }}!</h3>
            <p class="text-sm text-slate-500 leading-relaxed font-normal">
              Su pago ha sido procesado exitosamente. Se ha enviado un correo con la factura detallada a <strong>{{ email }}</strong>.
            </p>
          </div>

          <div class="w-full bg-slate-50 border border-slate-200 rounded-2xl p-4 text-left divide-y divide-slate-200">
            <div class="pb-3 flex justify-between text-xs">
              <span class="text-slate-400 font-bold uppercase">Número de Pedido</span>
              <span class="font-mono font-bold text-slate-800 tracking-wider text-sm">{{ generatedOrderNumber }}</span>
            </div>
            <div class="py-3 flex justify-between text-xs">
              <span class="text-slate-400 font-bold uppercase">Envío Destinado a</span>
              <span class="font-semibold text-slate-800 truncate max-w-[200px]">{{ address }}</span>
            </div>
            <div class="pt-3 flex justify-between text-xs">
              <span class="text-slate-400 font-bold uppercase">Estimado de Entrega</span>
              <span class="font-semibold text-blue-700 font-sans">2 a 4 Días Hábiles</span>
            </div>
          </div>

          <div class="flex items-center justify-center pt-2">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 bg-blue-50 border border-blue-100 rounded-full text-xs font-semibold text-blue-700">
              <Sparkles class="w-3.5 h-3.5" /> Despachado por ElectroMart Express
            </span>
          </div>

          <button
            id="success-shop-more-btn"
            @click="onClose"
            class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-sm transition cursor-pointer"
          >
            Seguir Comprando
          </button>
        </div>

        <!-- CHECKOUT VIEW -->
        <template v-else-if="isCheckoutStep">
          <form @submit="handleCheckoutSubmit" class="flex-1 overflow-y-auto">
            <div class="p-6 space-y-6">
              
              <!-- Order total banner -->
              <div class="bg-blue-50/60 rounded-2xl p-4 border border-blue-100 flex items-center justify-between">
                <div>
                  <span class="text-xs text-blue-600 font-bold uppercase tracking-wider block font-sans">Total a Pagar</span>
                  <span class="text-xs text-slate-400 font-normal">Incluye envío sugerido</span>
                </div>
                <span class="text-xl font-bold text-slate-800">{{ formatPrice(total) }}</span>
              </div>

              <!-- Form inputs -->
              <div class="space-y-4 text-left">
                <h3 class="text-sm font-bold text-slate-800 border-b border-slate-100 pb-2 flex items-center gap-1.5">
                  <MapPin class="w-4 h-4 text-blue-600" /> Información de Envío
                </h3>
                
                <div>
                  <label for="form-full-name" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 font-sans">
                    Nombre Completo *
                  </label>
                  <input
                    id="form-full-name"
                    type="text"
                    placeholder="Ej. Juan Pérez González"
                    v-model="fullName"
                    :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                      errors.fullName ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
                  />
                  <p v-if="errors.fullName" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
                    <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.fullName }}
                  </p>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label for="form-email" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 font-sans">
                      Correo Electrónico *
                    </label>
                    <input
                      id="form-email"
                      type="email"
                      placeholder="usuario@correo.com"
                      v-model="email"
                      :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                        errors.email ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
                    />
                    <p v-if="errors.email" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
                      <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.email }}
                    </p>
                  </div>

                  <div>
                    <label for="form-address" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 font-sans">
                      Dirección de Envío *
                    </label>
                    <input
                      id="form-address"
                      type="text"
                      placeholder="Calle 123, Colonia, Estado"
                      v-model="address"
                      :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                        errors.address ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
                    />
                    <p v-if="errors.address" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
                      <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.address }}
                    </p>
                  </div>
                </div>

                <h3 class="text-sm font-bold text-slate-800 border-b border-slate-100 pt-3 pb-2 flex items-center gap-1.5">
                  <CreditCard class="w-4 h-4 text-blue-600" /> Tarjeta de Crédito (Simulado)
                </h3>

                <div>
                  <label for="form-card-num" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 font-sans">
                    Número de Tarjeta *
                  </label>
                  <div class="relative">
                    <input
                      id="form-card-num"
                      type="text"
                      placeholder="0000 0000 0000 0000"
                      :value="cardNumber"
                      @input="handleCardNumberChange"
                      :class="['w-full pl-10 pr-4 py-2.5 rounded-xl border text-sm font-mono focus:outline-none focus:ring-2 focus:ring-blue-100',
                        errors.cardNumber ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
                    />
                    <CreditCard class="w-4 h-4 text-slate-400 absolute left-3.5 top-3.5" />
                  </div>
                  <p v-if="errors.cardNumber" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
                    <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.cardNumber }}
                  </p>
                </div>

                <div class="grid grid-cols-2 gap-3">
                  <div>
                    <label for="form-expiry" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 font-sans">
                      Vencimiento *
                    </label>
                    <input
                      id="form-expiry"
                      type="text"
                      placeholder="MM/AA"
                      :value="expiry"
                      @input="handleExpiryChange"
                      :class="['w-full px-4 py-2.5 rounded-xl border text-sm font-mono focus:outline-none focus:ring-2 focus:ring-blue-100',
                        errors.expiry ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
                    />
                    <p v-if="errors.expiry" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
                      <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.expiry }}
                    </p>
                  </div>

                  <div>
                    <label for="form-cvv" class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 font-sans">
                      CVV *
                    </label>
                    <input
                      id="form-cvv"
                      type="password"
                      placeholder="•••"
                      :value="cvv"
                      @input="e => cvv = e.target.value.replace(/\D/g, '').slice(0, 4)"
                      :class="['w-full px-4 py-2.5 rounded-xl border text-sm font-mono focus:outline-none focus:ring-2 focus:ring-blue-100',
                        errors.cvv ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
                    />
                    <p v-if="errors.cvv" class="flex items-center gap-1 mt-1 text-xs text-rose-600 font-medium font-sans">
                      <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.cvv }}
                    </p>
                  </div>
                </div>

                <p class="text-[10px] text-slate-550 bg-slate-50 border border-slate-200 rounded-xl p-3 leading-relaxed mt-2 font-normal">
                  🛡️ Transacción mock de simulación académica. ElectroMart encripta los datos y no almacena claves bancarias reales.
                </p>
              </div>
            </div>
          </form>
        </template>

        <!-- CART ITEMS SCROLL VIEW -->
        <template v-else>
          <div id="cart-items-scroll" class="flex-1 overflow-y-auto p-5 space-y-4">
            <div v-if="cartItems.length === 0" id="empty-cart-splash" class="h-full flex flex-col items-center justify-center text-center space-y-4 py-16">
              <div class="w-16 h-16 bg-slate-50 text-slate-400 rounded-full flex items-center justify-center border border-slate-200">
                <ShoppingCart class="w-8 h-8 text-slate-400" />
              </div>
              <div class="space-y-1 max-w-xs">
                <h3 class="text-base font-bold text-slate-800">Tu carrito se encuentra vacío</h3>
                <p class="text-xs text-slate-500 leading-normal font-normal">
                  Explora el catálogo, selecciona tus gadgets favoritos de tecnología y agrégalos aquí.
                </p>
              </div>
              <button
                @click="onClose"
                class="px-5 py-2.5 bg-blue-50 hover:bg-blue-100 text-blue-700 font-bold rounded-xl text-xs transition active:scale-95 cursor-pointer"
              >
                Regresar al Catálogo
              </button>
            </div>

            <div v-else class="space-y-3">
              <div
                v-for="item in cartItems"
                :key="`cart-item-${item.product.id}`"
                class="flex items-center gap-3 bg-white p-3 border border-slate-200 rounded-2xl hover:border-slate-300 shadow-xs transition"
              >
                <!-- Product Thumbnail -->
                <img
                  :src="item.product.image"
                  :alt="item.product.name"
                  class="w-16 h-16 object-cover rounded-xl bg-slate-50 border border-slate-100 shrink-0"
                  referrerPolicy="no-referrer"
                />

                <div class="flex-1 min-w-0 text-left">
                  <span class="text-[9px] font-bold tracking-wider uppercase text-slate-450 block mb-0.5">
                    {{ item.product.category }}
                  </span>
                  <h4 class="text-xs sm:text-sm font-bold text-slate-800 truncate" :title="item.product.name">
                    {{ item.product.name }}
                  </h4>
                  <span class="text-xs sm:text-sm font-bold text-blue-600 block mt-0.5">
                    {{ formatPrice(item.product.price) }}
                  </span>
                </div>

                <!-- Quantity Controls -->
                <div class="flex flex-col items-end gap-1.5 shrink-0">
                  <div class="flex items-center bg-slate-50 border border-slate-200 rounded-lg overflow-hidden h-7">
                    <button
                      @click="onUpdateQuantity(item.product.id, item.quantity - 1)"
                      class="p-1 px-1.5 hover:bg-slate-100/50 text-slate-500 transition duration-105 cursor-pointer"
                      aria-label="Disminuir"
                    >
                      <Minus class="w-3 h-3" />
                    </button>
                    <span class="px-2 text-xs font-bold text-slate-800 font-sans min-w-[20px] text-center">
                      {{ item.quantity }}
                    </span>
                    <button
                      @click="onUpdateQuantity(item.product.id, item.quantity + 1)"
                      :disabled="item.quantity >= item.product.stock"
                      :class="['p-1 px-1.5 hover:bg-slate-100/50 text-slate-500 transition duration-105 cursor-pointer',
                        item.quantity >= item.product.stock ? 'opacity-30 cursor-not-allowed' : '']"
                      aria-label="Aumentar"
                    >
                      <Plus class="w-3 h-3" />
                    </button>
                  </div>

                  <button
                    @click="onRemoveItem(item.product.id)"
                    class="flex items-center gap-1 text-[10px] font-bold text-rose-500 hover:text-rose-700 transition cursor-pointer"
                  >
                    <Trash2 class="w-3 h-3" /> Eliminar
                  </button>
                </div>
              </div>
            </div>
          </div>
        </template>
      </div>

      <!-- Drawer Footer -->
      <div v-if="!purchaseSuccess && cartItems.length > 0" id="cart-drawer-footer" class="p-5 border-t border-slate-200 bg-slate-50 shrink-0 space-y-4">
        
        <!-- Price Calculations -->
        <div class="space-y-2 text-sm text-left">
          <div class="flex justify-between text-slate-550">
            <span>Subtotal</span>
            <span class="font-medium text-slate-700">{{ formatPrice(subtotal) }}</span>
          </div>
          <div class="flex justify-between text-slate-550">
            <span class="flex items-center gap-1 text-slate-500">
              Envío <span v-if="shippingFee === 0" class="text-[10px] font-bold text-emerald-600 bg-emerald-50 border border-emerald-100 px-1 py-0.5 rounded">Gratis</span>
            </span>
            <span class="font-medium text-slate-705">{{ shippingFee === 0 ? 'Gratis' : formatPrice(shippingFee) }}</span>
          </div>
          <p v-if="shippingFee > 0" class="text-[10px] text-blue-600 font-semibold leading-none">
            💡 ¡Agrega {{ formatPrice(1500 - subtotal) }} más para obtener envío gratis!
          </p>
          <div class="flex justify-between text-base font-bold text-slate-800 pt-2 border-t border-slate-200">
            <span>Total de Compra</span>
            <span class="text-blue-600 font-bold">{{ formatPrice(total) }}</span>
          </div>
        </div>

        <!-- Confirmations / Proceed Buttons -->
        <div class="flex gap-2">
          <template v-if="isCheckoutStep">
            <button
              id="checkout-cancel-btn"
              @click="isCheckoutStep = false"
              class="w-1/3 py-3 bg-white border border-slate-200 text-slate-700 font-bold rounded-xl text-center text-sm hover:bg-slate-50 transition cursor-pointer"
            >
              Regresar
            </button>
            <button
              id="checkout-confirm-btn"
              @click="handleCheckoutSubmit"
              class="w-2/3 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-center text-sm shadow-xs transition cursor-pointer"
            >
              Confirmar Pago
            </button>
          </template>
          <button
            v-else
            id="cart-proceed-checkout-btn"
            @click="isCheckoutStep = true"
            class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-center text-sm shadow-xs flex items-center justify-center gap-1.5 transition cursor-pointer"
          >
            <span>Proceder al Pago</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
