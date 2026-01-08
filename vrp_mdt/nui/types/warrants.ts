import Player from './player';

export interface Warrant {
    id: number,
    citizenid: String,
    house: String,
    reason: String,
    done: Boolean,
    starting: String,
    createdAt: String
}

export interface WarrantType {
    value: String,
    label: String,
    hidden?: Boolean
}

export default interface Data {
    types: WarrantType[],
    type: String,
    reason: String,
    description: String,
    house?: any[],
    players: Player[],
    start_time?: String
}
