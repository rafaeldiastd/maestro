<script setup>
import { SelectValue } from "reka-ui";

const props = defineProps({
  placeholder: { type: String, required: false },
  as: { type: null, required: false, default: "span" },
});
</script>

<template>
  <SelectValue v-bind="props">
    <slot />
  </SelectValue>
</template>
