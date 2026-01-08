<template>
    <div id='houses'>
        <page-header :title='t("houses.title")' :description='t("houses.description")' />
        
        <div class='page-content'>
            <list name='house' :label='t("houses.search")' :delete='false' :interactable='false' item_element='fa-solid fa-house-chimney' main_template='Casa NR: #=id=' secondary_template='Owner: {owner}' />
        </div>
    </div>
</template>

<script lang='ts' src='./Houses.ts'></script>