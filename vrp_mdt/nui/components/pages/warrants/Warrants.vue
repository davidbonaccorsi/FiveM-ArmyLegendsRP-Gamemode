<template>
    <div id='warrants'>
        <page-header title="Caziere" description='Cauta sau creaza un Cazier' />

        <div class='page-content'>
            <!-- <list name='warrant' label='Cauta un Cazier' item_element='fa-solid fa-folder-minus' :main_template='"Cazier " + " #=id="' secondary_template='~createdAt~' /> -->

            <div class='create-container'>
                <div class='content-header'>
                    <h1>Creaza un Cazier</h1>

                    <form @submit.prevent='create' autocomplete='off'>
                        <input placeholder='Motiv' type='text' v-model='reason' />
                        <textarea placeholder='Descriere Cazier' type='text' v-model='description' />
                        <mdt-autocomplete placeholder='Persoana Acuzata' variable='players' suggested_template='{userIdentity-firstname} {userIdentity-name}' selected_template='{userIdentity-firstname} {userIdentity-name}' />

                        <div class='form-footer'>
                            <div class='submit-button' @click='create'>
                               Creaza Cazier
                            </div>
                        </div>
                    </form>
                </div>            
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Warrants.ts'></script>