<template>
    <aside class='navigation'>
        <div class='logo'>
            <img :src='logo' alt='logo' />
        </div>
        <div class='links'>
            <div class='link' 
                v-for='page in $parent.pages.filter(page => !page.disabled)'
                :key='page.id'
                :class='{ active: $parent.currentPage == page.id }'
                @click='$parent.switchPage(page.id)'
                v-bind:id='"to-" + page.id'
            >
                <i :class='page.icon'></i>
                <small>{{ page.label }}</small>
            </div>
        </div>

        <div class='links'>
            <div class='link' @click='$parent.close()'>
                <i class='fa-solid fa-sign-out-alt'></i>
                <small>{{ exit }}</small>
            </div>
        </div>
    </aside>
</template>

<script lang='ts' src='./Navigation.ts'></script>