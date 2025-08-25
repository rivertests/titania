import UIKit
import Capacitor
import Network
import WebKit

class AppDelegate: CAPAppDelegate, WKNavigationDelegate {

    // Cria uma única instância do monitor de rede para a classe
    let monitor = NWPathMonitor()

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Pega a referência da WebView do Capacitor de forma segura
        guard let webView = self.bridge?.getWebView() else {
            return true
        }

        // --- Configurações Visuais da WebView ---
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.navigationDelegate = self
        
        // --- Lógica de Rede Principal ---
        // Este bloco decide o que carregar quando o app inicia ou a rede muda
        monitor.pathUpdateHandler = { path in
            // Garante que qualquer mudança na interface ocorra na thread principal
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    // SE ONLINE: Carrega o site
                    if let url = URL(string: "https://inteligenciatitan.com.br") {
                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                        webView.load(request)
                    }
                } else {
                    // SE OFFLINE: Carrega a página local
                    self.loadOfflinePage(webView)
                }
            }
        }
        
        // Inicia o monitoramento da rede em um background thread
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        return true
    }
    
    // --- Funções Auxiliares ---

    // Carrega a página offline.html a partir dos assets do app
    func loadOfflinePage(_ webView: WKWebView) {
        // O Capacitor copia 'www/offline/offline.html' para a pasta 'public/offline/offline.html' no bundle.
        // O subdiretório correto a ser procurado a partir da raiz ('public') é 'offline'.
        if let offlineURL = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "offline") {
             webView.loadFileURL(offlineURL, allowingReadAccessTo: offlineURL.deletingLastPathComponent())
        }
    }
    
    // --- Funções do WKNavigationDelegate ---

    // "Guarda de Trânsito": Decide o que fazer quando um usuário clica em um link
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else {
            decisionHandler(.allow)
            return
        }
        let urlString = url.absoluteString

        // Se for um link externo, abre no navegador padrão (Safari)
        if urlString.contains("kirvano.com") || urlString.contains("aplicativotitan.com") {
            decisionHandler(.cancel) // Impede que a webview interna carregue o link
            UIApplication.shared.open(url)
        } else {
            // Para todos os outros links, permite que a webview navegue normalmente
            decisionHandler(.allow)
        }
    }
    
    // Injeta CSS/JS quando uma página termina de carregar
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Remove o highlight azul que aparece ao tocar em links
        let js = "var style = document.createElement('style');" +
                 "style.innerHTML = '* { -webkit-tap-highlight-color: rgba(0,0,0,0) !important; }';" +
                 "document.head.appendChild(style);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    // Fallback: Se uma navegação falhar por qualquer motivo (ex: site fora do ar), carrega a página offline
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { self.loadOfflinePage(webView) }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { self.loadOfflinePage(webView) }
    }

    // --- Funções Padrão do Capacitor (Não modificar) ---

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUerActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}