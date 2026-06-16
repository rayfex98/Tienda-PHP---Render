<script setup>
import { useRouter } from 'vue-router';
import { Laptop, Mail, Phone, MapPin, Shield, Award } from 'lucide-vue-next';

const router = useRouter();

const handleNavClick = (path) => {
  router.push(path);
};
</script>

<template>
  <footer id="footer-container" class="bg-gray-900 text-gray-300 border-t border-gray-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-16">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8 md:gap-12 pb-12 border-b border-gray-800">
        
        {/* Brand Info */}
        <div id="footer-brand" class="space-y-4">
          <div class="flex items-center cursor-pointer" @click="handleNavClick('/')">
            <div class="p-2 bg-blue-600 rounded-lg text-white mr-2">
              <Laptop class="w-5 h-5" />
            </div>
            <span class="text-lg font-bold tracking-tight text-white">
              Electro<span class="text-blue-500">Mart</span>
            </span>
          </div>
          <p class="text-sm text-slate-400 leading-relaxed font-normal">
            La tienda líder en venta de componentes electrónicos y gadgets de última generación con garantía certificada y soporte premium.
          </p>
          <div class="flex space-x-3 text-xs font-semibold">
            <span class="flex items-center gap-1 text-emerald-400 bg-emerald-900/20 px-2 py-1 rounded">
              <Shield class="w-3.5 h-3.5" /> Compra Segura
            </span>
            <span class="flex items-center gap-1 text-blue-400 bg-blue-900/20 px-2 py-1 rounded">
              <Award class="w-3.5 h-3.5" /> Oficial
            </span>
          </div>
        </div>

        {/* Quick Links */}
        <div id="footer-links-explore" class="space-y-4">
          <h3 class="text-sm font-semibold text-white tracking-wider uppercase">Explorar</h3>
          <ul class="space-y-2.5 text-sm">
            <li>
              <button 
                @click="handleNavClick('/')" 
                class="hover:text-white hover:underline transition-all text-left cursor-pointer"
              >
                Inicio
              </button>
            </li>
            <li>
              <button 
                @click="handleNavClick('/catalogo')" 
                class="hover:text-white hover:underline transition-all text-left cursor-pointer"
              >
                Catálogo de Productos
              </button>
            </li>
            <li>
              <button 
                @click="handleNavClick('/nosotros')" 
                class="hover:text-white hover:underline transition-all text-left cursor-pointer"
              >
                Sobre Nosotros
              </button>
            </li>
          </ul>
        </div>

        {/* Categories */}
        <div id="footer-links-categories" class="space-y-4">
          <h3 class="text-sm font-semibold text-white tracking-wider uppercase">Categorías</h3>
          <ul class="space-y-2.5 text-sm text-gray-400">
            <li>Laptops y Computadores</li>
            <li>Smartphones de Alta Gama</li>
            <li>Audio de Resolución Alta</li>
            <li>Hogar Inteligente & Wearables</li>
          </ul>
        </div>

        {/* Location and Contact */}
        <div id="footer-contact-info" class="space-y-4">
          <h3 class="text-sm font-semibold text-white tracking-wider uppercase font-sans">Contacto & Soporte</h3>
          <ul class="space-y-3 text-sm">
            <li class="flex items-start gap-2.5 text-slate-400">
              <MapPin class="w-4 h-4 text-blue-400 shrink-0 mt-0.5" />
              <span class="font-normal text-slate-400">Av. Tecnológica 1024, Complejo Científico, CDMX, México</span>
            </li>
            <li class="flex items-center gap-2.5 text-slate-400">
              <Phone class="w-4 h-4 text-blue-400 shrink-0" />
              <span class="font-normal text-slate-400">+52 (55) 4892-0294</span>
            </li>
            <li class="flex items-center gap-2.5 text-slate-400">
              <Mail class="w-4 h-4 text-blue-400 shrink-0" />
              <span class="font-normal text-slate-400">contacto@electromart.com</span>
            </li>
          </ul>
        </div>

      </div>

      <div class="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-gray-500">
        <p>© 2026 ElectroMart Inc. Todos los derechos reservados. Diseñado bajo exigencias de alto rendimiento.</p>
        <div class="flex space-x-4">
          <span>Privacidad</span>
          <span>Términos y Condiciones</span>
          <span>Garantías</span>
        </div>
      </div>
    </div>
  </footer>
</template>
