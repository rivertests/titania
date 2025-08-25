import UIKit
import Capacitor
import Network
import WebKit

class AppDelegate: CAPAppDelegate, WKNavigationDelegate {

    let monitor = NWPathMonitor()

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard let webView = self.bridge?.getWebView() else {
            return true
        }
//
        // Configurações da WebView
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.navigationDelegate = self
        
        // Lógica de Rede
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    if let url = URL(string: "https://inteligenciatitan.com.br") {
                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                        webView.load(request)
                    }
                } else {
                    self.loadOfflinePage(webView)
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        return true
    }
    
    // Função para carregar a página offline
    func loadOfflinePage(_ webView: WKWebView) {
        // CORREÇÃO APLICADA AQUI: O subdiretório é apenas "offline",
        // pois a pasta "public" já é a raiz.
        if let offlineURL = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "offline") {
             webView.loadFileURL(offlineURL, allowingReadAccessTo: offlineURL.deletingLastPathComponent())
        }
    }
    
    // Função "Guarda de Trânsito" para links
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else {
            decisionHandler(.allow)
            return
        }
        let urlString = url.absoluteString

        if urlString.contains("kirvano.com") || urlString.contains("aplicativotitan.com") {
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // Função para injetar CSS
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "var style = document.createElement('style');" +
                 "style.innerHTML = '* { -webkit-tap-highlight-color: rgba(0,0,0,0) !important; }';" +
                 "document.head.appendChild(style);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    // Funções de fallback para erros de carregamento
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { self.loadOfflinePage(webView) }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { self.loadOfflinePage(webView) }
    }

    // Funções padrão do Capacitor
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}