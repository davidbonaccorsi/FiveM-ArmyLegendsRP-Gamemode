import Vue from 'vue';

import { Post, useDebouncedValue, replaceTemplate, capitalizeFirstLetter, parseStringified, t } from '../../utils';
import Config from '../../config.json';

export default Vue.component('list', {
    props: {
        name: {
            type: String,
            required: true
        },
        label: {
            type: String,
            required: true
        },
        item_element: {
            type: String,
            required: false,
            default: 'fa-solid fa-folder'
        },
        main_template: {
            type: String,
            required: true
        },
        secondary_template: {
            type: String,
            required: false,
            default: '{name} (~createdAt~)'
        },
        interactable: {
            type: Boolean,
            required: false,
            default: true
        },
        itemClick: {
            type: Function,
            required: false,
            default: null
        },
        delete: {
            type: Boolean,
            required: false,
            default: true
        }
    },
    data() {
        return {
            query: null,
            items: []
        }
    },
    mounted() {
        if(Config.ShowResultsMounted) 
            return this.refresh();
    },
    methods: {
        refresh() {
            useDebouncedValue(this.query || '', async (value: string) => {
                let items: any = await Post(`search:${this.name}`, { 
                    query: value,
                    max: Config.MaxPerRequest
                });

                this.set(items);
            });
        },
        set(data: any[]) {
            let items: any[] = data.map(item => parseStringified(item));

            this.items = items;
        },
        async remove(item: any) {
            let response: boolean = await Post(`delete:${this.name}`, { id: item.id });
            this.$parent.$parent.successModal(() => response, t('modal.deleted', { name: t(`words.${this.name}`) }));
            if (response) return this.refresh();
        },
        manage(item: any) {
            if (!this.interactable) {
                if (!this.itemClick) return;
                return this.itemClick(item);
            }

            let parent = this.$parent.$parent; 
            this.$parent.$parent.data = item;
            
            if (this.delete) {
                return parent.openModal('fa-solid fa-shield-halved', capitalizeFirstLetter(t(`words.${this.name}`)), t('modal.choose', { name: t(`words.${this.name}`) }), [
                    { 
                        label: t('words.view'), 
                        handler: () => parent.switchPage(this.name, item) 
                    }, 
                    { 
                        label: t('words.delete'), 
                        close: true, 
                        handler: () => parent.confirmModal(() =>
                            parent.successModal(async () => await this.remove(item), t('modal.delete', { name: this.name }))
                        )
                    }
                ]);
            }

            return parent.switchPage(this.name, item);
        },
        template(type: string, element: Object) {
            return replaceTemplate(type, element, this);
        },
        t
    }
});
