import UIKit
import Capacitor
import WebKit
import Network // Importa o framework de rede

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bridge: CAPBridgeViewController?
    
    // Cria o monitor de rede
    let monitor = NWPathMonitor()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Inicializa o Capacitor Bridge
        self.bridge = CAPBridgeViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.bridge
        self.window?.makeKeyAndVisible()

        // Pega a WKWebView criada pelo Capacitor
        guard let webView = bridge?.webView else {
            return true
        }
        
        // 1. Remove o flash branco
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear

        // 2. Define esta classe como o "Guarda de Trânsito" de links
        webView.navigationDelegate = self
        
        // 3. Lógica de Carregamento Centralizada
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    // SE ONLINE: Carrega o site
                    if let url = URL(string: "https://inteligenciatitan.com.br") {
                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                        webView.load(request)
                    }
                } else {
                    // SE OFFLINE: Carrega o arquivo local
                    self.loadOfflinePage(webView)
                }
            }
        }
        
        // Inicia o monitoramento da rede
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        return true
    }

    // Funções padrão do Capacitor
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // Função auxiliar para carregar a página offline
    func loadOfflinePage(_ webView: WKWebView) {
        if let offlineURL = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "public/offline") {
             webView.loadFileURL(offlineURL, allowingReadAccessTo: offlineURL.deletingLastPathComponent().deletingLastPathComponent())
        }
    }
}

// MARK: - WKNavigationDelegate (Guarda de Trânsito e Funções Auxiliares)
extension AppDelegate: WKNavigationDelegate {

    // Decide o que fazer com os cliques
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
    
    // Injeta CSS quando a página termina de carregar
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "var style = document.createElement('style');" +
                 "style.innerHTML = '* { -webkit-tap-highlight-color: rgba(0,0,0,0) !important; }';" +
                 "document.head.appendChild(style);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    // Se qualquer navegação falhar (mesmo com internet), carrega a página offline como fallback
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage(webView)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage(webView)
    }
}