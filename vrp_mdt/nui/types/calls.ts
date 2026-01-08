export interface Call {
label: any
description: any
[x: string]: any
    id: number,
    info: {
        label: string,
        description: string,
        coords: string,
        streetLabel: string
    }
}

export default interface Data {
    calls: Call[]
}
