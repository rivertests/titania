// --- CÓDIGO DE DEBUG - REMOVER DEPOIS ---
(function() {
  var oldLog = console.log;
  console.log = function (message) {
      window.Capacitor.Plugins.Modals.alert({
          title: 'Debug Log',
          message: JSON.stringify(message)
      });
      oldLog.apply(console, arguments);
  };
})();
// --- FIM DO CÓDIGO DE DEBUG ---

const { LocalNotifications } = window.Capacitor.Plugins;
// --- BANCO DE MENSAGENS ---
// 4 mensagens únicas para cada dia da semana (Total: 28)
const mensagens = {
  // Domingo
  0: [ 
    { title: '☀️ Domingo também é dia!', body: 'O mercado cripto não dorme. O Titan já encontrou as primeiras oportunidades do dia para você.' },
    { title: '💡 Dica do Titan', body: 'Estude os gráficos do fim de semana. A preparação de hoje define a vitória de amanhã.' },
    { title: '☕ Foco no Fim de Semana', body: 'Enquanto outros descansam, os campeões se preparam. Continue focado nos seus objetivos.' },
    { title: '🚀 Planeje sua Semana', body: 'Use a tranquilidade do domingo para definir suas metas para a semana. O Titan está pronto para te ajudar a alcançá-las.' }
  ],
  // Segunda-feira
  1: [ 
    { title: '📈 Início da Semana, Foco Total!', body: 'O Titan já analisou o mercado. As oportunidades estão prontas. Vamos bater a meta hoje!' },
    { title: '💡 Dica do Titan', body: 'Paciência é uma virtude no trade. Espere pela confirmação antes de entrar na operação.' },
    { title: '📊 Análise de Meio-dia', body: 'Como estão seus trades? Siga o plano e não deixe a emoção dominar.' },
    { title: '🔒 Fechamento Seguro', body: 'O mercado está quase fechando. Garanta seus lucros e prepare-se para amanhã. Ótimo trabalho!' }
  ],
  // Terça-feira
  2: [ 
    { title: '🚀 O Mercado Não Para!', body: 'Novas tendências foram identificadas pelo Titan. Abra o app e confira os sinais.' },
    { title: '🧠 Mente de Trader', body: 'Controle o risco, gerencie seu capital. A disciplina de hoje é o lucro de amanhã.' },
    { title: '🎯 Meta à Vista!', body: 'Você está no caminho certo. Continue com a estratégia e a meta diária será atingida.' },
    { title: '🧐 Revise Suas Operações', body: 'O dia foi bom? Aprenda com cada trade. O Titan te ajuda, mas o trader é você!' }
  ],
  // Quarta-feira
  3: [ 
    { title: '🔥 Metade da Semana!', body: 'Mantenha a consistência. O Titan está operando com alta precisão. Confie no processo.' },
    { title: '⚠️ Alerta de Volatilidade', body: 'O mercado está agitado. Use o Titan para navegar pelas ondas e encontrar as melhores entradas.' },
    { title: '☕ Pausa e Gráficos', body: 'Respire fundo. Analise os resultados parciais e ajuste o que for preciso para a tarde.' },
    { title: '🏆 Dia de Vitória!', body: 'Cada trade positivo é um passo mais perto da sua liberdade financeira. Parabéns pela dedicação!' }
  ],
  // Quinta-feira
  4: [ 
    { title: '⚡️ Potencialize Seus Ganhos', body: 'O Titan encontrou um padrão promissor. Esta pode ser a grande oportunidade do dia.' },
    { title: '🧘‍♂️ Controle Emocional', body: 'Não se abale por uma perda. O gerenciamento de risco é a chave. Siga o plano.' },
    { title: '📈 Rumo ao Topo', body: 'A consistência é o que separa os amadores dos profissionais. Continue assim!' },
    { title: '🌙 Preparação Noturna', body: 'O dia de trade acabou, mas a preparação para amanhã começa agora. Estude os mercados.' }
  ],
  // Sexta-feira
  5: [ 
    { title: '🎉 Sextou com Meta Batida!', body: 'Último dia útil da semana! Vamos fechar com chave de ouro e garantir o lucro.' },
    { title: '💰 Realize Seus Lucros', body: 'Não seja ganancioso. Sexta-feira é dia de colocar o lucro no bolso. O Titan te ajuda a decidir a hora certa.' },
    { title: '✨ Fim de Tarde de Sucesso', body: 'Parabéns por mais uma semana de trades inteligentes. O descanso do fim de semana é merecido.' },
    { title: '🥂 Comemore as Conquistas!', body: 'Você trabalhou duro e usou a melhor tecnologia. Aproveite o resultado. Bom fim de semana, trader!' }
  ],
  // Sábado
  6: [ 
    { title: '💪 Sábado de Oportunidades!', body: 'O mercado de criptomoedas não para! O Titan continua trabalhando para você 24/7.' },
    { title: '📚 Estudo e Evolução', body: 'Aproveite o sábado para estudar novas estratégias. Conhecimento é poder no mundo do trade.' },
    { title: '📊 Análise Semanal', body: 'Revise seus trades da semana. O que funcionou? O que pode melhorar? O Titan te dá os dados.' },
    { title: '🎯 Mantenha o Foco', body: 'Mesmo no fim de semana, um olho no mercado pode revelar oportunidades únicas. Esteja preparado.' }
  ]
};

