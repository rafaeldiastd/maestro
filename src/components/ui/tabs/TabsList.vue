<script setup>
import { computed } from "vue";
import { TabsList, useForwardProps } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
    loop: { type: Boolean, required: false },
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
    <TabsList v-bind="forwarded" :class="cn(
        'inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground',
        props.class,
    )
        ">
        <slot />
    </TabsList>
</template>
