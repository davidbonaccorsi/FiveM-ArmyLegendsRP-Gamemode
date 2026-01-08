<template>
    <div id='charge'>
        <page-header :title='t("charge.title", { id: data.id })' :description='t("charge.description")' backable />

        <div class='page-content'>
            <div id='fine-grid'>
                <div id='container'> 
                    <div class='header'>
                        <h1>{{ t("words.details") }}</h1>
                    </div>

                    <input class='dark' maxlength='50' type='text' :placeholder='t("words.name")' v-model.trim='name' @keyup.enter='change("name")' />
                    <input class='dark' maxlength='7' type='text' :placeholder='t("jail.time")' v-model='time' @input='numberOnly("time")' @keyup.enter='change("time")' />
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Jail.ts'></script>