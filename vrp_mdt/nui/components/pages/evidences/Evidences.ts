import Vue from 'vue';

import Data from '../../../types/evidences';
import Player from '../../../types/player';
import Fine from '../../../types/fines';
import { Post, t } from '../../../utils';

export default Vue.component('evidences', {
    data(): Data {
        return {
            name: null,
            description: null,
            players: [],
            cops: [],
            fines: [],
            fine_reduction: 0,
            options: {
                tooltip: 'none'
            }
        }
    },
    methods: {
        async validate() {
            if (!this.name || !this.description) return false;
            if (this.name.length < 3 || !this.$parent.inRange(this.name)) return false;
            if (this.players.length <= 0) return false;

            return true;
        },
        async create() {
            let validation = await this.validate();
            if (!validation) return this.$parent.errorNotification();

            const id = await Post('create:amenda', {
                amenda: {
                    name: this.name,
                    description: this.description,
                    players: this.players.map((player) => {
                        return {
                            id: player.id,
                            image: player.image,
                            description: player.description,
                            userIdentity: player.userIdentity,
                        }
                    }),
                    cops: this.cops.map((player) => {
                        return {
                            id: player.id,
                            image: player.image,
                            description: player.description,
                            userIdentity: player.userIdentity,
                            faction: player.userFaction,
                        }
                    }),
                    targetId: this.players[0].id,
                    createdAt: Date.now(),
                    fines: this.fines.map((fine: Fine) => fine),
                    fine_reduction: this.fine_reduction || 0
                }
            });
            
            if (id > 0) {
                this.$parent.successNotification('incidents', { id });
                return this.$parent.switchPage('dashboard');
            }            
        },
        numberOnly(type: string) {
            let value: any = this[type];
            let letters: string[] = value.split('');
            
            letters.forEach((letter, index) => {
                if (!/^\d+$/.test(letter))
                    this[type] = value.slice(0, index)
            });
        },
        t
    },
    computed: {
        fine_reducted() {
            let fine: number = this.fines.reduce((current, fine) => current + fine.amount, 0);
            return `${(fine - ((this.fine_reduction / 100) * fine)).toFixed(2)}$`;
        },
    }
});
