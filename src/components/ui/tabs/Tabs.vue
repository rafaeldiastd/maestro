<script setup>
import { TabsRoot, useForwardPropsEmits } from "reka-ui";
import { computed } from "vue";
import { cn } from "@/lib/utils";

const props = defineProps({
    defaultValue: { type: String, required: false },
    modelValue: { type: String, required: false },
    orientation: { type: String, required: false },
    dir: { type: String, required: false },
    activationMode: { type: String, required: false },
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
    <TabsRoot v-bind="forwarded" :class="cn('', props.class)">
        <slot />
    </TabsRoot>
</template>
