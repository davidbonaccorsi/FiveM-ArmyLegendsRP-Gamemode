
import Player from './player';

import Fine from './fines';
import { Vehicle } from './vehicles';

export interface Incident {
    id: Number
    name: String,
    description: String,
    players: Object[],
    cops: Object[],
    vehicles: Object[],
    createdAt?: String
}

export default interface Data {
    name: String,
    description: String,
    players: Player[],
    cops: Player[],
    vehicles: Vehicle[],
    jails: any[],
    jail_reduction: Number,
    options: Object
}
