<template>
    <div id='codes'>
        <page-header :title='t("codes.title")' :description='t("codes.description")' />

        <div class='page-content'>
            <list name='code' :label='t("codes.search")' :interactable='false' item_element='fa-solid fa-clipboard-list' main_template='{name}' secondary_template='{code}' />
        </div>
    </div>
</template>

<script lang='ts' src='./Codes.ts'></script>