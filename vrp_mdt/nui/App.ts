import Vue from 'vue';

import { Notification, default as Data } from './types/data';

import Config from './config.json';
import Sound from './sounds/info.ogg';

import * as Pages from './components/pages/index';
import * as Components from './components/index';
import * as Utils from './utils';

export default Vue.extend({
    data(): Data {
        return {
            opened: false,
            currentPage: 'dashboard',
            data: null,
            pages: Config.Pages,
            history: [],
            modal: {
                opened: false,
                data: {
                    icon: null,
                    title: null,
                    description: null,
                    buttons: []
                }
            }
        }
    },
    components: {
        ...Components,
        ...Pages
    },
    async mounted() {
        this.setupColors();
        
        this.listenMessage();
        this.listenKeyboard();
    },
    destroyed() {
        window.removeEventListener('message', this.messageListener);
        window.removeEventListener('keydown', this.closeListener);
    },
    watch: {
        currentPage() {
            this.closeModal();
        }
    },
    methods: {
        async OPEN() {
            this.opened = true;
        },
        
        CLOSE() {
            this.opened = false;
            this.closeModal();
        },

        UPDATE_ALERTS() {
            if (Config.AlertNotification.Enabled) {
                if (this.opened || Config.AlertNotification.WhileClosed && !this.opened) {
                    return this.notify({
                        title: Utils.t('alert.new'),
                        text: Utils.t('alert.description'),
                        duration: 5000,
                        color: 'danger',
                        progress: 'auto'
                    }, true);
                }
            }
        },

        SWITCH(args: any) {
            this.switchPage(args.name, args.data);
        },

        // Methods

        switchPage(page: string, data: any) {
            if (this.currentPage === page) return;
            
            this.history.push({
                name: this.currentPage,
                data: this.data
            })

            this.currentPage = page;
            this.data = data;
        },

        navigateBack() {
            if (this.history.length <= 0) return;
            let last = this.history[this.history.length - 1];
            this.switchPage(last.name, last.data);
            this.history = this.history.slice(0, this.history.length - 1);
        },

        async close() {
            await Utils.Post('mdt:close');
        },

        // Modals

        openModal(icon, title, description, buttons = []) {
            this.modal.opened = true;
            this.modal.data = { icon, title, description, buttons };
        },
        
        closeModal() {
            this.modal.opened = false;
            this.modal.data = {};
        },

        confirmModal(handler: (...args: any) => void, label: string = Utils.t('modal.confirm')) {
            this.closeModal();

            setTimeout(() => {
                this.openModal('fa-solid fa-clipboard-question', Utils.t('words.confirm'), label, [
                    { 
                        label: Utils.t('words.confirm'), 
                        handler: () => {
                            handler();
                            this.closeModal();
                        } 
                    }, 
                    { label: Utils.t('words.cancel'), close: true, handler: this.closeModal }
                ]);
            }, 100);
        },

        successModal(resolve: (...args: any) => any, description: string) {
            this.closeModal();

            setTimeout(() => {
                let response = resolve();

                if (response)
                    this.openModal('fa-solid fa-circle-check', Utils.t('words.success'), description, [{ label: Utils.t('words.close'), handler: this.closeModal } ]);
                else 
                    this.openModal('fa-solid fa-triangle-exclamation', Utils.t('words.error'), Utils.t('modal.error'), [
                        {  label: Utils.t('words.close'), close: true, handler: this.closeModal } 
                    ]);
            }, 100);
        },

        // Notifications

        notify(data: Notification, sound?: Boolean) {
            let notification: Notification = { ...data, position: 'top-right' };
            
            if (sound) {
                let audio = new Audio(Sound);
                audio.play();
            }
            
            this.$vs.notification(notification);
        },

        errorNotification() {
            this.notify({
                title: Utils.t('words.error'),
                text: Utils.t('notification.error'),
                duration: 5000,
                progress: 'auto'
            });
        },

        successNotification(target: string, data?: Object) {
            this.notify({
                title: Utils.t(`${target}.notification_title`),
                text: Utils.t(`${target}.notification_description`, data),
                duration: 3000,
                progress: 'auto'
            }, true);
        },

        chiefOnly() {
            return this.notify({
                title: Utils.t('words.error'),
                text: Utils.t('notification.chief_only')
            });
        },

        // Photo

        async photo() {
            await this.close();

            let url = await Utils.Post('take:photo');
            return url;
        },

        // Utils

        inRange(text: string, min: number = 3, max: number = 500) {
            return text.length >= min && text.length <= max;
        },

        // Listeners
        
        listenMessage() {
            this.messageListener = (event: MessageEvent) => {
                let item: any = event.data;
                if (!item || !item.action) return;
    
                let actionFunction = this[item.action];
                if (actionFunction) return actionFunction(item.args);
            }
    
            window.addEventListener('message', this.messageListener);
        },

        listenKeyboard() {
            this.closeListener = (event: KeyboardEvent) => {
                let key = event.key.toLowerCase();
                if (key !== 'escape') return;
    
                if (this.modal.opened) 
                    this.closeModal();
                else 
                    this.close();
            }
    
            window.addEventListener('keydown', this.closeListener);
        },

        // Colors
        
        setColor(name: string, value: string) {
            let element = document.documentElement;
            element.style.setProperty(name, value);
        },

        setupColors() {
            let keys: string[] = Object.keys(Config.Colors);

            keys.forEach(key => {
                let value: string = localStorage.getItem(key);
                this.setColor(`--${key}`, value || Config.Colors[key]);
            });
        }
    }
});
