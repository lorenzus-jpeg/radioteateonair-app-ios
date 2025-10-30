
//
//  ProgramsModalView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//
import SwiftUI
import WebKit

struct ProgramsModalView: View {
    @StateObject private var cache = WebViewCache.shared
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if let html = cache.programsHTML {
                CachedProgramsWebView(html: html, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ProgramsWebView(isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)
            }
            
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.green)
                    Text("Caricamento programmi...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
        }
        .onAppear {
            if cache.programsHTML != nil {
                isLoading = false
            }
        }
    }
}

struct CachedProgramsWebView: UIViewRepresentable {
    let html: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = true
        webView.backgroundColor = .white
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: URL(string: "https://radioteateonair.it"))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: CachedProgramsWebView
        
        init(_ parent: CachedProgramsWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let script = """
                (function() {
                    var header = document.querySelector('header');
                    if (header) header.remove();
                    
                    var footer = document.querySelector('footer');
                    if (footer) footer.remove();
                    
                    var nav = document.querySelector('nav');
                    if (nav) nav.remove();
                })();
                """
                
                webView.evaluateJavaScript(script) { result, error in
                    DispatchQueue.main.async {
                        self.parent.isLoading = false
                    }
                }
            }
        }
    }
}

struct ProgramsWebView: UIViewRepresentable {
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = true
        webView.backgroundColor = .white
        webView.alpha = 0
        
        if let url = URL(string: "https://radioteateonair.it/programmi") {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ProgramsWebView
        
        init(_ parent: ProgramsWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let script = """
                (function() {
                    var header = document.querySelector('header');
                    if (header) header.remove();
                    
                    var footer = document.querySelector('footer');
                    if (footer) footer.remove();
                    
                    var nav = document.querySelector('nav');
                    if (nav) nav.remove();
                })();
                """
                
                webView.evaluateJavaScript(script) { result, error in
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            webView.alpha = 1
                        }
                        self.parent.isLoading = false
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

#Preview {
    ProgramsModalView()
}
