//
//  ViewController.swift
//  WKWebViewDemoApp
//
//  Created by Raymond Kim on 3/4/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    var ads: Dictionary<String, AdObserver> = [:]
    let webView: WKWebView

    required init?(coder: NSCoder) {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController

        // Inject JavaScript into the webpage. You can specify when your script will be injected and for
        // which frames–all frames or the main frame only.
//        let scriptSource = "window.webkit.messageHandlers.test.postMessage(`Hello, world!`);"
//        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        userContentController.addUserScript(userScript)

        webView = WKWebView(frame: .zero, configuration: config)

        super.init(coder: coder)

        // Add script message handlers that, when run, will make the function
        // window.webkit.messageHandlers.adPlaceholderTracker.postMessage() available in all frames.
        userContentController.add(self, name: "adPlaceholderTracker")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        view.addSubview(webView)

        let layoutGuide = view.safeAreaLayoutGuide

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true

        // Make sure in Info.plist you set `NSAllowsArbitraryLoads` to `YES` to load
        // URLs with an HTTP connection. You can run a local server easily with services
        // such as MAMP.
        if let url = URL(string: "http://localhost:8888/index.html") {
            webView.load(URLRequest(url: url))
        }
    }
}

enum ViewControllerError: Error {
    case unknownAdId(id: String, action: AdPlaceholderTrackerMessageAction)
    case addOrUpdateMessageWithoutRect(id: String, action: AdPlaceholderTrackerMessageAction)
}

extension ViewController: WKScriptMessageHandler {
    // Capture postMessage() calls inside loaded JavaScript from the webpage. Note that a Boolean
    // will be parsed as a 0 for false and 1 for true in the message's body. See WebKit documentation:
    // https://developer.apple.com/documentation/webkit/wkscriptmessage/1417901-body.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

//        print(message.body)

        do {
            let bodyData = Data((message.body as? String)!.utf8)
            let json = try JSONSerialization.jsonObject(with: bodyData) as! [String: Any]
            let message = try AdPlaceholderTrackerMessage(json: json)

            switch (message.action) {
            case AdPlaceholderTrackerMessageAction.add:
                guard let rect = message.rect else {
                    throw ViewControllerError.addOrUpdateMessageWithoutRect(id: message.id, action: message.action)
                }
                self.ads[message.id] = AdObserver(id: message.id, rect: rect, parent: webView)
            case AdPlaceholderTrackerMessageAction.update:
                guard let adObserver = self.ads[message.id] else {
                    throw ViewControllerError.unknownAdId(id: message.id, action: message.action)
                }
                guard let rect = message.rect else {
                    throw ViewControllerError.addOrUpdateMessageWithoutRect(id: message.id, action: message.action)
                }
                // TODO: only call `update()` when the values actually change
                adObserver.update(rect)
            case AdPlaceholderTrackerMessageAction.remove:
                guard self.ads[message.id] != nil else {
                    throw ViewControllerError.unknownAdId(id: message.id, action: message.action)
                }
                self.ads.removeValue(forKey: message.id)
            }
        } catch {
            print("Could not parse message body: \(message.body)")
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
      didCommit navigation: WKNavigation!) {
        self.ads.removeAll()
    }

    func webView(_ webView: WKWebView,
      didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("""
        window.postMessage('startTrackingAdPlaceholders');

        window.addEventListener('beforeunload', function () {
          window.postMessage('stopTrackingAdPlaceholders');
        });
        """)
    }
}
