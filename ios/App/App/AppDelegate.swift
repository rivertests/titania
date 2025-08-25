import UIKit
import Capacitor
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bridge: CAPBridgeViewController?

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
        if let webView = bridge?.webView {
            webView.navigationDelegate = self
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}

// MARK: - WKNavigationDelegate
extension AppDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage(webView)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage(webView)
    }

    private func loadOfflinePage(_ webView: WKWebView) {
    if let url = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "public") {
        webView.loadFileURL(url, allowingReadAccessTo: Bundle.main.bundleURL)
    }
}

}
