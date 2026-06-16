<script setup>
import { ref, computed, watch } from 'vue';
import { store } from '../store.js';
import { 
  Mail, Phone, MapPin, Send, AlertCircle, CheckCircle, 
  ShieldCheck, Heart, Sparkles, MessageSquare 
} from 'lucide-vue-next';

// Form states
const name = ref('');
const email = ref('');
const subject = ref('');
const message = ref('');

// Statuses
const errors = ref({});
const submitAttempted = ref(false);
const isSuccess = ref(false);

const storedMessages = computed(() => store.state.messages);

const validateForm = () => {
  const tempErrors = {};

  if (name.value.trim().length < 4) {
    tempErrors.name = 'El nombre completo debe tener al menos 4 caracteres.';
  } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(name.value)) {
    tempErrors.name = 'Solo se permiten letras y espacios.';
  }

  if (!email.value.trim()) {
    tempErrors.email = 'El correo electrónico es obligatorio.';
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
    tempErrors.email = 'Ingrese una estructura de correo electrónico válida.';
  }

  if (subject.value.trim().length < 4) {
    tempErrors.subject = 'El asunto debe tener un título explicativo de al menos 4 letras.';
  }

  if (message.value.trim().length < 15) {
    tempErrors.message = 'El mensaje para el departamento técnico debe constar de al menos 15 letras.';
  }

  errors.value = tempErrors;
  return Object.keys(tempErrors).length === 0;
};

// Live validation on changes after user submitted once
watch([name, email, subject, message], () => {
  if (submitAttempted.value) {
    validateForm();
  }
});

const handleSubmit = (e) => {
  e.preventDefault();
  submitAttempted.value = true;

  if (validateForm()) {
    const newMessage = {
      name: name.value.trim(),
      email: email.value.trim(),
      subject: subject.value.trim(),
      message: message.value.trim(),
      date: new Date().toISOString().replace('T', ' ').slice(0, 16)
    };

    store.addMessage(newMessage);
    isSuccess.value = true;

    // Blank out variables
    name.value = '';
    email.value = '';
    subject.value = '';
    message.value = '';
    errors.value = {};
    submitAttempted.value = false;

    // Hide success message after 5 seconds
    setTimeout(() => {
      isSuccess.value = false;
    }, 6000);
  }
};
</script>

