<template>
    <div id='citizen'>
        <page-header :title='t("citizen.title")' :description='t("citizen.description")' backable />

        <div class='page-content'>
            <div id='citizen-grid'>
                <div id='sidebar'>
                    <div id='header'>
                        <div id='image'>
                            <transition name='fade'>
                                <p v-show='imageHovered' id='label'>{{ t('citizen.change_image') }}</p>
                            </transition>

                            <img 
                                @mouseenter='imageHovered = true'
                                @mouseleave='imageHovered = false'
                                @click='changeImage(data.id)'
                                :src='data.image || defaultImage'
                            >
                        </div>
                        <div id='details'>
                            <!-- <p id='wanted' v-show='warrants.filter(w => !w.done).length > 0'>{{ t('citizen.wanted') }}</p> -->
                            
                            <h1>{{ data.userIdentity.firstname }} {{ data.userIdentity.name }}</h1>
                        </div>
                    </div>
                    <div id='container'>
                        <div class='header'>
                            <h1>Dosare Penale</h1>
                        </div>
                        <div id='list-grid'>
                            <div class='list-results' v-if='incidents.length'>
                                <div v-for='incident in incidents' @click='see("incident", incident)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>Dosar Penal #{{ incident.id }}</h1>
                                    </div>
                                    <p>{{ formatDate(incident.createdAt) }}</p>
                                </div>
                            </div>
                            <div v-else class='not-found'>
                                <i class='fa-regular fa-folder-open'></i>
                                <h1>{{ t('list.no_results') }}</h1>
                            </div>
                        </div>
                    </div>
                </div>
                <div id='header'>
                    <div>
                        <div class='header'>
                            <h1>{{ t('words.info') }}</h1>
                        </div>
                         
                        <div id='info'>
                            <div> 
                                <p>{{ t('words.forename') }}: <b>{{ data.userIdentity.firstname }}</b></p>
                                <p>{{ t('words.surname') }}: <b>{{ data.userIdentity.name }}</b></p>
                                <p>Varsta: <b>{{( data.userIdentity.age || 20)}}</b></p>
                                <p>Numar de Telefon: <b>{{ data.userIdentity.phone }}</b></p>
                                <p>Sex: <b>{{ data.userIdentity.sex == 'M' ? 'Masculin' : 'Feminin'}}</b></p>
                                <p>Permis de Conducere: <b>{{ data.dmvTest ? 'Valabil' : 'Expirat'}}</b></p>
                            </div>
                        </div>

                        <div class='header'>
                            <h1>{{ t('words.details') }}</h1>
                        </div>

                        <input class='dark' maxlength='120' type='text' :placeholder='t("citizen.person_description")' v-model.trim='description' @keyup.enter='change("description")' />    
                    </div>
                    <!-- <div>
                        <div class='header'>
                            <h1>Caziere</h1>
                        </div>
                        <div id='list-grid'>
                            <div class='list-results' v-if='caziere.length'>
                                <div v-for='cazier in caziere'  @click='see("warrant", cazier)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>Cazier #{{ cazier.id }}</h1>
                                    </div>
                                </div>
                            </div>
                            <div v-else class='not-found'>
                                <i class='fa-regular fa-folder-open'></i>
                                <h1>{{ t('list.no_results') }}</h1>
                            </div>
                        </div>
                    </div> -->
                </div>
                <div id='container'>
                    <div id='evidences'>
                        <div class='header'>
                            <h1>Amenzi</h1>
                        </div>

                        <div id='list-grid'>
                            <div class='list-results' v-if='amenda.length'>
                                <div v-for='data in amenda' @click='see("evidence", data)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-file-image'></i>
                                        <h1>Amenda #{{ data.id }}</h1>
                                    </div>
                                    <p>{{ formatDate(data.createdAt) }}</p>
                                </div>
                            </div>
                            <div v-else class='not-found'>
                                <i class='fa-regular fa-folder-open'></i>
                                <h1>{{ t('list.no_results') }}</h1>
                            </div>
                        </div>
                    </div>

                    <div id='warrants'>
                        <div class='header'>
                            <h1>Caziere</h1>
                        </div>

                        <div id='list-grid'>
                            <div class='list-results' v-if='caziere.length'>
                                <div v-for='cazier in caziere'  @click='see("warrant", cazier)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>Cazier #{{ cazier.id }}</h1>
                                    </div>
                                </div>
                            </div>
                            <div v-else class='not-found'>
                                <i class='fa-regular fa-folder-open'></i>
                                <h1>{{ t('list.no_results') }}</h1>
                            </div>
                        </div>
                    </div>

                    <div id='vehicles'>
                        <div class='header'>
                            <h1>{{ t('words.vehicles') }}</h1>
                        </div>

                        <div id='list-grid'>
                            <div class='list-results' v-if='vehicles.length'>
                                <div v-for='vehicle in vehicles' @click='see("vehicle", vehicle)' v-if="vehicle.vtype != 'faction' || vehicle.vtype != 'Politie' || vehicle.vtype != 'Smurd'">
                                    <div class='icon'>
                                        <i class='fa-solid fa-car'></i>
                                        <h1>{{vehicle.name}}</h1>
                                    </div>
                                </div>
                            </div>
                            <div v-else class='not-found'>
                                <i class='fa-regular fa-folder-open'></i>
                                <h1>{{ t('list.no_results') }}</h1>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Citizen.ts'></script>