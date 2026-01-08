<template>
    <div id='config'>
        <page-header :title='t("config.title")' :description='t("config.description")' />

        <div class='page-content'>
            <div id='config-grid'>
                <div class='box'>
                    <div class='color' v-for='color in colors'>
                        <h1>{{ t(`colors.${color}`) }}: </h1>
                        <verte picker='square' enableAlpha rgbSliders showHistory :value='getColor(color)' model='hex' @input='c => changeColor(c, color)'>
                            <i class='fa-solid fa-palette'></i>
                        </verte>
                    </div>

                    <div class='submit-button' @click='reset'>
                        {{ t('config.reset') }}
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Config.ts'></script>