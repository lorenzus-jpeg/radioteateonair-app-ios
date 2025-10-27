
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
            
            // Get current day in Italian
            let currentDay = getCurrentItalianDay()
            print("📅 Giorno corrente: \(currentDay)")
            
            // Wait a bit more for dynamic content to load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // JavaScript to keep only the schedule and show current day
                let script = """
                (function() {
                    // Map of Italian day names to IDs
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
                    
                    console.log('Current day: ' + currentDay);
                    console.log('Day ID: ' + dayId);
                    
                    // Find the schedule refresh container
                    var scheduleContainer = document.querySelector('.qt-schedule-refresh');
                    
                    if (scheduleContainer) {
                        console.log('Schedule container found');
                        
                        // Clone it
                        var clone = scheduleContainer.cloneNode(true);
                        
                        // In the clone, hide all days
                        var allDays = clone.querySelectorAll('.qt-show-schedule-day');
                        console.log('Found ' + allDays.length + ' day elements');
                        allDays.forEach(function(day) {
                            day.style.display = 'none';
                        });
                        
                        // Show only the current day
                        var currentDayElement = clone.querySelector('#' + dayId);
                        if (currentDayElement) {
                            currentDayElement.style.display = 'block';
                            console.log('Showing day: ' + dayId);
                        } else {
                            console.log('Day element not found: ' + dayId);
                        }
                        
                        // Hide the day selector
                        var selector = clone.querySelector('#qwShowSelector');
                        if (selector) {
                            selector.style.display = 'none';
                            console.log('Day selector hidden');
                        }
                        
                        // Get the head for CSS
                        var head = document.head.cloneNode(true);
                        
                        // Clear everything and rebuild
                        document.documentElement.innerHTML = '';
                        document.documentElement.appendChild(head);
                        
                        var newBody = document.createElement('body');
                        newBody.appendChild(clone);
                        document.documentElement.appendChild(newBody);
                        
                        console.log('Filtering complete');
                    } else {
                        console.log('Schedule container not found');
                        document.body.innerHTML = '<p style="padding: 20px; text-align: center;">Gli show in programma oggi sono terminati! Ascolta comunque la nostra playlist selezionata!</p>';
                    }
                })();
                """
                
                webView.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        print("❌ Errore JavaScript: \(error.localizedDescription)")
                    } else {
                        print("✅ Filtro palinsesto applicato con successo")
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
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Errore caricamento: \(error.localizedDescription)")
            parent.isLoading = false
        }
        
        private func getCurrentItalianDay() -> String {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            
            // weekday: 1 = Sunday, 2 = Monday, etc.
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
