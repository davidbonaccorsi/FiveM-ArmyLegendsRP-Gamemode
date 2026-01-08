<template>
    <div id='evidences'>
        <page-header title="Creaza Amenda" description='Amendeaza un jucator' />
        
        <div class='page-content'>
            <div class='create-container'>
                <div class='content-header'>
                    <h1>Creaza o Amenda</h1>

                    <form @submit.prevent='create' autocomplete='off'>
                        <input maxlength='120' type='text' placeholder = "Titlu Amenda" v-model='name' />
                        <textarea type='text' placeholder = "Descriere Amenda" v-model='description' />
                        
                        <mdt-autocomplete placeholder = "Persoane Amendate" variable='players' suggested_template='{userIdentity-firstname} {userIdentity-name}' selected_template='{userIdentity-firstname} {userIdentity-name}' />
                        <mdt-autocomplete placeholder = "Politisti Implicati" variable='cops' suggestion_url='cops' tag_icon='fa-solid fa-user-shield'  suggested_template='{userIdentity-firstname} {userIdentity-name}' selected_template='{userIdentity-firstname} {userIdentity-name}'/>

                        <div class='reducer' v-if='fines.length'>
                            <h1>{{ t('evidences.fine_reduction') }} ({{ fine_reduction }}%): {{ fine_reducted }}</h1>
                            <vue-slider v-model='fine_reduction' v-bind='options' />
                        </div>

                        <mdt-autocomplete :placeholder='t("words.fines")' identifier='code' variable='fines' suggestion_url='fines' selected_template='{name}' suggested_template='({code}) {name} [=amount=$]' tag_icon='fa-solid fa-file-signature' />
                        
                        <div class='form-footer'>
                            <div class='submit-button' @click='create'>
                                Creaza Amenda
                            </div>
                        </div>
                    </form>
                </div>            
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Evidences.ts'></script>