import Config from './config.json';

export const Post = async (url: string, data: Object = {}) => {
    const response = await fetch(`https://vrp/${url}`, {
        method: 'POST',
        mode: 'no-cors',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });

    return await response.json();
}

export const capitalizeFirstLetter = (string: string, every: boolean = false) => {
    const capitalizeWord = w => w.charAt(0).toUpperCase() + w.slice(1);
    if (every) return string.split(' ').map(capitalizeWord).join(' ');
    return capitalizeWord(string);
}

export const formatDate = (date: string) => new Date(parseInt(date)).toLocaleString(Config.Locale);
export const formatNumber = (value: number) => new Intl.NumberFormat(Config.Locale).format(value);
export const isObject = (object: any) => object != null && typeof object === 'object';

export const parseStringified = (target: Object) => {
    let keys = Object.keys(target);
    let object = {};

    keys.forEach(key => {
        let value = target[key];
        let regex = new RegExp(`\{(.*?)\}`);
        object[key] = regex.test(value) ? JSON.parse(value) : value;
    });

    return object;
}

export const replaceTemplate = (type: string, element: Object, object: Object) => {
    let template = object[`${type}_template`];
    let keys = Object.keys(element);
    
    keys.forEach(key => {
        let value = element[key];
        let string = new RegExp(`{${key}}`, 'g');
        let digits = new RegExp(`=${key}=`, 'g');
        let date = new RegExp(`~${key}~`, 'g');

        if (isObject(value)) {
            let replacement = template.split('-').slice(1);
            let array = replacement.map(w => w.slice(0, w.indexOf('}')))
            
            array.forEach(w => {
                string = new RegExp(`{${key}-${w}}`, 'g');
                template = template.replace(string, value[w]);
            });
        }

        template = template.replace(string, value)
            .replace(digits, formatNumber(value))
            .replace(date, formatDate(value));
    });
    
    return template;
}

const getKey = (dir: string[], store: Object) => {
    if (dir.length === 1) return store[dir[0]]; 
    
    if (dir.length > 1) {
        let text: string = store[dir[0]];
        if (!text) return `Invalid value: ${dir}`;
        return getKey(dir.slice(1), text);
    }
}

const replaceAll = (text: string, map: Object = {}) => {
    const replaceThis = (query: string, replacement: any) => text.replace(new RegExp(query, 'g'), replacement);
    for (const key in map) text = replaceThis(`{{${key}}}`, map[key]);
    return text;
}

export const t = (dir: string, keys: Object = {}) => {
    let text: string = getKey(dir.split('.'), Config.Messages);
    return replaceAll(text, keys);
}

export const debounce = (callback: (...args: any) => void, delay: number = 200) => {
    let timeout;

    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
            callback(...args);
        }, delay);
    }
}

export const useDebouncedValue = debounce((text: string, callback: (...args: any) => void) => callback(text), 300);
