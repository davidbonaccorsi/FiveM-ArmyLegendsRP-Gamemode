export interface Notification {
    title: String,
    text: String,
    position: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left' | 'bottom-center' | 'top-center',
    color?: 'primary' | 'success' | 'danger' | 'warning' | 'dark' | String,
    duration?: 'none' | Number,
    progress?: String,
    square?: Boolean,
    border?: Boolean,
    flat?: Boolean,
    loading?: Boolean,
    width?: String
}

export interface ModalButton {
    label: String,
    close?: Boolean,
    handler: (...args) => any
}

export interface Modal {
    opened: Boolean,
    data: {
        icon: String,
        title: String,
        description: String,
        buttons: ModalButton[]
    }
}

export interface HistoryItem {
    name: String,
    data: any
}

export default interface Data {
    opened: Boolean,
    currentPage: String,
    pages: Object[],
    history: HistoryItem[],
    data: any,
    modal: Modal
}
