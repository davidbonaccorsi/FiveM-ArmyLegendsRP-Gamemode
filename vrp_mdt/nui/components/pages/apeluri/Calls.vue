<template>
    <div id='calls'>
        <page-header :title='t("calls.title")' :description='t("calls.description")' />
        <div class='page-content'>
            <div id='calls-grid' v-if='calls.length'>
                <div class='call' v-for='(call, index) in calls' @click='take(index + 1)'>
                    <div class='details'>
                        <h1>{{ call.info.firstname + ' ' + call.info.name}} #{{ index + 1 }}</h1>
                        <p>{{ call.info.reason }}</p>
                    </div>
                    <div class='icon'>
                        <i class="fa-solid fa-phone"></i>
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

<script lang='ts' src='./Calls.ts'></script>