<template>
  <div id="about-us-container" class="space-y-12 sm:space-y-16 pb-16 animate-fade-in text-slate-800">
    
    <!-- 1. HERO BRAND INTRO -->
    <section id="about-brand-card" class="relative p-8 sm:p-12 rounded-3xl bg-slate-900 overflow-hidden text-white shadow-md flex items-center justify-between text-left">
      <div class="absolute inset-0 bg-linear-to-br from-slate-950 via-slate-900 to-slate-850 opacity-95"></div>
      
      <!-- Abstract background graphics -->
      <div class="absolute top-0 right-0 w-80 h-80 bg-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-15 animate-pulse"></div>
      <div class="absolute bottom-0 left-10 w-60 h-60 bg-slate-800 rounded-full mix-blend-multiply filter blur-2xl opacity-20"></div>

      <div class="relative z-10 max-w-xl space-y-4">
        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-white/10 border border-white/20 text-white tracking-widest uppercase">
          SABER MÁS DE NOSOTROS
        </span>
        <h1 class="text-3xl sm:text-4xl font-extrabold tracking-tight leading-tight">
          Nuestra Historia & Compromiso Tecnológico
        </h1>
        <p class="text-sm text-slate-300 leading-relaxed font-normal">
          ElectroMart fue fundada en 2021 en la Ciudad de México por un colectivo de ingenieros informáticos obsesionados con la democratización del hardware premium. Nos especializamos en proveer microcomponentes de precisión, gadgets inteligentes y laptops de alto rendimiento bajo estándares rigurosos de control de calidad.
        </p>
      </div>

      <div class="hidden lg:flex relative z-10 p-6 bg-white/5 rounded-2xl border border-white/10 backdrop-blur-xs max-w-xs shrink-0 select-none flex-col">
        <p class="text-xs text-slate-300 leading-relaxed italic font-medium">
          "No vendemos simplemente circuitos integrados o plástico pulido; equipamos las ideas del mañana con la ingeniería del hoy."
        </p>
        <div class="mt-3 block border-t border-slate-700 pt-2 text-[10px] font-bold text-slate-400 tracking-widest uppercase">
          — FUNDACIÓN ELECTROMART
        </div>
      </div>
    </section>

    <!-- 2. CORPORATE CORE VALUES -->
    <section id="corporate-values" class="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8 text-center">
      <div class="bg-white border border-slate-200 p-6 rounded-2xl shadow-2xs">
        <div class="p-3.5 bg-blue-50 text-blue-600 rounded-2xl mx-auto max-w-max mb-4">
          <ShieldCheck class="w-6 h-6 stroke-[2]" />
        </div>
        <h3 class="text-base font-bold text-slate-800 mb-2 font-sans">Ingeniería Rigurosa</h3>
        <p class="text-xs sm:text-sm text-slate-500 leading-relaxed font-normal">
          Cada producto en nuestro catálogo atraviesa pruebas exhaustivas de voltaje, disipación térmica y durabilidad antes de ser despachado.
        </p>
      </div>

      <div class="bg-white border border-slate-200 p-6 rounded-2xl shadow-2xs">
        <div class="p-3.5 bg-emerald-50 text-emerald-600 rounded-2xl mx-auto max-w-max mb-4">
          <Heart class="w-6 h-6 stroke-[2]" />
        </div>
        <h3 class="text-base font-bold text-slate-800 mb-2 font-sans">Soporte Humano</h3>
        <p class="text-xs sm:text-sm text-slate-500 leading-relaxed font-normal">
          Olvídate de bots imprecisos. Contamos con ingenieros de carne y hueso listos para asistirte en resolver cualquier configuración.
        </p>
      </div>

      <div class="bg-white border border-slate-200 p-6 rounded-2xl shadow-2xs">
        <div class="p-3.5 bg-amber-50 text-amber-600 rounded-xl mx-auto max-w-max mb-4">
          <Sparkles class="w-6 h-6 stroke-[2]" />
        </div>
        <h3 class="text-base font-bold text-slate-800 mb-2 font-sans">Garantía Absoluta</h3>
        <p class="text-xs sm:text-sm text-slate-500 leading-relaxed font-normal">
          Ofrecemos coberturas extendidas y procesos de devolución sin burocracia dentro de las primeras semanas para tu máxima tranquilidad.
        </p>
      </div>
    </section>

    <!-- 3. CONTACT FORM & REGISTRY DATA -->
    <section id="contact-and-inbox-section" class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start text-left">
      
      <!-- Left side: Contact panel info + form -->
      <div class="lg:col-span-7 bg-white border border-slate-200 rounded-3xl p-6 sm:p-8 shadow-sm space-y-6">
        <div class="space-y-1.5 pb-4 border-b border-slate-150">
          <h2 class="text-xl font-bold text-slate-800 tracking-tight flex items-center gap-2">
            Enviar Mensaje al Equipo <Send class="w-4 h-4 text-blue-600" />
          </h2>
          <p class="text-xs sm:text-sm text-slate-500 font-normal">
            ¿Dudas técnicas de hardware, compatibilidad o cotizaciones especiales? Escríbenos y te responderemos en menos de 2 horas hábiles.
          </p>
        </div>

        <!-- Success toast inside column -->
        <div v-if="isSuccess" id="contact-success-alert" class="p-4 bg-emerald-50 border border-emerald-150 rounded-2xl text-emerald-800 flex items-start gap-2.5 animate-bounce">
          <CheckCircle class="w-5 h-5 shrink-0 text-emerald-600 mt-0.5" />
          <div>
            <h4 class="text-xs sm:text-sm font-bold">¡Mensaje Enviado con Éxito!</h4>
            <p class="text-xs text-emerald-650 mt-0.5 leading-normal font-normal">
              Su mensaje ha sido indexado en LocalStorage. Nuestro equipo técnico en servidores ya tiene su solicitud asignada.
            </p>
          </div>
        </div>

        <!-- Contact Input parameters -->
        <form @submit="handleSubmit" class="space-y-4">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label for="contact-form-name" class="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-1.5 font-sans">
                Nombre Completo *
              </label>
              <input
                id="contact-form-name"
                type="text"
                placeholder="Ej. Sofía Mendoza"
                v-model="name"
                :class="['w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                  errors.name ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500'
                ]"
              />
              <p v-if="errors.name" class="flex items-center gap-1 mt-1 text-xs text-rose-650 font-semibold font-sans">
                <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.name }}
              </p>
            </div>

            <div>
              <label for="contact-form-email" class="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-1.5 font-sans">
                Correo Electrónico *
              </label>
              <input
                id="contact-form-email"
                type="text"
                placeholder="usuario@correo.com"
                v-model="email"
                :class="['w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                  errors.email ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500'
                ]"
              />
              <p v-if="errors.email" class="flex items-center gap-1 mt-1 text-xs text-rose-650 font-semibold font-sans">
                <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.email }}
              </p>
            </div>
          </div>

          <div>
            <label for="contact-form-subject" class="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-1.5 font-sans">
              Asunto de la Solicitud *
              </label>
            <input
              id="contact-form-subject"
              type="text"
              placeholder="Ej. Compatibilidad de memorias RAM DDR5 o Cotización corporativa"
              v-model="subject"
              :class="['w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-blue-100',
                errors.subject ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500'
              ]"
            />
            <p v-if="errors.subject" class="flex items-center gap-1 mt-1 text-xs text-rose-650 font-semibold font-sans">
              <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.subject }}
            </p>
          </div>

          <div>
            <label for="contact-form-message" class="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-1.5 font-sans">
              Mensaje Detallado *
            </label>
            <textarea
              id="contact-form-message"
              rows="5"
              placeholder="Hola equipo ElectroMart, me gustaría saber si la laptop ZenBook Pro Duo soporta..."
              v-model="message"
              :class="['w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-blue-100 resize-none',
                errors.message ? 'border-rose-300 focus:border-rose-500' : 'border-slate-200 focus:border-blue-500'
              ]"
            ></textarea>
            <p v-if="errors.message" class="flex items-center gap-1 mt-1 text-xs text-rose-650 font-semibold font-sans">
              <AlertCircle class="w-3.5 h-3.5 shrink-0" /> {{ errors.message }}
            </p>
          </div>

          <button
            type="submit"
            class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-xs sm:text-sm shadow-sm transition active:scale-95 flex items-center justify-center gap-1.5 cursor-pointer font-sans"
          >
            <Send class="w-4 h-4" /> Enviar Formulario
          </button>
        </form>
      </div>

      <!-- Right side: Location list + Sent Messages Log (Inbox simulation!) -->
      <div class="lg:col-span-5 space-y-6">
        <!-- Quick contact direct values -->
        <div class="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm space-y-4">
          <h3 class="text-sm font-bold text-slate-805 border-b border-slate-100 pb-2.5 uppercase tracking-wide font-sans">
            Oficinas Generales
          </h3>
          
          <ul class="space-y-4 text-xs sm:text-sm">
            <li class="flex items-start gap-2.5">
              <MapPin class="w-4.5 h-4.5 text-blue-650 mt-0.5 shrink-0" />
              <div class="space-y-0.5">
                <span class="font-bold text-slate-800">Dirección Física</span>
                <p class="text-slate-500 leading-relaxed font-normal">Av. Tecnológica 1024, Complejo Científico, CDMX, México</p>
              </div>
            </li>

            <li class="flex items-start gap-2.5">
              <Phone class="w-4.5 h-4.5 text-blue-655 mt-0.5 shrink-0" />
              <div class="space-y-0.5">
                <span class="font-bold text-slate-800">Soporte telefónico</span>
                <p class="text-slate-500 leading-relaxed font-normal">+52 (55) 4892-0294 (Lunes a Viernes de 9am a 6pm)</p>
              </div>
            </li>

            <li class="flex items-start gap-2.5">
              <Mail class="w-4.5 h-4.5 text-blue-655 mt-0.5 shrink-0" />
              <div class="space-y-0.5">
                <span class="font-bold text-slate-800">Correos directos</span>
                <p class="text-slate-500 leading-relaxed font-normal">ventas@electromart.com<br />soporte.tecnico@electromart.com</p>
              </div>
            </li>
          </ul>
        </div>

        <!-- Persisted Sent Messages Log (The Inbox simulation) -->
        <div class="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm space-y-4">
          <h3 class="text-sm font-bold text-slate-805 border-b border-slate-100 pb-2.5 flex items-center justify-between uppercase tracking-wide font-sans">
            <span>Buzón Enviado</span>
            <span class="text-[10px] bg-blue-50 border border-blue-100 text-blue-700 px-2.5 py-0.5 rounded-full font-bold font-sans">
              {{ storedMessages.length }} registrados
            </span>
          </h3>

          <div v-if="storedMessages.length === 0" id="no-logged-messages" class="text-center py-6 space-y-1">
            <MessageSquare class="w-7 h-7 text-slate-300 mx-auto" />
            <p class="text-[11px] font-bold text-slate-700">Sin mensajes registrados aún</p>
            <p class="text-[10px] text-slate-400 font-normal">Tus envíos del formulario se guardarán y desplegarán aquí en tiempo real.</p>
          </div>

          <div v-else class="space-y-3.5 max-h-56 overflow-y-auto pr-1">
            <div
              v-for="msg in storedMessages"
              :key="msg.id"
              class="p-3 bg-slate-50 rounded-xl border border-slate-200 hover:bg-slate-100/50 transition duration-200"
            >
              <div class="flex justify-between items-center mb-1">
                <span class="font-bold text-slate-800 font-sans text-[11px] truncate max-w-[155px]">
                  {{ msg.subject }}
                </span>
                <span class="text-[9px] text-slate-400 font-medium font-sans shrink-0">{{ msg.date }}</span>
              </div>
              <p class="text-[10px] text-slate-500 font-normal leading-relaxed truncate mb-1">
                {{ msg.message }}
              </p>
              <div class="flex justify-between text-[8px] tracking-wide font-bold text-slate-400 uppercase pt-1 border-t border-slate-150">
                <span>Remitente: {{ msg.name }}</span>
                <span class="text-blue-600 font-sans font-bold">Estado: Pendiente</span>
              </div>
            </div>
          </div>
        </div>
      </div>

    </section>

  </div>
</template>
