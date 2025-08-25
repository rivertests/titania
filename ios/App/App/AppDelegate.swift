import UIKit
import Capacitor
import Network // Importa o framework de rede da Apple

// Adiciona o WKNavigationDelegate para podermos interceptar cliques em links
class AppDelegate: CAPAppDelegate, WKNavigationDelegate {

    // Cria um "monitor" para vigiar o status da internet de forma contínua
    let monitor = NWPathMonitor()

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Esta função é o equivalente ao "onCreate" do Android

        // Pega a referência da WebView do Capacitor
        guard let webView = self.bridge?.getWebView() else {
            return true
        }

        // 1. Remove o flash branco (equivalente ao setBackgroundColor)
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear

        // 2. Define esta classe como o "Guarda de Trânsito" de links (equivalente ao setWebViewClient)
        webView.navigationDelegate = self

        // 3. Lógica de Carregamento Centralizada (equivalente ao seu if/else)
        // A gente configura o que fazer quando a internet mudar de status
        monitor.pathUpdateHandler = { path in
            // O código aqui dentro roda sempre que a conexão muda (conecta/desconecta)
            // Precisamos garantir que a atualização da webview seja feita na thread principal
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    // SE ONLINE: Carrega o site
                    print("--> Conectado à internet. Carregando site...")
                    if let url = URL(string: "https://inteligenciatitan.com.br") {
                        let request = URLRequest(url: url)
                        webView.load(request)
                    }
                } else {
                    // SE OFFLINE: Carrega o arquivo local
                    print("--> Desconectado. Carregando página offline...")
                    if let offlineURL = Bundle.main.url(forResource: "offline/offline", withExtension: "html", subdirectory: "public") {
                         webView.loadFileURL(offlineURL, allowingReadAccessTo: offlineURL.deletingLastPathComponent().deletingLastPathComponent())
                    }
                }
            }
        }

        // Inicia o monitoramento da rede
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)

        return true
    }

    // Esta função é o "Guarda de Trânsito", o equivalente ao "shouldOverrideUrlLoading"
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString

        // Se for um link externo, abre no navegador Safari
        if urlString.contains("kirvano.com") || urlString.contains("aplicativotitan.com") {
            // Cancela a navegação dentro do app
            decisionHandler(.cancel)
            // Abre no navegador externo
            UIApplication.shared.open(url)
        } else {
            // Senão, deixa a WebView cuidar
            decisionHandler(.allow)
        }
    }
    
    // Esta função é o equivalente ao "onPageFinished" para injetar CSS/JS
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "var style = document.createElement('style');" +
                 "style.innerHTML = '* { -webkit-tap-highlight-color: rgba(0,0,0,0) !important; }';" +
                 "document.head.appendChild(style);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    // Restante das funções do AppDelegate...
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}