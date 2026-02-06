<script setup>
import { computed } from "vue";
import { RadioGroupRoot, useForwardPropsEmits } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
    defaultValue: { type: String, required: false },
    modelValue: { type: String, required: false },
    orientation: { type: String, required: false },
    dir: { type: String, required: false },
    loop: { type: Boolean, required: false },
    disabled: { type: Boolean, required: false },
    required: { type: Boolean, required: false },
    name: { type: String, required: false },
    asChild: { type: Boolean, required: false },
    as: { type: null, required: false },
    class: { type: null, required: false },
});
const emits = defineEmits(["update:modelValue"]);

const delegatedProps = computed(() => {
    const { class: _, ...delegated } = props;

    return delegated;
});

const forwarded = useForwardPropsEmits(delegatedProps, emits);
</script>

<template>
    <RadioGroupRoot :class="cn('grid gap-2', props.class)" v-bind="forwarded">
        <slot />
    </RadioGroupRoot>
</template>
