import Vue from 'vue';

import Image from '../../../images/profile.jpg';
import Config from '../../../config.json';

import { Post, parseStringified, formatDate, capitalizeFirstLetter, t } from '../../../utils';

export default Vue.component('takeapel', {
    props: {
        data: {
            type: Object,
            required: false,
            default: {}
        }
    },
    data() {
        return {
            description: this.data.description,
            defaultImage: Image,
            imageHovered: false,
        }
    }, 
    methods: {
        see(type: string, item: any) {
            this.$parent.confirmModal(() => this.$parent.switchPage(type, item), t('modal.see', { type }));
        },
        async takecall(call: number) {
            const result = await Post(`mdt:take-call`,[call])
            if (result) {
                this.$parent.successNotification('takeapel');
                this.$parent.switchPage('calls');
            } else if (!result) {
                this.$parent.successNotification('apelpreluat');
                this.$parent.switchPage('calls');
            } else if (result == "offline") {
                this.$parent.successNotification('offline');
                this.$parent.switchPage('calls');
            };
        },
        async cancelcall(call: number) {
            const result = await Post(`mdt:calls-delete`,[call])
            if (result) {
                this.$parent.successNotification('succescancel');
                this.$parent.switchPage('calls');
            } else {
                this.$parent.successNotification('cancelcall');
                this.$parent.switchPage('calls');
            };
        },
        async requestbackup(call: number) {
            const result = await Post(`mdt:calls-requestbackup`,[call])
            if (result) {
                this.$parent.successNotification('requestbackup');
            } else {
                this.$parent.successNotification('cantrequestbackup');
                this.$parent.switchPage('calls');
            };
        },
        async requestparamedic(call: number) {
            const result = await Post(`mdt:calls-requestparamedic`,[call])
            if (result) {
                this.$parent.successNotification('requestparamedic');
            } else {
                this.$parent.successNotification('cantrequestparamedic');
                this.$parent.switchPage('calls');
            };
        },
        async setLocation(call: number) {
            let result = await Post(`mdt:calls-setlocation`, [call])
            if (result) {
                this.$parent.successNotification('setLocation');
            }
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
        capitalizeFirstLetter, t
    }
})