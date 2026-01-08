<template>
    <div class='page-header'>
        <h1><i class='fa-solid fa-arrow-circle-left' v-if='backable' @click='$parent.$parent.navigateBack'></i> {{ title }}</h1>
        <p>{{ description }}</p>
    </div>
</template>

<script lang='ts' src='./Header.ts'></script>