import Vue from 'vue';

import Data from '../../../types/calls';
import { Post, t } from '../../../utils';

export default Vue.component('calls', {
    data(): Data {
        return {
            calls: []
        }
    },
    async mounted() {
        await this.update();
        window.addEventListener('message', this.listener);
    },
    destroyed() {
        window.removeEventListener('message', this.listener);
    },
    methods: {
        async update() {
            let data = await Post('mdt:update-calls');
            this.calls = data
        },
        listener(event: MessageEvent) {
            if (event.data.act === 'update_calls') {
                this.calls = event.data.calls
            }
        },
        async take(id:number) {
            let item: any = await Post(`mdt:search-call`, [id]);
            this.$parent.switchPage("takeapel", item);
        },
        t
    }
});

