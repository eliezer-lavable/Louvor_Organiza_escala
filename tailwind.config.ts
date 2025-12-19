import type { Config } from "tailwindcss";

export default {
  darkMode: ["class"],
  content: ["./pages/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./app/**/*.{ts,tsx}", "./src/**/*.{ts,tsx}"],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      // Paleta neutra (ton‑on‑ton) usando escala de cinza/stone.
      // Cada cor tem um tom mais escuro para o background e um tom mais claro
      // para o texto/foreground, garantindo contraste suficiente.
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        // Primary – tom pastel azul‑acinzentado suave.
        primary: {
          DEFAULT: "hsl(210 20% 80%)",   // azul claro pastel
          foreground: "hsl(210 20% 20%)",
        },
        // Secondary – tom de pedra claro e suave.
        secondary: {
          DEFAULT: "hsl(210 15% 90%)",
          foreground: "hsl(210 15% 30%)",
        },
        // Destructive – vermelho rosado suave para alertas.
        destructive: {
          DEFAULT: "hsl(0 70% 85%)",
          foreground: "hsl(0 0% 20%)",
        },
        // Muted – cinza muito claro para áreas de fundo secundárias.
        muted: {
          DEFAULT: "hsl(210 10% 95%)",
          foreground: "hsl(210 10% 40%)",
        },
        // Accent – tom levemente mais quente que primary, ainda pastel.
        accent: {
          DEFAULT: "hsl(30 30% 85%)",   // pêssego suave
          foreground: "hsl(30 30% 20%)",
        },
        popover: {
          DEFAULT: "hsl(210 10% 98%)",
          foreground: "hsl(210 10% 30%)",
        },
        card: {
          DEFAULT: "hsl(210 10% 96%)",
          foreground: "hsl(210 10% 30%)",
        },
        sidebar: {
          DEFAULT: "hsl(210 10% 94%)",
          foreground: "hsl(210 10% 35%)",
          primary: "hsl(210 20% 80%)",
          "primary-foreground": "hsl(210 20% 20%)",
          accent: "hsl(30 30% 85%)",
          "accent-foreground": "hsl(30 30% 20%)",
          border: "hsl(210 10% 90%)",
          ring: "hsl(210 10% 85%)",
        },
      },
      backgroundImage: {
        'gradient-primary': 'var(--gradient-primary)',
        'gradient-hero': 'var(--gradient-hero)',
        'gradient-card': 'var(--gradient-card)',
      },
      boxShadow: {
        'soft': 'var(--shadow-soft)',
        'medium': 'var(--shadow-medium)',
        'large': 'var(--shadow-large)',
      },
      transitionProperty: {
        'smooth': 'var(--transition-smooth)',
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: {
            height: "0",
          },
          to: {
            height: "var(--radix-accordion-content-height)",
          },
        },
        "accordion-up": {
          from: {
            height: "var(--radix-accordion-content-height)",
          },
          to: {
            height: "0",
          },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config;
