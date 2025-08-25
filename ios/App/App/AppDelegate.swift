import UIKit
import Capacitor // <-- A LINHA QUE FALTAVA E CORRIGE TUDO
import Network

class AppDelegate: CAPAppDelegate, WKNavigationDelegate {

    let monitor = NWPathMonitor()

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let webView = self.bridge?.getWebView() else {
            return true
        }

        // 1. Remove o flash branco
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear

        // 2. Define o "Guarda de Trânsito" de links
        webView.navigationDelegate = self

        // 3. Lógica de Carregamento Centralizada
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    // SE ONLINE: Carrega o site
                    print("--> Conectado à internet. Carregando site...")
                    if let url = URL(string: "https://inteligenciatitan.com.br") {
                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                        webView.load(request)
                    }
                } else {
                    // SE OFFLINE: Carrega o arquivo local
                    print("--> Desconectado. Carregando página offline...")
                    // O caminho correto para os assets do Capacitor
                    if let offlineURL = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "public/offline") {
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

    // "Guarda de Trânsito" - decide o que fazer com os cliques
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString

        // Se for um link externo, abre no navegador Safari
        if urlString.contains("kirvano.com") || urlString.contains("aplicativotitan.com") {
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            // Senão, deixa a WebView cuidar
            decisionHandler(.allow)
        }
    }
    
    // Injeta CSS/JS quando a página termina de carregar
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "var style = document.createElement('style');" +
                 "style.innerHTML = '* { -webkit-tap-highlight-color: rgba(0,0,0,0) !important; }';" +
                 "document.head.appendChild(style);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    // Funções padrão do Capacitor
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}