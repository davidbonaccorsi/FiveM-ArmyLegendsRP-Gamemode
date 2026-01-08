export interface Vehicle {
    id: number,
    plate: string
}

export default interface Data {
    query: String,
    vehicles: Vehicle[]
}
