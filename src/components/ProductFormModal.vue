<script setup>
import { ref, watch } from 'vue';
import { X, Sparkles, AlertCircle, Trash2, Plus, Check } from 'lucide-vue-next';

const props = defineProps({
  isOpen: { type: Boolean, required: true },
  productToEdit: { type: [Object, null], default: null }
});

const emit = defineEmits(['close', 'save']);

const IMAGE_PRESETS = [
  { label: 'Laptop / PC', url: 'https://images.unsplash.com/photo-1496181130207-89353039897d?w=600&auto=format&fit=crop&q=80' },
  { label: 'Smartphone', url: 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&auto=format&fit=crop&q=80' },
  { label: 'Auriculares', url: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=600&auto=format&fit=crop&q=80' },
  { label: 'Smartwatch', url: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=600&auto=format&fit=crop&q=80' },
  { label: 'Pantalla TV', url: 'https://images.unsplash.com/photo-1461151304267-38535e780c79?w=600&auto=format&fit=crop&q=80' },
  { label: 'Cámara Pro', url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&auto=format&fit=crop&q=80' },
  { label: 'Hogar Inteligente', url: 'https://images.unsplash.com/photo-1558002038-1055907df827?w=600&auto=format&fit=crop&q=80' },
  { label: 'Consola Video', url: 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=600&auto=format&fit=crop&q=80' },
];

const CATEGORIES = [
  { id: 'laptops', name: 'Laptops y Computadoras' },
  { id: 'smartphones', name: 'Smartphones' },
  { id: 'audio', name: 'Audio y Música' },
  { id: 'wearables', name: 'Wearables y Relojes' },
  { id: 'televisiones', name: 'Televisores y Entretenimiento' },
  { id: 'hogar-inteligente', name: 'Hogar Inteligente' },
];

const name = ref('');
const category = ref('laptops');
const price = ref('');
const stock = ref('');
const image = ref('');
const description = ref('');
const specs = ref([]);
const newSpec = ref('');

const errors = ref({});
const submitAttempted = ref(false);

const resetForm = () => {
  if (props.productToEdit) {
    name.value = props.productToEdit.name;
    category.value = props.productToEdit.category;
    price.value = props.productToEdit.price.toString();
    stock.value = props.productToEdit.stock.toString();
    image.value = props.productToEdit.image;
    description.value = props.productToEdit.description;
    specs.value = [...props.productToEdit.specs];
  } else {
    name.value = '';
    category.value = 'laptops';
    price.value = '';
    stock.value = '';
    image.value = IMAGE_PRESETS[0].url;
    description.value = '';
    specs.value = ['Garantía por defecto: 1 año', 'Incluye cargador y manual original'];
  }
  newSpec.value = '';
  errors.value = {};
  submitAttempted.value = false;
};

// Sync fields when modal is shown or product to edit changes
watch(() => [props.productToEdit, props.isOpen], resetForm, { immediate: true });

const validateForm = () => {
  const tempErrors = {};

  if (name.value.trim().length < 3) {
    tempErrors.name = 'El nombre debe tener al menos 3 caracteres.';
  }

  if (!category.value) {
    tempErrors.category = 'Debe seleccionar una categoría válida.';
  }

  const priceVal = parseFloat(price.value);
  if (isNaN(priceVal) || priceVal <= 0) {
    tempErrors.price = 'Ingrese un precio válido y mayor a cero.';
  }

  const stockVal = parseInt(stock.value, 10);
  if (isNaN(stockVal) || stockVal < 0) {
    tempErrors.stock = 'La cantidad de stock no puede ser negativa.';
  }

  if (!image.value.trim().startsWith('http://') && !image.value.trim().startsWith('https://')) {
    tempErrors.image = 'La imagen debe ser una URL válida (http/https).';
  }

  if (description.value.trim().length < 10) {
    tempErrors.description = 'La descripción debe tener al menos 10 caracteres.';
  }

  if (specs.value.length === 0) {
    tempErrors.specs = 'Debe agregar al menos una especificación técnica del producto.';
  }

  errors.value = tempErrors;
  return Object.keys(tempErrors).length === 0;
};

// Live validation once initial attempt is made
watch([name, category, price, stock, image, description, specs], () => {
  if (submitAttempted.value) {
    validateForm();
  }
}, { deep: true });

const handleAddSpec = (e) => {
  e.preventDefault();
  if (newSpec.value.trim()) {
    specs.value.push(newSpec.value.trim());
    newSpec.value = '';
  }
};

const handleRemoveSpec = (index) => {
  specs.value.splice(index, 1);
};

const handleSubmit = (e) => {
  e.preventDefault();
  submitAttempted.value = true;

  if (validateForm()) {
    const payload = {
      name: name.value.trim(),
      category: category.value,
      price: parseFloat(price.value),
      stock: parseInt(stock.value, 10),
      image: image.value.trim(),
      description: description.value.trim(),
      specs: [...specs.value]
    };
    if (props.productToEdit) {
      payload.id = props.productToEdit.id;
      payload.rating = props.productToEdit.rating;
      payload.featured = props.productToEdit.featured;
    }
    emit('save', payload);
  }
};
</script>

<template>
  <div v-if="isOpen" id="product-form-modal-overlay" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 overflow-y-auto" @click.self="emit('close')">
    <div
      id="product-form-panel"
      class="relative bg-white w-full max-w-2xl rounded-3xl shadow-xl overflow-hidden animate-scale-in max-h-[90vh] flex flex-col cursor-default"
    >
      <!-- Modal Header -->
      <div class="flex items-center justify-between p-6 border-b border-slate-100 shrink-0">
        <div class="flex items-center gap-2">
          <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
            <Sparkles class="w-5 h-5" />
          </div>
          <h2 class="text-xl font-bold text-slate-850">
            {{ productToEdit ? 'Editar Producto Electrónico' : 'Agregar Nuevo Producto' }}
          </h2>
        </div>
        <button
          id="close-product-form-modal"
          @click="emit('close')"
          class="p-1.5 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-slate-800 transition cursor-pointer"
        >
          <X class="w-5 h-5" />
        </button>
      </div>

      <!-- Form Body scrollable -->
      <form @submit="handleSubmit" class="flex-1 overflow-y-auto p-6 space-y-5 text-left">
        <!-- Main Name & Price block -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label for="form-prod-name" class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
              Nombre del Producto *
            </label>
            <input
              id="form-prod-name"
              type="text"
              placeholder="Ej. Smart Earbuds Pro 3"
              v-model="name"
              :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                errors.name ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
            />
            <p v-if="errors.name" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
              <AlertCircle class="w-3.5 h-3.5" /> {{ errors.name }}
            </p>
          </div>

          <div>
            <label for="form-prod-category" class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
              Categoría *
            </label>
            <select
              id="form-prod-category"
              v-model="category"
              class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 cursor-pointer bg-white"
            >
              <option v-for="c in CATEGORIES" :key="c.id" :value="c.id">
                {{ c.name }}
              </option>
            </select>
            <p v-if="errors.category" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
              <AlertCircle class="w-3.5 h-3.5" /> {{ errors.category }}
            </p>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label for="form-prod-price" class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
              Precio (MXN) *
            </label>
            <input
              id="form-prod-price"
              type="number"
              step="0.01"
              placeholder="0.00"
              v-model="price"
              :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                errors.price ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
            />
            <p v-if="errors.price" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
              <AlertCircle class="w-3.5 h-3.5" /> {{ errors.price }}
            </p>
          </div>

          <div>
            <label for="form-prod-stock" class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
              Stock Inicial *
            </label>
            <input
              id="form-prod-stock"
              type="number"
              placeholder="0"
              v-model="stock"
              :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                errors.stock ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
            />
            <p v-if="errors.stock" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
              <AlertCircle class="w-3.5 h-3.5" /> {{ errors.stock }}
            </p>
          </div>
        </div>

        <!-- Image Presets Panel -->
        <div>
          <span class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
            Seleccionar Imagen (Presets o URL manual)
          </span>
          <div class="grid grid-cols-4 sm:grid-cols-8 gap-2.5 mb-3">
            <button
              v-for="(preset, index) in IMAGE_PRESETS"
              :key="`preset-${index}`"
              type="button"
              @click="image = preset.url"
              :class="['relative aspect-square rounded-xl overflow-hidden border-2 transition cursor-pointer',
                image === preset.url ? 'border-blue-600 shadow-sm ring-2 ring-blue-50' : 'border-transparent hover:scale-105']"
              :title="preset.label"
            >
              <img :src="preset.url" :alt="preset.label" class="w-full h-full object-cover" referrerPolicy="no-referrer" />
              <div v-if="image === preset.url" class="absolute inset-0 bg-blue-600/15 flex items-center justify-center">
                <Check class="w-4 h-4 text-white drop-shadow-md" />
              </div>
            </button>
          </div>
          <input
            type="text"
            placeholder="URL de la imagen (ej: https://...)"
            v-model="image"
            :class="['w-full px-4 py-2.5 rounded-xl border text-sm font-mono text-xs focus:outline-none focus:ring-2 focus:ring-blue-100',
              errors.image ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
          />
          <p v-if="errors.image" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
            <AlertCircle class="w-3.5 h-3.5" /> {{ errors.image }}
          </p>
        </div>

        <!-- Description -->
        <div>
          <label for="form-prod-desc" class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
            Descripción Corta *
          </label>
          <textarea
            id="form-prod-desc"
            rows="3"
            placeholder="Detalles sobre las características generales del producto electrónico..."
            v-model="description"
            :class="['w-full px-4 py-2.5 rounded-xl border text-sm focus:outline-none focus:ring-2 focus:ring-blue-100 resize-none',
              errors.description ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500']"
          ></textarea>
          <p v-if="errors.description" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
            <AlertCircle class="w-3.5 h-3.5" /> {{ errors.description }}
          </p>
        </div>

        <!-- Specifications Management -->
        <div class="border-t border-slate-100 pt-5">
          <span class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2 font-sans">
            Especificaciones Técnicas ({{ specs.length }}) *
          </span>

          <ul v-if="specs.length > 0" class="space-y-2 mb-3">
            <li
              v-for="(item, index) in specs"
              :key="`spec-${index}`"
              class="flex items-center justify-between gap-2 px-3 py-2 bg-slate-50 border border-slate-150 rounded-xl"
            >
              <span class="text-xs text-slate-700 truncate font-normal">{{ item }}</span>
              <button
                type="button"
                @click="handleRemoveSpec(index)"
                class="p-1 hover:bg-rose-100 hover:text-rose-700 rounded text-slate-400 transition cursor-pointer"
                title="Eliminar especificación"
              >
                <Trash2 class="w-3.5 h-3.5" />
              </button>
            </li>
          </ul>

          <div class="flex gap-2">
            <input
              type="text"
              placeholder="Ej. Batería de 5000 mAh con carga de 30W"
              v-model="newSpec"
              @keydown.enter="handleAddSpec"
              class="flex-1 px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
            />
            <button
              type="button"
              @click="handleAddSpec"
              class="px-4 py-2.5 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-xl font-bold text-sm flex items-center gap-1.5 transition cursor-pointer"
            >
              <Plus class="w-4 h-4" /> Agregar
            </button>
          </div>
          <p v-if="errors.specs" class="flex items-center gap-1 mt-1.5 text-xs text-rose-600 font-medium font-sans">
            <AlertCircle class="w-3.5 h-3.5" /> {{ errors.specs }}
          </p>
        </div>
      </form>

      <!-- Modal Footer -->
      <div class="p-6 border-t border-slate-200 bg-slate-50 flex items-center justify-end gap-3 shrink-0">
        <button
          type="button"
          @click="emit('close')"
          class="px-5 py-2.5 bg-white border border-slate-200 hover:bg-slate-100 rounded-xl text-sm font-semibold text-slate-700 transition cursor-pointer"
        >
          Cancelar
        </button>
        <button
          type="button"
          @click="handleSubmit"
          class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-xs transition cursor-pointer"
        >
          {{ productToEdit ? 'Guardar Cambios' : 'Crear Producto' }}
        </button>
      </div>
    </div>
  </div>
</template>
