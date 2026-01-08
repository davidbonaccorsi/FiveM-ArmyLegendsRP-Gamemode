<template>
    <div id='officers'>
        <page-header :title='t("officers.title")' :description='t("officers.description")' />

        <div class='page-content'>
            <div id='officers-grid' v-if='cops.length'>
                <div class='officer' v-for='(cop, index) in cops'>
                    <div class='details'>
                        <h1>{{ cop.firstname }} {{ cop.lastname }}</h1>
                        <p>Grad: {{ cop.rank }}</p>
                        <p>ID: {{ cop.user_id }}</p>
                    </div>
                    <div class='icon'>
                        <i class='fa-solid fa-user-shield'></i>
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

<script lang='ts' src='./Officers.ts'></script>