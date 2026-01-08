import Vue from 'vue';
import { Post, t } from '../../../utils';

export default Vue.component('jail', {
    props: {
        data: {
            type: Object,
            required: false,
            default: {}
        }
    },
    data() {
        return {
            name: this.data.name,
            time: this.data.time
        }
    },
    methods: {
        async change() {
            let success = await Post('update:jail', {
                id: this.data.id,
                name: this.name,
                time: this.time
            });

            if (!success) return this.$parent.chiefOnly();

            this.$parent.successNotification('charge', { id: this.data.id });
            return this.$parent.switchPage('charges');
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
