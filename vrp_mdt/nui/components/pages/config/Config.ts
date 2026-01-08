import Vue from 'vue';

import Data from '../../../types/config';
import Config from '../../../config.json';

import { t } from '../../../utils';

export default Vue.component('config', {
    data(): Data {
        return {
            colors: [],
            contrast: localStorage.getItem('contrast') || Config.Colors['contrast'],
            main: localStorage.getItem('main') || Config.Colors['main'],
            secondary: localStorage.getItem('secondary') || Config.Colors['secondary'],
            highlight: localStorage.getItem('highlight') || Config.Colors['highlight'],
            text: localStorage.getItem('text') || Config.Colors['text'],
            light: localStorage.getItem('light') || Config.Colors['light'],
            mainlight: localStorage.getItem('mainlight') || Config.Colors['mainlight'],
            secondarylight: localStorage.getItem('secondarylight') || Config.Colors['secondarylight'],
            textdark: localStorage.getItem('textdark') || Config.Colors['textdark']
        }
    },
    created() {
        let list: string[] = Object.keys(Config.Colors);

        this.colors = list;
        this.colors.forEach(color => this.watch(color));
    },
    methods: {
        watch(type: string) {
            this.$watch(type, (value: string) => {
                localStorage.setItem(type, value);
                this.$parent.setupColors();
            });
        },
        getColor(type: string) {
            return this[type];
        },
        changeColor(color: string, variable: string) {
            this[variable] = color;
        },
        reset() {
            this.$parent.confirmModal(() => {
                this.colors.forEach(color => {
                    this.changeColor(Config.Colors[color], color);
                });
            }, t('config.confirm'));
        },
        t
    }
});
