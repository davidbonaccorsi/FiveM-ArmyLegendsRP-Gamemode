<template>
    <div id='app'>
        <transition name='fade'>
            <div class='container' v-show='opened'>
                <transition name='fade'>
                    <div class='modal-overlay' v-if='modal.opened'> 
                        <modal />
                    </div>
                </transition>

                <navigation />
                
                <transition name='component-fade' mode='out-in'>
                    <component class='page-container' :data='data' :is='currentPage' />
                </transition>
            </div> 
        </transition>
    </div>
</template>

<script lang='ts' src='./App.ts'></script>