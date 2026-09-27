/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        dark: {
          950: '#05070e',
          900: '#090d16',
          850: '#0d1322',
          800: '#121a2d',
          700: '#1a243d',
        },
        brand: {
          orange: '#ff7a29',
          purple: '#a855f7',
          indigo: '#6366f1',
          cyan: '#06b6d4',
          emerald: '#10b981',
        }
      },
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'Inter', 'sans-serif'],
        display: ['Sora', 'sans-serif'],
      },
      animation: {
        'pulse-glow': 'pulseGlow 3s infinite alternate',
        'spin-slow': 'spinSlow 16s linear infinite',
      },
      keyframes: {
        pulseGlow: {
          '0%': { opacity: 0.4, transform: 'scale(1)' },
          '100%': { opacity: 0.8, transform: 'scale(1.05)' },
        },
        spinSlow: {
          '0%': { transform: 'rotate(0deg)' },
          '100%': { transform: 'rotate(360deg)' },
        }
      }
    },
  },
  plugins: [],
}
