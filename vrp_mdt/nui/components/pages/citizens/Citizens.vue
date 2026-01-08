<template>
    <div id='citizens'>
        <page-header :title='t("citizens.title")' :description='t("citizens.description")' />

        <div class='page-content'>
            <list name='citizen' :label='t("citizens.search")' :delete='false' item_element='fa-solid fa-person' main_template='{userIdentity-firstname} {userIdentity-name}' secondary_template='{userIdentity-phone}' />
        </div>
    </div>
</template>

<script lang='ts' src='./Citizens.ts'></script>