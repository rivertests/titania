import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'br.com.inteligenciatitan.app',
  appName: 'Titan IA',
  webDir: 'www',
  server: {
    url: 'https://inteligenciatitan.com.br',
    errorPath: 'public/offline.html'
  },
  // Adiciona configurações explícitas da Splash Screen para garantir
  plugins: {
    SplashScreen: {
      launchShowDuration: 3000, // Mostra por 3 segundos
      launchAutoHide: true,
      backgroundColor: "#101212", // Mesma cor de fundo
      androidScaleType: "CENTER_CROP",
      splashFullScreen: true,
      splashImmersive: true,
    }
  }
};

export default config;