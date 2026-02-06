<script setup>
import { computed } from "vue";
import { TabsContent, useForwardProps } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
    value: { type: String, required: true },
    forceMount: { type: Boolean, required: false },
    asChild: { type: Boolean, required: false },
    as: { type: null, required: false },
    class: { type: null, required: false },
});

const delegatedProps = computed(() => {
    const { class: _, ...delegated } = props;

    return delegated;
});

const forwarded = useForwardProps(delegatedProps);
</script>

<template>
    <TabsContent v-bind="forwarded" :class="cn(
        'mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        props.class,
    )
        ">
        <slot />
    </TabsContent>
</template>
