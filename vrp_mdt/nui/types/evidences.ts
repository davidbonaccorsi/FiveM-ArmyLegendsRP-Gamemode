import Player from './player';

export interface Evidence {
    id: Number
    name: String,
    description: String,
    players: Object[],
    cops: Object[],
    vehicles: Object[],
    fines: Object[],
    createdAt?: String
}

export default interface Data {
    name: String,
    description: String,
    players: Player[],
    cops: Player[],
    fines: Fine[],
    fine_reduction: Number,
    options: Object
}
