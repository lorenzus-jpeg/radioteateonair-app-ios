
//
//  ScheduleModalView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//
import SwiftUI
import WebKit

struct ScheduleModalView: View {
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScheduleWebView(isLoading: $isLoading)
                .ignoresSafeArea(edges: .bottom)
            
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
            print("🔄 Starting to load schedule page...")
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Pagina palinsesto caricata, attendo caricamento completo...")
            
            let currentDay = getCurrentItalianDay()
            print("📅 Giorno corrente: \(currentDay)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let script = """
                (function() {
                    var dayMap = {
                        'lunedi': 'lunedi',
                        'martedi': 'martedi',
                        'mercoledi': 'mercoledi',
                        'giovedi': 'giovedi',
                        'venerdi': 'venerdi',
                        'sabato': 'sabato',
                        'domenica': 'domenica'
                    };
                    
                    var currentDay = '\(currentDay)';
                    var dayId = dayMap[currentDay];
                    
                    console.log('Looking for day: ' + dayId);
                    
                    // Find the current day div
                    var currentDayDiv = document.querySelector('#' + dayId);
                    
                    if (!currentDayDiv) {
                        console.log('Day div not found: ' + dayId);
                        document.body.innerHTML = '<p style="padding: 20px; text-align: center; font-family: sans-serif;">Gli show in programma oggi sono terminati! Ascolta comunque la nostra playlist selezionata!</p>';
                        return false;
                    }
                    
                    console.log('Day div found: ' + dayId);
                    
                    // Check if it has content
                    var hasContent = currentDayDiv.innerHTML.trim().length > 0;
                    if (!hasContent) {
                        console.log('Day div is empty');
                        document.body.innerHTML = '<p style="padding: 20px; text-align: center; font-family: sans-serif;">Gli show in programma oggi sono terminati! Ascolta comunque la nostra playlist selezionata!</p>';
                        return false;
                    }
                    
                    // Clone the head to keep all CSS
                    var head = document.head.cloneNode(true);
                    
                    // Clone only the current day div
                    var clonedDiv = currentDayDiv.cloneNode(true);
                    clonedDiv.style.display = 'block';
                    
                    // Clear the document
                    document.documentElement.innerHTML = '';
                    
                    // Rebuild with head (CSS) and only current day
                    document.documentElement.appendChild(head);
                    
                    var newBody = document.createElement('body');
                    newBody.style.margin = '0';
                    newBody.style.padding = '0';
                    newBody.appendChild(clonedDiv);
                    
                    document.documentElement.appendChild(newBody);
                    
                    console.log('✅ Parsing complete - showing only ' + dayId);
                    return true;
                })();
                """
                
                webView.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        print("❌ Errore JavaScript: \(error.localizedDescription)")
                    } else if let success = result as? Bool {
                        print(success ? "✅ Filtro applicato" : "⚠️ Nessun contenuto")
                    }
                    
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
            print("❌ Errore caricamento: \(error.localizedDescription)")
            parent.isLoading = false
        }
        
        private func getCurrentItalianDay() -> String {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            
            let italianDays = [
                1: "domenica",
                2: "lunedi",
                3: "martedi",
                4: "mercoledi",
                5: "giovedi",
                6: "venerdi",
                7: "sabato"
            ]
            
            return italianDays[weekday] ?? "lunedi"
        }
    }
}

#Preview {
    ScheduleModalView()
}
