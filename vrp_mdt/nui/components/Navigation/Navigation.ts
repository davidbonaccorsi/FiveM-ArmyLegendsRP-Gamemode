import Vue from 'vue';

import { t } from '../../utils';
import Logo from '../../images/logo.png';

export default Vue.component('navigation', {
    data() {
        return {
            logo: Logo
        }
    },
    computed: {
        exit() {
            return t('words.exit')
        }
    }
});
