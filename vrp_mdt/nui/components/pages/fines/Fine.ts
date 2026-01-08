import Vue from 'vue';
import { Post, t } from '../../../utils';

export default Vue.component('fine', {
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
            amount: this.data.amount
        }
    },
    methods: {
        async change() {
            let success = await Post('update:fine', {
                id: this.data.id,
                name: this.name,
                amount: this.amount
            });

            if (!success) return this.$parent.chiefOnly();

            this.$parent.successNotification('fine', { id: this.data.id });
            return this.$parent.switchPage('fines');
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
