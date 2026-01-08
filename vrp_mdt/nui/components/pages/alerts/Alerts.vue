<template>
    <div id='alerts'>
        <page-header :title='t("alerts.title")' :description='t("alerts.description")' />
        <div class='page-content'>
            <div id='alerts-grid' v-if='alerts.length'>
                <div class='alert' v-for='(alert, index) in alerts' @click='take(index, alert)'>
                    <div class='details'>
                        <h1>({{ index + 1 }}) {{ alert.info.label }}</h1>
                        <p>{{ alert.info.description }}</p>
                        <p>{{ alert.info.streetLabel }}</p>
                    </div>
                    <div class='icon'>
                        <i class='fas fa-street-view'></i>
                    </div>
                </div>
            </div>
                    
            <div v-else class='not-found'>
                <i class='fa-regular fa-bell'></i>
                <h1>{{ t('list.no_results') }}</h1>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Alerts.ts'></script>