import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'br.com.inteligenciatitan.app',
  appName: 'Titan IA',
  webDir: 'www', // Deixe isso, mesmo que a pasta esteja vazia
  plugins: {
    EdgeToEdge: {
      backgroundColor: '#101212'
    },
  },
};
//
export default config;