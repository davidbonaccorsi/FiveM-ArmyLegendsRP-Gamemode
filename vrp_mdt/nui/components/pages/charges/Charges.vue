<template>
    <div id='charges'>
        <page-header :title='t("jail.title")' :description='t("jail.description")' />
        <div class='page-content'>
            <list name='jail' :label='t("jail.search")' item_element='fa-solid fa-folder-open' main_template='{name}' :secondary_template='"=time= " + t("words.months")' />

            <div class='create-container'>
                <div class='content-header'>
                    <h1>{{ t('jail.create') }}</h1>

                    <form @submit.prevent='create' autocomplete='off'>
                        <input maxlength='50' type='text' :placeholder='t("words.name")' v-model='name' />
                        <input maxlength='3' type='text' :placeholder='t("jail.time")' v-model='time' @input='numberOnly("time")' />

                        <div class='form-footer'>
                            <div class='submit-button' @click='create'>
                                {{ t('jail.button') }}
                            </div>
                        </div>
                    </form>
                </div>            
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Charges.ts'></script>