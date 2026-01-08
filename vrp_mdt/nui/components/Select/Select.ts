import Vue from 'vue';

import { WarrantType } from '../../types/warrants';

export default Vue.component('mdt-select', {
    props: {
        options: {
            type: Array,
            required: true
        },
        variable: {
            type: String,
            required: true
        }
    },
    data() {
        return {
            selected: this.options.find((option: WarrantType) => option.hidden),
            open: false
        }
    },
    mounted() {
        this.$emit('input', this.selected);
    },
    watch: {
        selected() {
            this.switchValue(this.variable, this.selected.value);
        }
    },
    methods: {
        switchValue(path: string, value: string, target: any = this.$parent) {
            let keys = path.split('.');

            if (keys.length > 1) {
                target = target !== this.$parent ? target[keys[0]] : this.$parent[keys[0]];
                return this.switchValue(keys.slice(1).join('.'), value, target);
            }
                
            return target[path] = value;
        }
    },
    computed: {
        unselected() {
            return this.options.filter((option: WarrantType) => !option.hidden && option.value !== this.selected.value);
        }
    }
});
