//
//  WebViewWrapper.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//


//
//  WebView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//

import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .white
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .white
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}