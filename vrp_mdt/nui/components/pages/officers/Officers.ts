import Vue from 'vue';

import Data from '../../../types/cops';
import { Post, t } from '../../../utils';

export default Vue.component('officers', {
    data(): Data {
        return {
            cops: []
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
            let cops = await Post('search:officer');
            this.cops = cops
        },
        t
    }
});
