//
//  WebCameraLinkViewController.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 25/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit
import WebKit

class WebCameraLinkViewController: UIViewController, WKUIDelegate, WKNavigationDelegate
{
    @IBOutlet weak var webView: WKWebView!
    
    var webCamURL: URL!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var viewForBackgroundWhileLoading: UIView!
    
    var newView: WKWebView!
    
    // MARK: ViewController lifecycle methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "OrangeGradientBackground.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        viewForBackgroundWhileLoading.insertSubview(backgroundImage, at: 0)
        
        if let url = webCamURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // view needs to reload when coming back from another app, else we will have messed up view, so we use NSNotification.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    @objc func willEnterForeground(_ notification: NSNotification) {
        webView.reload()
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    //When loading webview and scren is rotating at the same time avoid messed view.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if progressView.isHidden == false {
            webView?.reload()
        }
    }
    
    // MARK: WebView methods.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        viewForBackgroundWhileLoading.fadeOut()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        viewForBackgroundWhileLoading.fadeOut()
    }
    
    // This handles target=_blank links by opening them in the new view.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        //Need check for navigationAction.request.url! != webCamURL to avoid white screen and overlapping views.
        if navigationAction.targetFrame == nil, navigationAction.request.url! != webCamURL {
            newView = WKWebView.init(frame: webView.frame, configuration: configuration)
            
            newView.customUserAgent = webView.customUserAgent
            newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            newView.navigationDelegate = self
            newView.uiDelegate = self
            
            self.view.addSubview(newView)
            
            newView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            newView.configuration.preferences.javaScriptEnabled = true
            newView.load(navigationAction.request)
            
            return newView
        }
        return nil
    }
    
    // When popup for addthis is closed by x button, close popup.
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        newView = nil
    }
    
    // Open long tapped event on short tap to avoid error, open links, also open mailapp when user taps on mail icon.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        let url = navigationAction.request.url?.absoluteString
        let urlElements = url?.components(separatedBy: ":") ?? []
        
        switch urlElements[0] {
        case "mailto":
            UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        default:
            switch navigationAction.navigationType {
            case .linkActivated:
                webView.load(URLRequest(url: navigationAction.request.url!))
                decisionHandler(.cancel)
                return
            default:
                break
            }
        }
        decisionHandler(.allow)
    }
}

extension UIView {
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0

        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }) { (completed) in
            self.isHidden = true
            completion(true)
        }
    }
}