// --- FUNÇÃO PRINCIPAL ---
async function setupNotifications() {
  try {
    // Impede que a função seja executada múltiplas vezes na mesma sessão
    if (window.notificationsAreScheduled) {
      console.log("Notificações já foram agendadas nesta sessão.");
      return;
    }

    const { LocalNotifications } = window.Capacitor.Plugins;

    const perm = await LocalNotifications.requestPermissions();
    if (perm.display !== 'granted') {
      console.log("Permissão de notificação negada.");
      return;
    }

    // Cria o canal de notificação
    await LocalNotifications.createChannel({
      id: 'lembretes_titan_prod',
      name: 'Sinais e Lembretes Titan',
      description: 'Notificações diárias para te ajudar a bater suas metas.',
      importance: 4, // Alta
      visibility: 1, // Pública
    });

    // Limpa agendamentos antigos para evitar duplicatas
    const pending = await LocalNotifications.getPending();
    if (pending.notifications.length > 0) {
      await LocalNotifications.cancel(pending);
      console.log("Agendamentos antigos cancelados.");
    }

    // Define as janelas de tempo para os horários aleatórios
    const janelas = [
      { start: 8, end: 10 },   // Manhã
      { start: 12, end: 14 },  // Almoço
      { start: 15, end: 17 },  // Tarde
      { start: 18, end: 20 }   // Noite
    ];
    
    const hoje = new Date().getDay(); // Domingo = 0, Segunda = 1, ...
    const mensagensDoDia = mensagens[hoje];

    const notificacoesParaAgendar = [];
    
    // Pega as 4 mensagens do dia e cria 4 agendamentos
    for (let i = 0; i < 4; i++) {
      const janela = janelas[i];
      const mensagem = mensagensDoDia[i];

      // Gera um horário aleatório dentro da janela
      const hora = Math.floor(Math.random() * (janela.end - janela.start + 1)) + janela.start;
      const minuto = Math.floor(Math.random() * 60);

      notificacoesParaAgendar.push({
        id: 100 + i, // IDs de 100 a 103 para as 4 notificações do dia
        title: mensagem.title,
        body: mensagem.body,
        schedule: { 
          on: {
            hour: hora,
            minute: minuto
          },
          repeats: true // Repete todos os dias neste horário
        },
        channelId: 'lembretes_titan_prod',
        smallIcon: 'res://mipmap/ic_launcher_round'
      });
    }

    await LocalNotifications.schedule({ notifications: notificacoesParaAgendar });
    
    window.notificationsAreScheduled = true;
    console.log(`${notificacoesParaAgendar.length} notificações diárias agendadas com sucesso para hoje.`);

  } catch (err) {
    console.error("Erro ao configurar as notificações:", err);
  }
}

// Roda a função principal
setupNotifications();