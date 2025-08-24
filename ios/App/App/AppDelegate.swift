import UIKit
import Capacitor
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var webView: WKWebView?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Inicializa o bridge do Capacitor
        let bridgeViewController = CAPBridgeViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = bridgeViewController
        self.window?.makeKeyAndVisible()
        self.webView = bridgeViewController.webView

        // Define o fallback offline direto no WKWebView
        webView?.navigationDelegate = self

        return true
    }

    // MARK: - App Lifecycle
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

    // MARK: - Open URLs
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        return ApplicationDelegateProxy.shared.application(
            application,
            continue: userActivity,
            restorationHandler: restorationHandler
        )
    }
}

// MARK: - WKNavigationDelegate
extension AppDelegate: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadOfflinePage()
    }

    private func loadOfflinePage() {
        if let offlinePath = Bundle.main.path(forResource: "offline", ofType: "html", inDirectory: "public") {
            let offlineURL = URL(fileURLWithPath: offlinePath)
            webView?.loadFileURL(offlineURL, allowingReadAccessTo: offlineURL.deletingLastPathComponent())
        } else {
            print("⚠️ offline.html não encontrado no bundle")
        }
    }
}
