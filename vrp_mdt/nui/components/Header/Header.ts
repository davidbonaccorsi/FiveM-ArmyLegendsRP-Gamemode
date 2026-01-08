import Vue from 'vue';

export default Vue.component('page-header', {
    props: {
        title: {
            type: String,
            required: true
        },
        description: {
            type: String,
            required: true
        },
        backable: {
            type: Boolean,
            required: false,
            default: false
        }
    }
});
