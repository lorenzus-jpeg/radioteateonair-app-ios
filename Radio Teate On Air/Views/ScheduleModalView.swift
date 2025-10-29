
//
//  ScheduleModalView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//
import SwiftUI
import WebKit

struct ScheduleModalView: View {
    @StateObject private var cache = WebViewCache.shared
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if let html = cache.scheduleHTML {
                CachedWebView(html: html, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ScheduleWebView(isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)
            }
            
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.green)
                    Text("Caricamento palinsesto...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
        }
        .onAppear {
            if cache.scheduleHTML != nil {
                isLoading = false
            }
        }
    }
}

struct CachedWebView: UIViewRepresentable {
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
        var parent: CachedWebView
        
        init(_ parent: CachedWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}

struct ScheduleWebView: UIViewRepresentable {
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
        
        if let url = URL(string: "https://radioteateonair.it/palinsesto") {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ScheduleWebView
        
        init(_ parent: ScheduleWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let currentDay = getCurrentItalianDay()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let script = """
                (function() {
                    var dayMap = {
                        'lunedi': 'lunedi', 'martedi': 'martedi', 'mercoledi': 'mercoledi',
                        'giovedi': 'giovedi', 'venerdi': 'venerdi', 'sabato': 'sabato', 'domenica': 'domenica'
                    };
                    
                    var dayId = dayMap['\(currentDay)'];
                    var currentDayDiv = document.querySelector('#' + dayId);
                    
                    if (!currentDayDiv || currentDayDiv.innerHTML.trim().length === 0) {
                        document.body.innerHTML = '<p style="padding: 20px; text-align: center; font-family: sans-serif;">Gli show in programma oggi sono terminati! Ascolta comunque la nostra playlist selezionata!</p>';
                        return false;
                    }
                    
                    var head = document.head.cloneNode(true);
                    var clonedDiv = currentDayDiv.cloneNode(true);
                    clonedDiv.style.display = 'block';
                    
                    document.documentElement.innerHTML = '';
                    document.documentElement.appendChild(head);
                    
                    var newBody = document.createElement('body');
                    newBody.style.margin = '0';
                    newBody.style.padding = '0';
                    newBody.appendChild(clonedDiv);
                    
                    document.documentElement.appendChild(newBody);
                    return true;
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
        
        private func getCurrentItalianDay() -> String {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            let italianDays = [
                1: "domenica", 2: "lunedi", 3: "martedi", 4: "mercoledi",
                5: "giovedi", 6: "venerdi", 7: "sabato"
            ]
            return italianDays[weekday] ?? "lunedi"
        }
    }
}

#Preview {
    ScheduleModalView()
}
