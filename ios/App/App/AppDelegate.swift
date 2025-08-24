import UIKit
import Capacitor
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bridge: CAPBridge?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Cria a janela principal
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // Inicializa o Capacitor Bridge
        let bridgeViewController = CAPBridgeViewController()
        self.bridge = bridgeViewController.bridge

        // Define delegate de navegação para capturar falhas
        bridgeViewController.bridge?.webView?.navigationDelegate = self

        self.window?.rootViewController = bridgeViewController
        self.window?.makeKeyAndVisible()

        return true
    }
}

extension AppDelegate: WKNavigationDelegate {
    // Quando falhar carregar uma URL, cai aqui
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage(in: webView)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage(in: webView)
    }

    private func loadOfflinePage(in webView: WKWebView) {
        if let url = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "public") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}
