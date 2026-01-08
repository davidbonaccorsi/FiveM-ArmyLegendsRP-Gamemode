<template>
    <div id='vehicle'>
        <page-header :title='t("vehicle.title")' :description='t("vehicles.description")' backable />

        <div class='page-content'>
            <div id='vehicle-grid'>
                <div id='sidebar'>
                    <div id='header'>
                        <div id='image'>
                            <transition name='fade'>
                                <p v-show='imageHovered' id='label'>{{ t('vehicle.change_image') }}</p>
                            </transition>
                            <img 
                                @mouseenter='imageHovered = true'
                                @mouseleave='imageHovered = false'
                                @click='changeImage(data.plate)'
                                :src='data.image || defaultImage'
                            >
                        </div>
                        <div id='details'>
                            <h1>{{data.name}}</h1>
                            <p>{{data.carPlate}}</p>
                        </div>
                    </div>
                    <div id='container'>
                        <div class='header'>
                            <h1>{{ t('words.incidents') }}</h1>
                        </div>

                        <div id='list-grid'>
                            <div class='list-results' v-if='incidents.length'>
                                <div v-for='incident in incidents' @click='see("incident", incident)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>{{ t('words.incident') }} #{{ incident.id }}</h1>
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
                <div id='container'>
                    <div class='header'>
                        <h1>{{ t('words.details') }}</h1>
                    </div>

                    <input class='dark' maxlength='50' type='text' :placeholder='t("vehicle.veh_description")' v-model.trim='description' @keyup.enter='changeDescription' />
                
                    <div class='header'>
                        <h1>{{ t('words.info') }}</h1>
                    </div>

                    <div id='info'>
                        <p>{{ t('words.owner') }}: <b>{{ data.owner }}</b></p>
                        <p>Numar de inmatriculare: <b>{{data.carPlate}}</b></p>
                        <p v-if="data['vehStatus']">KM: <b>{{ data['vehStatus']['condition'].km || 0 }}</b></p>
                        <p v-else>KM: <b>0</b></p>
                    </div>   
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Vehicle.ts'></script>