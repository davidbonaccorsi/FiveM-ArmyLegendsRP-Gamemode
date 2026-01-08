import Vue from 'vue';

import Image from '../../../images/vehicle.png';
import { Post, parseStringified, formatDate, capitalizeFirstLetter, t } from '../../../utils';

export default Vue.component('vehicle', {
    props: {
        data: {
            type: Object,
            required: false,
            default: {}
        }
    },
    data() {
        return {
            defaultImage: Image,
            imageHovered: false,
            incidents: [],
            description: this.data.description,
            name: null,
            brand: null,
            category: null
        }
    },
    methods: {
        async search(name: string) {
            let items: any = await Post(`search:${name}_vehicle`, { 
                plate: this.data.plate
            });
            
            this[name] = items.map(item => parseStringified(item));
        },
        changeImage(plate: string) {
            this.$parent.confirmModal(async () => {
                let url = await this.$parent.photo();
                let success = await Post('update:vehicle_photo', { user_id: this.data.user_id, vehicle: this.data.vehicle, url });

                if (success) {
                    this.$parent.successNotification('vehicle');

                    setTimeout(async () => {
                        this.$parent.switchPage('vehicles')

                        await Post('mdt:toggle:nui', {
                            state: true,
                            page: {
                                name: 'vehicle',
                                data: {
                                    ...this.data,
                                    mdt_image: url
                                }
                            }
                        });
                    }, 500);
                }
            });
        },
        async changeDescription() {
            if (this.description.length < 1) return;

            let response: boolean = await Post(`update:vehicle`, { 
                description: this.description,
                user_id: this.data.user_id,
                vehicle: this.data.vehicle
            });

            if (response) {
                this.$parent.notify({
                    title: t('words.info'),
                    text: t('vehicle.changed'),
                    duration: 2500,
                    progress: 'auto'
                }, true);

                return this.$parent.switchPage('vehicles');
            }

            return this.$parent.errorNotification();
        },
        see(type: string, item: any) {
            this.$parent.confirmModal(() => this.$parent.switchPage(type, item), t('modal.see', { type }));
        },
        formatDate(date: string) {
            return formatDate(date);
        },
        t
    }
});
