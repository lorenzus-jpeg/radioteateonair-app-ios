
//
//  ContentView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/09/25.
//

import SwiftUI
import AVFoundation

struct BottomWave: Shape {
    var offset: CGFloat
    var waveHeight: CGFloat
    var frequency: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: height))
        
        // Draw wave at the top
        for x in stride(from: 0, through: width * 2, by: 5) {
            let relativeX = (x / width) - offset
            let sine = sin(relativeX * .pi * frequency)
            let y = height - waveHeight - (sine * waveHeight * 0.3)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Complete the shape by going to bottom right and back
        path.addLine(to: CGPoint(x: width * 2, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct AnimatedBottomWave: View {
    let waveHeight: CGFloat
    let frequency: CGFloat
    let duration: Double
    let greenShade: Color
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            BottomWave(offset: offset, waveHeight: waveHeight, frequency: frequency)
                .fill(greenShade)
                .frame(width: geometry.size.width * 2)
                .offset(x: -geometry.size.width * offset)
                .onAppear {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        offset = 1
                    }
                }
        }
    }
}

struct ContentView: View {
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var streamURL: String = "" // You'll provide this later
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Animated green waves from bottom
            ZStack {
                // Multiple layers of waves with different heights and speeds
                AnimatedBottomWave(
                    waveHeight: 280,
                    frequency: 2,
                    duration: 8,
                    greenShade: Color(red: 0, green: 0.3, blue: 0.1)
                )
                
                AnimatedBottomWave(
                    waveHeight: 240,
                    frequency: 2.5,
                    duration: 7,
                    greenShade: Color(red: 0, green: 0.35, blue: 0.12)
                )
                
                AnimatedBottomWave(
                    waveHeight: 320,
                    frequency: 1.8,
                    duration: 9,
                    greenShade: Color(red: 0, green: 0.4, blue: 0.15)
                )
                
                AnimatedBottomWave(
                    waveHeight: 200,
                    frequency: 3,
                    duration: 6,
                    greenShade: Color(red: 0, green: 0.45, blue: 0.18)
                )
                
                AnimatedBottomWave(
                    waveHeight: 360,
                    frequency: 1.5,
                    duration: 10,
                    greenShade: Color(red: 0, green: 0.5, blue: 0.2)
                )
                
                AnimatedBottomWave(
                    waveHeight: 180,
                    frequency: 3.5,
                    duration: 5.5,
                    greenShade: Color(red: 0, green: 0.55, blue: 0.22)
                )
                
                AnimatedBottomWave(
                    waveHeight: 260,
                    frequency: 2.2,
                    duration: 7.5,
                    greenShade: Color(red: 0, green: 0.6, blue: 0.25)
                )
                
                AnimatedBottomWave(
                    waveHeight: 300,
                    frequency: 1.6,
                    duration: 8.5,
                    greenShade: Color(red: 0.05, green: 0.65, blue: 0.28)
                )
                
                AnimatedBottomWave(
                    waveHeight: 220,
                    frequency: 2.8,
                    duration: 6.5,
                    greenShade: Color(red: 0.1, green: 0.7, blue: 0.3)
                )
                
                AnimatedBottomWave(
                    waveHeight: 340,
                    frequency: 1.4,
                    duration: 9.5,
                    greenShade: Color(red: 0.15, green: 0.75, blue: 0.32)
                )
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Main content area with background image
                VStack(spacing: 20) {
                    // Background image - YOUR IMAGE IS HERE
                    Group {
                        if let uiImage = UIImage(named: "ic_rtoa_logo") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 200, maxHeight: 200)
                                .opacity(0.8)
                        } else {
                            // Fallback placeholder when image is not found
                            Image(systemName: "radio.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: 200, maxHeight: 200)
                        }
                    }
                    
                    Text("Radio Teate On Air")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if isPlaying {
                        Text("Now Playing...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Music player controls at the bottom
                VStack {
                    Divider()
                        .background(Color.gray)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(isPlaying ? Color.red : Color.green)
                                .clipShape(Circle())
                        }
                        .scaleEffect(isPlaying ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPlaying)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
                .background(Color.black.opacity(0.3))
                
                // Social media icons
                VStack {
                    Divider()
                        .background(Color.gray)
                    
                    Text("Follow Us")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    HStack(spacing: 30) {
                        // Facebook
                        Button(action: { openURL("https://www.facebook.com/radioteateonair") }) {
                            Image(systemName: "globe")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                                .frame(width: 40, height: 40)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        // Instagram
                        Button(action: { openURL("https://www.instagram.com/radio_teateonair") }) {
                            Image(systemName: "camera")
                                .font(.system(size: 24))
                                .foregroundColor(.pink)
                                .frame(width: 40, height: 40)
                                .background(Color.pink.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        // TikTok
                        Button(action: { openURL("https://www.tiktok.com/@radioteateonair") }) {
                            Image(systemName: "music.note")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // YouTube
                        Button(action: { openURL("https://www.youtube.com/@radioteateonair4409") }) {
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                                .frame(width: 40, height: 40)
                                .background(Color.red.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 15)
                }
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        // This is where you'll use the URL you provide later
        guard !streamURL.isEmpty, let url = URL(string: streamURL) else {
            print("Invalid or empty stream URL")
            return
        }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }
    
    private func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: "https://\(urlString)") else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    ContentView()
}
