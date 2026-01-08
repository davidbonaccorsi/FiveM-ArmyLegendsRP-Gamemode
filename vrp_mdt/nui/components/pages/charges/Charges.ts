import Vue from 'vue';

import { Post, t } from '../../../utils';

export default Vue.component('charges', {
    data() {
        return {
            name: null,
            time: null
        }
    },
    methods: {
        validate() {
            if (!this.name || !this.time || isNaN(this.time) || this.time <= 0) return false;
            if (!this.$parent.inRange(this.name)) return false;

            return true;
        },
        async create() {
            if (!this.validate()) return this.$parent.errorNotification();

            const id = await Post('create:jail', { jail: { name: this.name, time: this.time } });
            if (!id) return this.$parent.chiefOnly();

            if (id > 0) {
                this.$parent.successNotification('jail', { id });
                return this.$parent.switchPage('dashboard');
            }
        },
        numberOnly(type: string) {
            let value: any = this[type];
            let letters: string[] = value.split('');
            
            letters.forEach((letter, index) => {
                if (!/^\d+$/.test(letter))
                    this[type] = value.slice(0, index)
            });
        },
        t
    }
});
