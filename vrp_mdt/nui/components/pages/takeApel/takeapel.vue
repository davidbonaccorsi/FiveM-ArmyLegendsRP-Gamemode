<template>
    <div id='takeapel'>
        <page-header :title='"Apel"' :description='"Accepta sau respinge acest apel"' backable />

        <div class='page-content'>
            <div id='takecalls-grid'>
                <div id='sidebar'>
                    <div id='header'>
                        <div id='image'>
                            <img :src='data.info.image || defaultImage'/>
                        </div>
                        <div id='details'>
                        <p id='wanted' v-show='data.info.policeTaken'>{{ "Acest apel a fost preluat de" }} {{data.info.policeTaken}}</p>

                            <h1>{{ data.info.firstname }} {{ data.info.name }}</h1>
                        </div>
                    </div>
                    <div id='container'>
                        <div class='header'>
                            <h1>Informatii Apel</h1>
                        </div>

                        <div class='descriptionData'>{{ data.info.reason }}</div>
                    </div>
                </div>
                <div id='header'>
                    <div>
                        <div class='header'>
                            <h1>{{ t('words.info') }}</h1>
                        </div>
                         
                        <div id='info'>
                            <div>    
                                <p>CNP: <b>{{ data.info.playerID }}</b></p>
                                <p>{{ t('words.forename') }}: <b>{{ data.info.firstname }}</b></p>
                                <p>{{ t('words.surname') }}: <b>{{ data.info.name }}</b></p>
                                <p>Numar de Telefon: <b>{{ data.info.phone }}</b></p>
                                <p>Sex: <b>{{ data.info.sex == 'm' ? 'Masculin' : 'Feminin'}}</b></p>
                                <br>
                            </div>
                        </div>

                        <div id="buttons" >
                          <div id='accept' @click='takecall(data.info.callID)'> 
                            <div class='icon'>
                               <i class="fa-solid fa-phone"></i>
                            </div>
                            <p>Accepta Apelul</p>
                          </div>

                         <div id='cancel' @click='cancelcall(data.info.callID)'> 
                            <div class='icon'>
                               <i class="fa-solid fa-phone-slash"></i>
                            </div>
                            <p>Anuleaza apelul</p>
                          </div>

                         <div id='locate' @click='setLocation(data.info.callID)'> 
                            <div class='icon'>
                               <i class="fa-solid fa-location-dot"></i>
                            </div>
                            <p>Localizeaza Apelul</p>
                          </div>

                         <div id='backup' @click='requestbackup(data.info.callID)'> 
                            <div class='icon'>
                               <i class="fa-solid fa-person-military-rifle"></i>
                            </div>
                            <p>Solicita Intariri</p>
                          </div>

                         <div id='medic' @click='requestparamedic(data.info.callID)'> 
                            <div class='icon'>
                               <i class="fa-solid fa-truck-medical"></i>
                            </div>
                            <p>Solicita Paramedici</p>
                          </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./takeapel.ts'></script>