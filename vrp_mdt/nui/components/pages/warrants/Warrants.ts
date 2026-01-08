import Vue from 'vue';

import Data from '../../../types/warrants';
import Player from '../../../types/player';
import { Post, t } from '../../../utils';

export default Vue.component('warrants', {
    data(): Data {
        return {
            type: null,
            reason: null,
            description: null,
            house: [],
            players: [],
            start_time: null,
            types: [
                { value: "default", label: t('warrants.type'), hidden: true },
                { value: "search", label: t('warrants.search_type') }, 
                { value: "arrest", label: t('warrants.arrest_type') }
            ]
        }
    },
    methods: {
        validate() {
            if (!this.reason || !this.description) return false;
            if (!this.$parent.inRange(this.reason)) return false;
            if (this.players.length <= 0) return false;
            if (this.players.length > 1) return false;
            
            return true;
        },
        async create() {
            if (!this.validate()) return this.$parent.errorNotification();

            const id = await Post('create:warrant', { 
                warrant: {
                    reason: this.reason,
                    description: this.description,
                    createdAt: Date.now(),
                    target: this.players[0].id,
                    userIdentity: this.players[0].userIdentity,
                    players: this.players.map((player) => {
                        return {
                            id: player.id,
                            image: player.image,
                            description: player.description,
                            userIdentity: player.userIdentity,
                        }
                    }),
                }
            });

            if (id > 0) {
                this.$parent.successNotification('warrants', { id });
                return this.$parent.switchPage('dashboard');
            }
        },
        setStarting() {
            if (!/^\d+$/.test(this.start_time))
                this.start_time = this.start_time.slice(0, -1);
        },
        t
    }
});
