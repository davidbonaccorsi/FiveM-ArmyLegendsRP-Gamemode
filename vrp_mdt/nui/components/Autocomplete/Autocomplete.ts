import Vue from 'vue';

import { Post, useDebouncedValue, replaceTemplate, parseStringified } from '../../utils';
import Config from '../../config.json';

export default Vue.component('mdt-autocomplete', {
    props: {
        identifier: {
            type: String,
            required: false,
            default: 'citizenid'
        },
        selected_template: {
            type: String,
            required: false,
            default: '{charinfo-firstname} {charinfo-lastname}'
        },
        suggested_template: {
            type: String,
            required: false,
            default: '{charinfo-firstname} {charinfo-lastname} ({citizenid})'
        },
        suggestion_url: {
            type: String,
            required: false,
            default: 'players'
        },
        max_selected: {
            type: Number,
            required: false,
            default: Config.MaxSelected
        },
        max_completed: {
            type: Number,
            required: false,
            default: Config.MaxAutocomplete
        },
        tag_icon: {
            type: String,
            required: false,
            default: 'fa-solid fa-user-lock'
        },
        placeholder: {
            type: String,
            required: true
        },
        variable: {
            type: String,
            required: true
        }
    },
    data() {
        return {
            selected: this.$parent[this.variable],
            suggested: [],
            query: null
        }
    },
    watch: {
        selected() {
            this.switchValue(this.variable, this.selected);
        }
    },
    methods: {
        suggestion() {
            useDebouncedValue(this.query, async (value: string) => {
                if (!value || !value.trim()) return this.suggested = [];

                if (this.selected.length < Config.MaxAutocomplete) {
                    let response: any[] = await Post(`suggested:${this.suggestion_url}`, { 
                        query: value,
                        max: Config.MaxAutocomplete 
                    });
    
                    return this.suggested = response.map(item => parseStringified(item));
                }

                return this.suggested = [];
            });
        },
        add(target: any) {
            this.suggested = [];
            this.query = null;

            // let exists = this.selected.some((value: any) => value[this.identifier] == target[this.identifier]);
            // if (exists || this.selected.length >= this.max_selected) return;

            this.selected.push(target);
        },
        remove(target: any) {
            this.suggested = [];

            let key = this.identifier;
            let included = this.selected.find((value: any) => value[key] == target[key]);
            if (!included) return;

            let filtered = this.selected.filter((value: any) => value[key] !== target[key]);
            this.selected = filtered;
        },
        template(type: string, element: Object) {
            return replaceTemplate(type, element, this);
        },
        switchValue(path: string, value: string, target: any = this.$parent) {
            let keys = path.split('.');

            if (keys.length > 1) {
                target = target !== this.$parent ? target[keys[0]] : this.$parent[keys[0]];
                return this.switchValue(keys.slice(1).join('.'), value, target);
            }
                
            return target[path] = value;
        }
    }
});
