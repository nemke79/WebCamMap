//
//  WebCameraLinkViewController.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 25/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit
import WebKit

class WebCameraLinkViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    var webCamURL: URL!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var viewForBackgroundWhileLoading: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "OrangeGradientBackground.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        viewForBackgroundWhileLoading.insertSubview(backgroundImage, at: 0)
        
        if let url = webCamURL {
            let request = URLRequest(url: url)
            print(url)
            webView.load(request)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        viewForBackgroundWhileLoading.fadeOut()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        viewForBackgroundWhileLoading.fadeOut()
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
