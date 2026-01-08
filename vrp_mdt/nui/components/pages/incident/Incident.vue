<template>
    <div id='incident'>
        <page-header :title='"Raport" + " #" + data.id' description='Acest document nu se poate modifica.' backable />

        <div class='page-content'>
            <div id='incident-grid'>
                <div id='sidebar'>
                    <div id='header'>
                        <div id='details'>
                            <i class='fa-solid fa-folder-open'></i>
                            <h1>{{ data.name }}</h1>
                            <p>{{ data.description }}</p>
                        </div>
                    </div>
                </div>
                <div id='container'>
                    <div id='details'>
                        <div class='header'>
                            <h1>Detalii</h1>
                        </div>
                        <div id='info'>
                            <p>Creat la data de: <b>{{ createdAt }}</b></p>
                        </div>
                    </div>
                    
                    <div v-if='data.players.length'>
                        <div class='header'>
                            <h1>Persoane Implicate</h1>
                        </div>
                        <div id='list-grid'>
                            <div class='list-results'>
                                <div v-for='player in data.players' @click='see("citizen", player)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>{{ player.userIdentity.firstname }} {{ player.userIdentity.name }}</h1>
                                    </div>
                                    <p>{{ player.id }}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div v-if='data.cops.length'>
                        <div class='header'>
                            <h1>Politisti Implicati</h1>
                        </div>
                        <div id='list-grid'>
                            <div class='list-results'>
                                <div v-for='cop in data.cops' @click='see("citizen", cop)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>{{ cop.userIdentity.firstname }} {{ cop.userIdentity.name }}</h1>
                                    </div>
                                    <p>{{ cop.faction.rank }}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div v-if='data.vehicles.length'>
                        <div class='header'>
                            <h1>Vehicule</h1>
                        </div>
                        <div id='list-grid'>
                            <div class='list-results'>
                                <div v-for='vehicle in data.vehicles' @click='see("vehicle", vehicle)'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>{{ vehicle.name }}</h1>
                                    </div>
                                    <p>{{ vehicle.owner }}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div v-if='data.jail.length'>
                        <div class='header'>
                            <h1>Amenzi</h1>
                        </div>
                        <div id='list-grid'>
                            <div class='list-results'>
                                <div v-for='data in data.jail'>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>{{ data.name }}</h1>
                                    </div>
                                    <p>{{ data.time }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Incident.ts'></script>