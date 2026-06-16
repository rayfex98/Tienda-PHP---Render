import { reactive, watch } from 'vue';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost/api';

// Initialize core state
const state = reactive({
  products: [],
  reviews: [],
  cart: JSON.parse(localStorage.getItem('electromart_cart')) || [],
  messages: [],
  isCartOpen: false,
  isFormModalOpen: false,
  productToEdit: null,
  searchQuery: '',
  isAdminMode: false,
  toast: null,
  toastTimeout: null
});

// Load initial data from the database asynchronously
async function initStore() {
  try {
    const res = await fetch(`${API_BASE_URL}/products.php`);
    if (res.ok) {
      state.products = await res.json();
    }
  } catch (e) {
    console.error('Error fetching products from database:', e);
  }

  try {
    const res = await fetch(`${API_BASE_URL}/reviews.php`);
    if (res.ok) {
      state.reviews = await res.json();
    }
  } catch (e) {
    console.error('Error fetching reviews from database:', e);
  }

  try {
    const res = await fetch(`${API_BASE_URL}/messages.php`);
    if (res.ok) {
      state.messages = await res.json();
    }
  } catch (e) {
    console.error('Error fetching messages from database:', e);
  }
}

// Call initStore on startup
initStore();

// Watcher for cart (stored locally on client)
watch(() => state.cart, (newCart) => {
  localStorage.setItem('electromart_cart', JSON.stringify(newCart));
}, { deep: true });

// Actions that can be imported to modify the reactive state safely
export const store = {
  state,

  // Toast notifications
  triggerToast(message, type = 'success') {
    state.toast = { message, type };
    if (state.toastTimeout) {
      clearTimeout(state.toastTimeout);
    }
    state.toastTimeout = setTimeout(() => {
      state.toast = null;
      state.toastTimeout = null;
    }, 3500);
  },

  // Cart operations
  addToCart(product, quantity = 1) {
    if (product.stock === 0) {
      this.triggerToast('Este producto se encuentra agotado actualmente.', 'warn');
      return;
    }
    const existingIndex = state.cart.findIndex(item => item.product.id === product.id);
    if (existingIndex !== -1) {
      const newQty = state.cart[existingIndex].quantity + quantity;
      if (newQty > product.stock) {
        this.triggerToast(`Límite de stock alcanzado para "${product.name}".`, 'warn');
        state.cart[existingIndex].quantity = product.stock;
      } else {
        state.cart[existingIndex].quantity = newQty;
        this.triggerToast(`Se incrementó la cantidad de "${product.name}" en tu carrito.`);
      }
    } else {
      state.cart.push({ product: { ...product }, quantity: Math.min(quantity, product.stock) });
      this.triggerToast(`"${product.name}" agregado al carrito.`);
    }
    state.isCartOpen = true; // Auto open cart drawer
  },

  updateCartQuantity(productId, quantity) {
    const item = state.cart.find(item => item.product.id === productId);
    if (item) {
      if (quantity <= 0) {
        this.removeFromCart(productId);
      } else {
        if (quantity > item.product.stock) {
          this.triggerToast(`Límite máximo excedido. Solo quedan ${item.product.stock} un.`, 'warn');
          item.quantity = item.product.stock;
        } else {
          item.quantity = quantity;
        }
      }
    }
  },

  removeFromCart(productId) {
    const item = state.cart.find(item => item.product.id === productId);
    state.cart = state.cart.filter(item => item.product.id !== productId);
    if (item) {
      this.triggerToast(`Se removió "${item.product.name}" del carrito.`, 'info');
    }
  },

  clearCart() {
    state.cart = [];
  },

  // Product CRUD
  async addProduct(product) {
    try {
      const response = await fetch(`${API_BASE_URL}/products.php`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(product)
      });

      if (response.ok) {
        const newProduct = await response.json();
        state.products.push(newProduct);
        this.triggerToast(`"${product.name}" creado e insertado exitosamente.`);
      } else {
        const err = await response.json();
        this.triggerToast(err.error || 'Error al crear producto.', 'error');
      }
    } catch (e) {
      console.error('Network error creating product:', e);
      this.triggerToast('Error de red al intentar crear el producto.', 'error');
    }
  },

  async updateProduct(updatedProduct) {
    try {
      const response = await fetch(`${API_BASE_URL}/products.php`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedProduct)
      });

      if (response.ok) {
        const returnedProduct = await response.json();
        const idx = state.products.findIndex(p => p.id === returnedProduct.id);
        if (idx !== -1) {
          state.products[idx] = returnedProduct;
        }

        // Sync update to cart if it currently lives there
        const cartItem = state.cart.find(item => item.product.id === returnedProduct.id);
        if (cartItem) {
          cartItem.product = { ...returnedProduct };
          // Clamp quantity if stock decreased
          if (cartItem.quantity > returnedProduct.stock) {
            cartItem.quantity = returnedProduct.stock;
          }
          if (cartItem.quantity <= 0) {
            this.removeFromCart(returnedProduct.id);
          }
        }
        this.triggerToast(`"${returnedProduct.name}" modificado de forma exitosa.`);
      } else {
        const err = await response.json();
        this.triggerToast(err.error || 'Error al modificar producto.', 'error');
      }
    } catch (e) {
      console.error('Network error updating product:', e);
      this.triggerToast('Error de red al intentar actualizar el producto.', 'error');
    }
  },

  async deleteProduct(productId) {
    try {
      const response = await fetch(`${API_BASE_URL}/products.php?id=${productId}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        const prod = state.products.find(p => p.id === productId);
        state.products = state.products.filter(p => p.id !== productId);
        this.removeFromCart(productId);
        if (prod) {
          this.triggerToast(`"${prod.name}" eliminado del catálogo.`, 'warn');
        }
      } else {
        const err = await response.json();
        this.triggerToast(err.error || 'Error al eliminar producto.', 'error');
      }
    } catch (e) {
      console.error('Network error deleting product:', e);
      this.triggerToast('Error de red al intentar eliminar el producto.', 'error');
    }
  },

  // Reviews CRUD
  async addReview(review) {
    try {
      const response = await fetch(`${API_BASE_URL}/reviews.php`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(review)
      });

      if (response.ok) {
        const newReview = await response.json();
        state.reviews.push(newReview);

        // Reload products list to get updated average rating calculated by the DB
        const productsRes = await fetch(`${API_BASE_URL}/products.php`);
        if (productsRes.ok) {
          state.products = await productsRes.json();
        }
        this.triggerToast('¡Gracias! Tu valoración técnica fue registrada.');
      } else {
        const err = await response.json();
        this.triggerToast(err.error || 'Error al registrar valoración.', 'error');
      }
    } catch (e) {
      console.error('Network error adding review:', e);
      this.triggerToast('Error de red al registrar valoración.', 'error');
    }
  },

  // Contact communications messages
  async addMessage(message) {
    try {
      const response = await fetch(`${API_BASE_URL}/messages.php`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(message)
      });

      if (response.ok) {
        const newMessage = await response.json();
        state.messages.push(newMessage);
        this.triggerToast('Mensaje de contacto indexado exitosamente.');
      } else {
        const err = await response.json();
        this.triggerToast(err.error || 'Error al guardar mensaje.', 'error');
      }
    } catch (e) {
      console.error('Network error adding contact message:', e);
      this.triggerToast('Error de red al enviar mensaje de contacto.', 'error');
    }
  }
};

