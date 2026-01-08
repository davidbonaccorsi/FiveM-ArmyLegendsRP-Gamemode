<template>
    <div id='fine'>
        <page-header :title='t("fine.title", { id: data.id })' :description='t("fine.description")' backable />

        <div class='page-content'>
            <div id='fine-grid'>
                <div id='container'>
                    <div class='header'>
                        <h1>{{ t("words.details") }}</h1>
                    </div>

                    <input class='dark' maxlength='50' type='text' :placeholder='t("words.name")' v-model.trim='name' @keyup.enter='change' />
                    <input class='dark' maxlength='7' type='text' :placeholder='t("words.amount")' v-model='amount' @input='numberOnly("amount")' @keyup.enter='change' />
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Fine.ts'></script>