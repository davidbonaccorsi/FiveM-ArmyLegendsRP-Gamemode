<template>
    <div class='modal'>
        <div class='type'>
            <i :class='$parent.modal.data.icon'></i>
        </div>
        <h1>{{ $parent.modal.data.title }}</h1>
        <h2 v-html='$parent.modal.data.description'></h2>
        <div class='buttons'>
            <div class='button' v-for='button in $parent.modal.data.buttons' v-bind:class='{ red: button.close }' v-on:click='button.handler'>
                {{ button.label }}
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Modal.ts'></script>