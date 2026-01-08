import Vue from 'vue';
import Vuesax from 'vuesax';

import App from './App.vue';

import './index.scss';

import 'vuesax/dist/vuesax.css';
import 'verte/dist/verte.css';

document.body.classList.add('darken');
document.body.setAttribute('vs-theme', 'dark');

Vue.use(Vuesax);

export const instance = new Vue({
    el: '#app',
    render: h => h(App)
});
