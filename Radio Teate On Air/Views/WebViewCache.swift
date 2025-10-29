
//
//  WebViewCache.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 29/10/25.
//

import Foundation
import WebKit

class WebViewCache: ObservableObject {
    static let shared = WebViewCache()
    
    @Published var scheduleHTML: String?
    @Published var programsHTML: String?
    @Published var scheduleReady = false
    @Published var programsReady = false
    
    private var scheduleWebView: WKWebView?
    private var programsWebView: WKWebView?
    
    private init() {}
    
    func prefetchAll() {
        prefetchSchedule()
        prefetchPrograms()
    }
    
    func prefetchSchedule() {
        let config = WKWebViewConfiguration()
        scheduleWebView = WKWebView(frame: .zero, configuration: config)
        
        guard let url = URL(string: "https://radioteateonair.it/palinsesto") else { return }
        scheduleWebView?.load(URLRequest(url: url))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.extractScheduleHTML()
        }
    }
    
    func prefetchPrograms() {
        let config = WKWebViewConfiguration()
        programsWebView = WKWebView(frame: .zero, configuration: config)
        
        guard let url = URL(string: "https://radioteateonair.it/programmi") else { return }
        programsWebView?.load(URLRequest(url: url))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.extractProgramsHTML()
        }
    }
    
    private func extractScheduleHTML() {
        let currentDay = getCurrentItalianDay()
        
        let script = """
        (function() {
            var dayMap = {
                'lunedi': 'lunedi', 'martedi': 'martedi', 'mercoledi': 'mercoledi',
                'giovedi': 'giovedi', 'venerdi': 'venerdi', 'sabato': 'sabato', 'domenica': 'domenica'
            };
            
            var dayId = dayMap['\(currentDay)'];
            var dayDiv = document.querySelector('#' + dayId);
            
            if (dayDiv && dayDiv.innerHTML.trim().length > 0) {
                var head = document.head.cloneNode(true);
                var headHTML = head.innerHTML;
                
                return '<!DOCTYPE html><html><head>' + headHTML + '</head><body style="margin:0;padding:0;">' + dayDiv.outerHTML + '</body></html>';
            }
            return null;
        })();
        """
        
        scheduleWebView?.evaluateJavaScript(script) { [weak self] result, error in
            if let html = result as? String {
                DispatchQueue.main.async {
                    self?.scheduleHTML = html
                    self?.scheduleReady = true
                    print("✅ Schedule cached")
                }
            }
        }
    }
    
    private func extractProgramsHTML() {
        let script = """
        (function() {
            var content = document.querySelector('[data-elementor-id="4947"]');
            
            if (!content) {
                return null;
            }
            
            var head = document.head.cloneNode(true);
            var headHTML = head.innerHTML;
            
            return '<!DOCTYPE html><html><head>' + headHTML + '</head><body style="margin:0;padding:0;">' + content.outerHTML + '</body></html>';
        })();
        """
        
        programsWebView?.evaluateJavaScript(script) { [weak self] result, error in
            if let html = result as? String {
                DispatchQueue.main.async {
                    self?.programsHTML = html
                    self?.programsReady = true
                    print("✅ Programs cached")
                }
            } else {
                print("❌ Programs extraction failed: \(error?.localizedDescription ?? "unknown")")
            }
        }
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
