import Vue from 'vue';

import Fine from '../../../types/fines';
import { Post, t } from '../../../utils';

export default Vue.component('fines', {
    data(): Fine {
        return {
            id: 0,
            code: null,
            name: null,
            amount: null,
            createdAt: null
        }
    },
    methods: {
        validate() {
            let code = /^[1-9][-S][0-9][0-9]?[a-z|0-9]?$/;

            if (!this.name || !this.code || !this.amount) return false;
            if (!this.$parent.inRange(this.name)) return false;
            if (!code.test(this.code)) return false;

            return true;
        },
        async create() {
            if (!this.validate()) return this.$parent.errorNotification();

            const id = await Post('create:fine', { fine: { code: this.code, name: this.name, amount: this.amount } });
            if (!id) return this.$parent.chiefOnly();
            if (id === -1) return this.$parent.notify({ title: t('words.error'), text: t('codes.unique') });

            this.$parent.successNotification('fines', { id });
            return this.$parent.switchPage('dashboard');
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