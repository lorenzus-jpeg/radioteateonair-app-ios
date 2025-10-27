
//
//  ProgramsModalView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//
import SwiftUI
import WebKit

struct ProgramsModalView: View {
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            FilteredWebView(isLoading: $isLoading)
                .ignoresSafeArea(edges: .bottom)
            
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
    }
}

struct FilteredWebView: UIViewRepresentable {
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
        var parent: FilteredWebView
        
        init(_ parent: FilteredWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Pagina caricata, applico filtro...")
            
            // JavaScript to keep only the div with data-elementor-id="4947"
            let script = """
            (function() {
                // Find the target div
                var targetDiv = document.querySelector('[data-elementor-id="4947"]');
                
                if (targetDiv) {
                    console.log('Target div found');
                    
                    // Clone the target div
                    var clone = targetDiv.cloneNode(true);
                    
                    // Clear the body
                    document.body.innerHTML = '';
                    
                    // Add the cloned div back
                    document.body.appendChild(clone);
                    
                    // Remove unnecessary elements
                    document.querySelectorAll('script').forEach(function(el) {
                        if (!el.src.includes('elementor')) {
                            el.remove();
                        }
                    });
                    
                    console.log('Filtering complete');
                } else {
                    console.log('Target div not found');
                    document.body.innerHTML = '<p style="padding: 20px; text-align: center;">Contenuto non trovato</p>';
                }
            })();
            """
            
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("❌ Errore JavaScript: \(error.localizedDescription)")
                } else {
                    print("✅ Filtro applicato con successo")
                }
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        webView.alpha = 1
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.parent.isLoading = false
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Errore caricamento: \(error.localizedDescription)")
            parent.isLoading = false
        }
    }
}

#Preview {
    ProgramsModalView()
}
