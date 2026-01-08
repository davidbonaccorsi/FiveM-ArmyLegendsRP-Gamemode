import Vue from 'vue';

import Image from '../../../images/profile.jpg';
import Config from '../../../config.json';

import { Post, parseStringified, formatDate, capitalizeFirstLetter, t } from '../../../utils';

export default Vue.component('citizen', {
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
            amenda: [],
            caziere: [],
            vehicles: [],
            description: this.data.description,
        }
    },
    mounted() {
        let items = ['caziere', 'incidents', 'amenda', 'vehicles'];
        items.forEach(async item => await this.search(item));
    },
    methods: {
        async search(name: string) {
            let items: any = await Post(`search:${name}_citizen`, { 
                id: this.data.id
            });

            this[name] = items.map(item => parseStringified(item));
        },
        changeImage(id: string) {
            this.$parent.confirmModal(async () => {
                let url = await this.$parent.photo();
                let success = await Post('update:photo', { id, url });
                
                if (success) {
                    this.$parent.notify({
                        title: t('citizen.photo_changed'),
                        text: t('citizen.photo_changed_description'),
                        duration: 4000,
                        progress: 'auto'
                    }, true);
                    
                    setTimeout(async () => {
                        this.$parent.switchPage('dashboard')

                        await Post('mdt:toggle:nui', {
                            state: true,
                            page: {
                                name: 'citizen',
                                data: {
                                    ...this.data,
                                    image: url
                                }
                            }
                        });
                    }, 500);
                }
            });
        },
        see(type: string, item: any) {
            this.$parent.confirmModal(() => this.$parent.switchPage(type, item), t('modal.see', { type }));
        },
        getLabel(name: string) {
            let spaced: string = name.replace(/([A-Z]|[a-z])(\d)/g, '$1 $2');
            return capitalizeFirstLetter(spaced, true);
        },
        formatDate(date: string) {
            return formatDate(date);
        },
        numberOnly(type: string) {
            let value: any = this[type];
            let letters: string[] = value.split('');
            
            letters.forEach((letter, index) => {
                if (!/^\d+$/.test(letter))
                    this[type] = value.slice(0, index)
            });
        },
        async change(type: string) {
            let value: any = this[type];
            if (value.length < 1) return;

            let response: boolean = await Post(`update:citizen`, { 
                description: value,
                id: this.data.id
            });

            if (!response) return this.$parent.errorNotification();

            if (response) {
                this.$parent.notify({
                    title: t('words.info'),
                    text: t('citizen.data_success'),
                    duration: 2500,
                    progress: 'auto'
                }, true);

                return this.$parent.switchPage('citizens');
            }
        },
        capitalizeFirstLetter, t
    }
});