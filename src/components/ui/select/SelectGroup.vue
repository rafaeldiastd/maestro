<script setup>
import { SelectGroup } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
  as: { type: null, required: false, default: "div" },
  class: { type: null, required: false },
});
</script>

<template>
  <SelectGroup :class="cn('p-1 w-full', props.class)" v-bind="props">
    <slot />
  </SelectGroup>
</template>
