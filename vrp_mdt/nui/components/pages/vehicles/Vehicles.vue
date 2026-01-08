<template>
    <div id='vehicles'>
        <page-header :title='t("vehicles.title")' :description='t("vehicles.description")' />

        <div class='page-content'>
            <list name='vehicle' :label='t("vehicles.search")' :delete='false' item_element='fa-solid fa-car' main_template='{name}' secondary_template='{carPlate}' />
        </div>
    </div>
</template>

<script lang='ts' src='./Vehicles.ts'></script>