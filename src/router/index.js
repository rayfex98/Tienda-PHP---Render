import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../components/HomeView.vue';
import CatalogView from '../components/CatalogView.vue';
import ProductDetailsView from '../components/ProductDetailsView.vue';
import AboutUsView from '../components/AboutUsView.vue';

const routes = [
  { path: '/', name: 'home', component: HomeView },
  { path: '/catalogo', name: 'catalog', component: CatalogView },
  { path: '/producto/:id', name: 'product-details', component: ProductDetailsView, props: true },
  { path: '/nosotros', name: 'about', component: AboutUsView }
];

export const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 };
  }
});
