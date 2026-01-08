import Vue from 'vue';

import Data from '../../../types/incidents';
import Player from '../../../types/player';
import Fine from '../../../types/fines';
import { Vehicle } from '../../../types/vehicles';
import { Post, t } from '../../../utils';

export default Vue.component('incidents', {
    data(): Data {
        return {
            name: null,
            description: null,
            players: [],
            cops: [],
            vehicles: [],
            jails: [],
            jail_reduction: 0,
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

            const id = await Post('create:incident', { 
                incident: {
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
                            faction: player.userFaction
                        }
                    }),
                    targetId: this.players[0].id,
                    createdAt: Date.now(),
                    vehicles: this.vehicles,
                    jails: this.jails,
                    jail_reduction: this.jail_reduction || 0
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
        jail_reducted() {
            let months: number = this.jails.reduce((current, jail) => current + jail.time, 0);
            return `${(months - ((this.jail_reduction / 100) * months)).toFixed(2)} ${t('words.months')}`;
        }
    }
});
