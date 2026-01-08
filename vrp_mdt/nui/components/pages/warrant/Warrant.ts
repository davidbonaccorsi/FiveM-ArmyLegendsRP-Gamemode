import Vue from 'vue';

import { capitalizeFirstLetter, Post, parseStringified, formatDate, t } from '../../../utils';

export default Vue.component('warrant', {
    props: {
        data: {
            type: Object,
            required: false,
            default: {}
        }
    },
    methods: {
        parse(text: string | string[]) {
            return typeof text == 'string' ? JSON.parse(text) : text;
        },
        finish() {
            this.$parent.confirmModal(async () => {
                await Post('finish:warrant', { id: this.data.id });

                this.$parent.successNotification('warrant');
                return this.$parent.switchPage('warrants');
            })
        },
        see(type: string, item: any) {
            this.$parent.confirmModal(() => this.$parent.switchPage(type, item), t('modal.see', { type }));
        },
        t
    },
    computed: {
        type() {
            return capitalizeFirstLetter(this.data.wtype)
        },
        starting() {
            return formatDate(this.data.start_time)
        },
        created() {
            return formatDate(this.data.createdAt)
        }
    }
});
