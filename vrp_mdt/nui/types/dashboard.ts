import Player from './player';
import Fine from './fines';

interface Message {
    id: Number,
    image: String,
    phone: String,
    author: String,
    rank: String,
    content: String,
    createdAt?: String
}

export default interface Data {
    image: ImageData,
    player: Player,
    message: String,
    messages: Message[],
    fines: Fine[],
    codes: Object[],
    alerts: Number,
    medics: Number,
    cops: Number
}