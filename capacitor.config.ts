import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'br.com.inteligenciatitan.app',
  appName: 'Titan IA',
  webDir: 'www', // mantém, mesmo que você use server.url
  server: {
    url: 'https://inteligenciatitan.com.br',
    cleartext: false, // garante https, pode omitir se quiser
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 3000,
      launchAutoHide: true,
      backgroundColor: "#101212",
      androidScaleType: "CENTER_CROP",
      splashFullScreen: true,
      splashImmersive: true,
    }
  }
};

export default config;
