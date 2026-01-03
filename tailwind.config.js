import colors from 'tailwindcss/colors'

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        slate: colors.stone, // Override slate with stone globally
        gray: colors.stone,  // Override gray with stone just in case
        'lumina-bg': '#0c0a09', // stone-950 (Obsidian-like)
        'lumina-card': '#1c1917', // stone-900
        'lumina-accent': '#d6d3d1', // stone-300 (Subtle high-contrast instead of purple)
        'lumina-accent-hover': '#e7e5e4', // stone-200
        'lumina-text': '#fafaf9', // stone-50
        'lumina-text-muted': '#a8a29e', // stone-400
      },
      fontFamily: {
        sans: ['Outfit', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
