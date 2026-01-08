<template>
    <div id='warrant'>
        <page-header title='Cazier' description='Nu poti edita acest document' backable />
        <div class='page-content'>
            <div id='warrant-grid'>
                <div id='sidebar'>
                    <div id='header'>
                        <div id='details'>
                            <i class='fa-solid fa-folder-open'></i>
                            <h1>Cazier</h1>
                        </div>
                    </div>

                    <div id='container'>
                        <div class='header'>
                            <h1>Persoana Acuzata</h1>
                        </div>

                        <div id='list-grid'>
                            <div class='list-results'>
                                <div>
                                    <div class='icon'>
                                        <i class='fa-solid fa-folder'></i>
                                        <h1>{{ data.userData.firstname }} {{ data.userData.name }}</h1>
                                    </div>
                                    <p>{{data.user_id }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div id='container'>
                    <div>
                        <div class='header'>
                            <h1>{{ t('words.info') }}</h1>
                        </div>

                        <div id='info'>
                            <p>{{ t('words.reason') }}: <b>{{ data.reason }}</b></p>
                            <p>{{ t('words.description') }}: <b>{{ data.description || t('words.none') }}</b></p>
                            <p>{{ t('words.createdAt') }}: <b>{{ created }}</b></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Warrant.ts'></script>