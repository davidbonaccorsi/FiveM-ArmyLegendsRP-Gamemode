import Vue from 'vue';

import { Alert, default as Data } from '../../../types/alerts';
import { Post, t } from '../../../utils';

export default Vue.component('alerts', {
    data(): Data {
        return {
            alerts: []
        }
    },
    async mounted() {
        await this.update();

        this.listener = (event: MessageEvent) => {
            if (event.data.action === 'UPDATE_ALERTS') {
                let alerts = event.data.args;
                this.alerts = alerts;
            }
        };

        window.addEventListener('message', this.listener);
    },
    destroyed() {
        window.removeEventListener('message', this.listener);
    },
    methods: {
        async update() {
            let alerts = await Post('update:alerts');
            this.alerts = alerts;
        },
        async take(id: number, alert: Alert) {
            this.$parent.confirmModal(() => {
                Post('take:alert', { id, alert });
                
                this.$parent.close();
                this.$parent.notify({
                    title: t('alert.label', { id: id + 1 }),
                    text: t('alert.take', { id: id + 1 }),
                    duration: 5000,
                    progress: 'auto'
                }, true);
            });
        },
        t
    }
});
