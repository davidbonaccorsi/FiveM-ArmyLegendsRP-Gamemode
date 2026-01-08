<template>
    <div id='dashboard'>
        <page-header :title='t("dashboard.title", { name: `${player.firstname} ${player.name}` })' :description='"Rank: " + player.jobRank' />
        
        <div class='page-content'>
            <div id='section' class='header'>
                <div id='info'>
                    <div class='icon'><i class='fas fa-phone-alt'></i></div>
                    <div>
                        <h1>{{ alerts }}</h1>
                        <h2>Apeluri</h2>
                    </div>
                </div>
                <div id='info'>
                    <div class='icon'><i class="fa-solid fa-kit-medical"></i></div>
                    <div>
                        <h1>{{ medics }}</h1>
                        <h2>Medici Online</h2>
                    </div>
                </div>
                <div id='info'>
                    <div class='icon'><i class='fas fa-shield-alt'></i></div>
                    <div>
                        <h1>{{ cops }}</h1>
                        <h2>Politisti Online</h2>
                    </div>
                </div>
            </div>
            <div id='section'>
                <div>
                    <div class='content-header'>
                        <h1>{{ t('words.chat') }}</h1>
                    </div>

                    <div class='chat'>
                        <div class='messages' id='messages-box' v-if='messages.length'>
                            <div class='message' 
                                v-for='message in messages' 
                                :id='message.id'
                                :class='message.phone == player.phone && "author"' 
                            >
                                <div class='left'>
                                    <img :src='message.image || image' />
                                </div>
                                <div class='right'>
                                    <div class='name'>
                                        <h1>{{ message.author }} ({{ message.rank }})</h1>
                                    </div>
                                    <div class='content'>
                                        <p>{{ message.content }}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div v-else class='not-found'>
                            <i class='fa-solid fa-comment-slash'></i>
                        </div>
                        <div class='footer'>
                            <input type='text' :placeholder='t("dashboard.chat_message")' v-model.trim='message' @keyup.enter='sendMessage' />
                            <i class='fa-solid fa-paper-plane' @click='sendMessage'></i>
                        </div>
                    </div>
                </div>

                <div class='fines' id='list-grid'>
                    <div class='content-header'>
                        <h1>{{ t('words.fines') }}</h1>
                    </div>
                    <div class='list-results' v-if='fines.length'>
                        <div class='fine' v-for='fine in fines'>
                            <div class='icon'>
                                <i :class='item_element'></i>
                                <h1>({{ fine.code }}) {{ fine.name }}</h1>
                            </div>
                            <p>{{ fine.amount }}$</p>
                        </div>
                    </div>
                    <div v-else class='not-found'>
                        <i class='fa-regular fa-folder-open'></i>
                    </div>
                </div>

                <div class='codes' id='list-grid'>
                    <div class='content-header'>
                        <h1>{{ t('words.codes') }}</h1>
                    </div>
                    <div class='list-results' v-if='codes.length'>
                        <div class='warrant' v-for='code in codes'>
                            <div class='icon'>
                                <i :class='item_element'></i>
                                <h1>{{code.code}}</h1>
                            </div>
                            <p>{{code.name}}</p>
                        </div>
                    </div>
                    <div v-else class='not-found'>
                        <i class='fa-regular fa-folder-open'></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Dashboard.ts'></script>