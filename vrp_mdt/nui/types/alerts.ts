export interface Alert {
    id: number,
    info: {
        label: string,
        description: string,
        coords: string,
        streetLabel: string
    }
}

export default interface Data {
    alerts: Alert[]
}
