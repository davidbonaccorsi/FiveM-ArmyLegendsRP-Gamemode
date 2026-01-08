<template>
    <div id='incidents'>
        <page-header title="Dosare Penale" description='Cauta sau creaza un Dosar Penal' />
        <div class='page-content'>

            <div class='create-container'>
                <div class='content-header'>
                    <h1>Creaza un Dosar Penal</h1>

                    <form @submit.prevent='create' autocomplete='off'>
                        <input maxlength='120' type='text' :placeholder='t("incidents.incident_name")' v-model='name' />
                        <textarea type='text' :placeholder='t("incidents.incident_description")' v-model='description' />
                        
                        <mdt-autocomplete :placeholder='t("warrants.players")' variable='players' suggested_template='{userIdentity-firstname} {userIdentity-name}' selected_template='{userIdentity-firstname} {userIdentity-name}' />
                        <mdt-autocomplete :placeholder='t("incidents.cops")' variable='cops' suggestion_url='cops' tag_icon='fa-solid fa-user-shield'  suggested_template='{userIdentity-firstname} {userIdentity-name}' selected_template='{userIdentity-firstname} {userIdentity-name}'/>
                        <mdt-autocomplete :placeholder='t("incidents.vehicles")' identifier='plate' variable='vehicles' suggestion_url='vehicles' selected_template='{name}' suggested_template='{name} ({carPlate})' tag_icon='fa-solid fa-car' />
             
                        <div class='reducer' v-if='jails.length'>
                            <h1>{{ t('incidents.jail_reduction') }} ({{ jail_reduction }}%): {{ jail_reducted }}</h1>
                            <vue-slider v-model='jail_reduction' v-bind='options' />
                        </div>
                        
                        <mdt-autocomplete :placeholder='t("words.jail")' identifier='id' variable='jails' suggestion_url='jail' selected_template='{name}' suggested_template='{name} [=time= months]' tag_icon='fa-solid fa-clock' />

                        <div class='form-footer'>
                            <div class='submit-button' @click='create'>
                                Creaza Dosar Penal
                            </div>
                        </div>
                    </form>
                </div>            
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Incidents.ts'></script>