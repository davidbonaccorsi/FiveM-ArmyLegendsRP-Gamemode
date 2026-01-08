<template>
    <div id='list-grid'>
        <div class='content-header'>
            <h1>{{ label }}</h1>
            <form @submit.prevent='refresh' class='input'>
                <input type='text' :placeholder='t("words.search")' v-model='query' @input='refresh' />
            </form>
        </div>

        <div class='list-results' v-if='items.length'>
            <div class='incident' v-for='item in items' @click='manage(item)'>
                <div class='icon'>
                    <i :class='item_element'></i>
                    <h1>{{ template('main', item) }}</h1>
                </div>
                <p>{{ template('secondary', item) }}</p>
            </div>
        </div>
        
        <div v-else class='not-found'>
            <i class='fa-regular fa-folder-open'></i>
            <h1>{{ t('list.no_results') }}</h1>
        </div>
    </div>
</template>

<script lang='ts' src='./List.ts'></script>