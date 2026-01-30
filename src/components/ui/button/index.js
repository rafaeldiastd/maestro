import { cva } from "class-variance-authority";

export { default as Button } from "./Button.vue";

export const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-lg text-sm font-medium transition-all focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        // Primary Glass (Gold/Detail - Based on IconSidebar Active)
        default: "bg-lumina-detail/10 text-lumina-detail border border-lumina-detail/20 hover:bg-lumina-detail/20 hover:border-lumina-detail/30 shadow-[0_0_15px_-3px_rgba(223,212,189,0.1)] backdrop-blur-md",

        // Secondary Glass (Neutral)
        secondary: "border border-lumina-detail/0 text-lumina-text hover:bg-lumina-bg",

        // Destructive Glass
        destructive: "bg-red-500/10 text-red-400 border border-red-500/20 hover:bg-red-500/20 hover:border-red-500/30",

        // Outline (Similar to Secondary but more border focus)
        outline: "border border-lumina-border bg-transparent hover:bg-white/5 text-lumina-text",

        // Ghost (Hover Glass)
        ghost: "hover:bg-white/5 hover:text-lumina-text text-lumina-text-muted transition-colors",

        // Link
        link: "text-lumina-detail underline-offset-4 hover:underline",

        // Icon Sidebar Style (Specific variant if needed, but 'default' covers the visual)
        sidebar: "bg-transparent text-lumina-text-muted hover:bg-lumina-bg hover:text-lumina-text data-[active=true]:bg-lumina-detail/10 data-[active=true]:text-lumina-detail data-[active=true]:border-lumina-detail/20 border border-transparent",
      },
      size: {
        default: "h-9 px-4 py-2",
        xs: "h-7 rounded-md px-2",
        sm: "h-8 rounded-md px-3 text-xs",
        lg: "h-10 rounded-lg px-8",
        full: "h9 px-4 py-2 w-full",
        icon: "h-9 w-9",
        "icon-sm": "h-8 w-8",
        "icon-lg": "h-10 w-10",
        pill: "h-9 px-6 rounded-full",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
);
