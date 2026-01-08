import Vue from 'vue';
import { Post, t } from '../../../utils';

export default Vue.component('codes', {
    data() {
        return {
            code: null,
            name: null
        }
    },
    methods: {
        validate() {
            let code = /^[1-9][-S][0-9][0-9]?[a-z|0-9]?$/;

            if (!this.name || !this.code) return false;
            if (!this.$parent.inRange(this.name)) return false;
            if (!code.test(this.code)) return false;

            return true;
        },
        async create() {
            if (!this.validate()) return this.$parent.errorNotification();

            const id = await Post('create:code', { code: { code: this.code, name: this.name } });

            if (!id) return this.$parent.chiefOnly();
            if (id === -1) return this.$parent.notify({ title: t('words.error'), text: t('codes.unique') });

            this.$parent.successNotification('codes', { code: this.code });
            return this.$parent.switchPage('dashboard');
        },
        t
    }
});
