import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'br.com.inteligenciatitan.app',
  appName: 'Titan IA',
  webDir: 'www',
  // VOLTAMOS A USAR O SERVIDOR, MAS AGORA ELE TEM UM PROPÓSITO
  server: {
    url: 'https://inteligenciatitan.com.br',
    // Esta configuração diz ao Capacitor para não falhar se a URL não carregar
    errorPath: 'offline.html'
  }
};

export default config;