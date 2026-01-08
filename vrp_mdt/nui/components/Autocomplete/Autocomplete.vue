<template>
    <div class='autocomplete'>
        <div>
            <ul class='tags' :class='{ visible: selected.length > 0 }'>
                <li v-for='element in selected'>
                    <i :class='tag_icon'></i>
                    <p>{{ template('selected', element) }}</p> 
                    <i class='fa-solid fa-times' id='removeTag' @click='$parent.$parent.confirmModal(() => remove(element))'></i>
                </li>
            </ul>

            <input type='text' :placeholder='placeholder' :disabled='selected.length >= max_selected' v-model='query' @input='suggestion' />
        </div>

        <div class='autocomplete-items'>
            <div v-for='element in suggested' @click='add(element)'>
                {{ template('suggested', element) }}
            </div>
        </div>
    </div>
</template>

<script lang='ts' src='./Autocomplete.ts'></script>