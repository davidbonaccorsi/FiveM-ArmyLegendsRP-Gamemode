import Vue from 'vue';
import Verte from 'verte';
import Slider from 'vue-slider-component'
import 'vue-slider-component/theme/default.css'

export const VueSlider = Vue.component('VueSlider', Slider)
export const Color = Vue.component('verte', Verte);

export { default as Navigation } from './Navigation/Navigation.vue';
export { default as Modal } from './Modal/Modal.vue';
export { default as Header } from './Header/Header.vue';
export { default as Select } from './Select/Select.vue';
export { default as Autocomplete } from './Autocomplete/Autocomplete.vue';
export { default as List } from './List/List.vue';