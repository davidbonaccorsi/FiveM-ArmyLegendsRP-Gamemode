import Vue from 'vue';

import { Post, parseStringified, formatNumber, formatDate, t } from '../../../utils';
import Fine from '../../../types/fines';

export default Vue.component('evidence', {
    props: {
        data: {
            type: Object,
            required: false,
            default: {}
        }
    },
    data() {
        return {
            players: [],
            cops: [],
            vehicles: [],
        }
    },
    methods: {
        parse(text: string | string[]) {
            return typeof text == 'string' ? JSON.parse(text) : text;
        },
        async get(type: string, callback: string = 'search:citizen') {
            let list: string[] = this.parse(this.data[type]);
            let retval: any[] = [];

            for(let i = 0; i < list.length; i++) {
                let data = await Post(callback, { query: list[i] });
                retval[i] = parseStringified(data[0]);
            }

            return retval;
        },
        see(type: string, item: any) {
            this.$parent.confirmModal(() => this.$parent.switchPage(type, item), "Ce vrei sa faci cu acest Raport?");
        },
    },
    computed: {
        createdAt() {
            return formatDate(this.data.createdAt)
        }
    }
});
