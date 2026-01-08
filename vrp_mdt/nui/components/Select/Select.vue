<template>
    <div class='mdt-select-component' @blur='open = false'>
      <div class='mdt-select' :tabindex='tabindex'>
          <div class='selected' :class='{ default: selected.hidden }' @click='open = !open'>
              {{ selected.label }}
          </div>
      </div>
      <div class='items' :class='{ hide: !open }'>
        <div v-for='(option, i) of unselected' :key='i'
            @click='
                selected = option;
                open = false;
                $emit("input", option);
            '
        >
            {{ option.label }}
        </div>
      </div>
    </div>
</template>

<script lang='ts' src='./Select.ts'></script>