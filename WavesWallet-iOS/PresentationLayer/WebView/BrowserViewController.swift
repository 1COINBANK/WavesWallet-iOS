//
//  WebViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 13/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import WebKit

final class BrowserViewController: UIViewController {
    
    let url: URL
    
    private var webView: WKWebView!
    private var loader: UIActivityIndicatorView!
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(sender:)))
        
        setupWebView()
        setupLoader()
        
        let myURL = url
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
    private func setupWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        
    }
    
    private func setupLoader() {
        
        loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loader.hidesWhenStopped = true
        loader.startAnimating()
        view.addSubview(loader)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        webView.frame = view.bounds
        loader.center = view.center
    }
    
    // MARK: - Content
    
    fileprivate func finishLoading() {
        loader.stopAnimating()
    }
    
    @objc func done(sender: Any) {
        dismiss(animated: true)
        
    }

}

extension BrowserViewController: WKUIDelegate {
    
    
    
}

extension BrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishLoading()
    }
    
}
