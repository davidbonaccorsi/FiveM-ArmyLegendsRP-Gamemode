import Vue from 'vue';

import Data from '../../../types/dashboard';
import Image from '../../../images/profile.jpg';
import { Post, parseStringified, t } from '../../../utils';

export default Vue.component('dashboard', {
    data(): Data {
        return {
            image: Image,
            player: {
                id: null,
                firstname: null,
                name: null,
                jobRank: null,
                phone: null,
            },
            message: null,
            messages: [],
            fines: [],
            codes: [],
            alerts: 0,
            medics: 0,
            cops: 0
        }
    },
    mounted() {
        this.setMessages();

        this.listener = async (event: MessageEvent) => {
            switch(event.data.action) {
                case 'OPEN':
                    await this.update();
                    break;
                case 'ADD_MESSAGE':
                    this.messages.push(event.data.args);
                    break;
                case 'SET_MESSAGES':
                    this.messages = event.data.args;
                    break;
            }
        };

        window.addEventListener('message', this.listener);
    },
    async created() {
        await this.update();
    },
    destroyed() {
        window.removeEventListener('message', this.listener);
    },
    methods: {
        async update() {
            let data = await Post('update:dashboard');

            await this.updatePlayer(data.player);
            await this.updateFines();
            await this.updateCodes();

            this.updateStatistics(data.stats);
        },
        async updatePlayer(data: any) {
            this.player.firstname = data.firstname;
            this.player.name = data.name;
            this.player.jobRank = data.jobRank;
            this.player.phone = data.phone;
        },
        updateStatistics(data: any) {
            this.alerts = parseInt(data.alerts);
            this.medics = parseInt(data.medics);
            this.cops = parseInt(data.cops);
        },
        async updateFines() {
            let items: any = await Post('search:fine', { query: '', max: 15 });
            this.fines = items.map(item => parseStringified(item));
        },
        async updateCodes() {
            this.codes = await Post('search:code');
        },
        async setMessages() {
            let data = await Post('chat:set-messages');

            this.messages = data
        },
        async sendMessage() {
            if (!this.message || !this.message.length) return;

            await Post('chat:message', {
                id: Date.now(),
                content: this.message,
                createdAt: Date.now()
            });

            this.message = null;
        },
        t
    }
});
