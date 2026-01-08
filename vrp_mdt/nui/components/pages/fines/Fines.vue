<template>
    <div id='fines'>
        <page-header :title='t("fines.title")' :description='t("fines.description")' />

        <div class='page-content'>
            <list name='fine' :label='t("fines.search")' item_element='fa-solid fa-money-bills' main_template='{name}' secondary_template='{code}' />

            <div class='create-container'>
                <div class='content-header'>
                    <h1>{{ t("fines.create") }}</h1>

                    <form @submit.prevent='create' autocomplete='off'>
                        <input maxlength='120' type='text' :placeholder='t("words.name")' v-model='name' />
                        <input maxlength='5' type='text' :placeholder='t("words.code_format")' v-model='code' />
                        <input maxlength='7' type='text' placeholder='Suma' v-model='amount' @input='numberOnly("amount")' />

                        <div class='form-footer'>
                            <div class='submit-button' @click='create'>
                                {{ t("fines.create") }}
                            </div>
                        </div>
                    </form>
                </div>            
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Fines.ts'></script>