
//
//  ContentView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/09/25.
//

import SwiftUI
import AVFoundation

struct SongInfo {
    var artist: String
    var song: String
}

struct BottomWave: Shape {
    var phase: CGFloat
    var waveHeight: CGFloat
    var frequency: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height - waveHeight
        
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 5) {
            let normalizedX = x / width
            let angle = (normalizedX * frequency * 2 * .pi) + (phase * 2 * .pi)
            let y = midHeight + sin(angle) * (waveHeight * 0.3)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: midHeight))
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct AnimatedBottomWave: View {
    let waveHeight: CGFloat
    let frequency: CGFloat
    let duration: Double
    let greenShade: Color
    let startPhase: CGFloat
    
    @State private var phase: CGFloat
    
    init(waveHeight: CGFloat, frequency: CGFloat, duration: Double, greenShade: Color, startPhase: CGFloat = 0) {
        self.waveHeight = waveHeight
        self.frequency = frequency
        self.duration = duration
        self.greenShade = greenShade
        self.startPhase = startPhase
        self._phase = State(initialValue: startPhase)
    }
    
    var body: some View {
        BottomWave(phase: phase, waveHeight: waveHeight, frequency: frequency)
            .fill(greenShade)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = startPhase + 1
                }
            }
    }
}

struct ContentView: View {
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var streamURL: String = "https://nr14.newradio.it:8663/radioteateonair"
    @State private var showModal = false
    @State private var currentModal: ModalType?
    @State private var songInfo: SongInfo?
    @State private var updateTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ZStack {
                AnimatedBottomWave(
                    waveHeight: 280,
                    frequency: 2,
                    duration: 8,
                    greenShade: Color(red: 0, green: 0.3, blue: 0.1).opacity(0.3),
                    startPhase: 0
                )
                
                AnimatedBottomWave(
                    waveHeight: 240,
                    frequency: 2.5,
                    duration: 7,
                    greenShade: Color(red: 0, green: 0.35, blue: 0.12).opacity(0.35),
                    startPhase: 0.1
                )
                
                AnimatedBottomWave(
                    waveHeight: 320,
                    frequency: 1.8,
                    duration: 9,
                    greenShade: Color(red: 0, green: 0.4, blue: 0.15).opacity(0.4),
                    startPhase: 0.2
                )
                
                AnimatedBottomWave(
                    waveHeight: 200,
                    frequency: 3,
                    duration: 6,
                    greenShade: Color(red: 0, green: 0.45, blue: 0.18).opacity(0.45),
                    startPhase: 0.3
                )
                
                AnimatedBottomWave(
                    waveHeight: 360,
                    frequency: 1.5,
                    duration: 10,
                    greenShade: Color(red: 0, green: 0.5, blue: 0.2).opacity(0.5),
                    startPhase: 0.4
                )
                
                AnimatedBottomWave(
                    waveHeight: 180,
                    frequency: 3.5,
                    duration: 5.5,
                    greenShade: Color(red: 0, green: 0.55, blue: 0.22).opacity(0.55),
                    startPhase: 0.5
                )
                
                AnimatedBottomWave(
                    waveHeight: 260,
                    frequency: 2.2,
                    duration: 7.5,
                    greenShade: Color(red: 0, green: 0.6, blue: 0.25).opacity(0.6),
                    startPhase: 0.6
                )
                
                AnimatedBottomWave(
                    waveHeight: 300,
                    frequency: 1.6,
                    duration: 8.5,
                    greenShade: Color(red: 0.05, green: 0.65, blue: 0.28).opacity(0.65),
                    startPhase: 0.7
                )
                
                AnimatedBottomWave(
                    waveHeight: 220,
                    frequency: 2.8,
                    duration: 6.5,
                    greenShade: Color(red: 0.1, green: 0.7, blue: 0.3).opacity(0.7),
                    startPhase: 0.8
                )
                
                AnimatedBottomWave(
                    waveHeight: 340,
                    frequency: 1.4,
                    duration: 9.5,
                    greenShade: Color(red: 0.15, green: 0.75, blue: 0.32).opacity(0.75),
                    startPhase: 0.9
                )
            }
            .ignoresSafeArea()
            
            VStack {
                // Top icons section
                HStack(spacing: 0) {
                    // Schedule icon - Left
                    Button(action: {
                        currentModal = .schedule
                        showModal = true
                    }) {
                        VStack(spacing: 8) {
                            if let uiImage = UIImage(named: "ic_schedule") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "calendar")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                            }
                            Text("PALINSESTO\nOGGI")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Programs icon - Center
                    Button(action: {
                        currentModal = .programs
                        showModal = true
                    }) {
                        VStack(spacing: 8) {
                            if let uiImage = UIImage(named: "ic_programs") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                            }
                            Text("PROGRAMMI")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Who We Are icon - Right
                    Button(action: {
                        currentModal = .whoWeAre
                        showModal = true
                    }) {
                        VStack(spacing: 8) {
                            if let uiImage = UIImage(named: "ic_whoweare") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                            }
                            Text("CHI SIAMO")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
                
                // Main content area with background image
                VStack(spacing: 20) {
                    if let uiImage = UIImage(named: "ic_rtoa_logo") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 300)
                            .opacity(0.8)
                    } else {
                        Image(systemName: "radio.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: 300, maxHeight: 300)
                    }
                }
                
                Spacer()
                
                // Music player controls at the bottom
                VStack {
                    Divider()
                        .background(Color.gray)
                    
                    HStack(spacing: 25) {
                        if isPlaying {
                            // Stop button on the left when playing
                            Button(action: togglePlayback) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .transition(.scale.combined(with: .opacity))
                            
                            // Song info on the right, left-aligned
                            VStack(alignment: .leading, spacing: 4) {
                                if let info = songInfo {
                                    Text(info.song)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(info.artist)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("Caricamento...")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                        } else {
                            // Play button centered when stopped
                            Spacer()
                            
                            Button(action: togglePlayback) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                            .transition(.scale.combined(with: .opacity))
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .animation(.easeInOut(duration: 0.3), value: isPlaying)
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
                        Link(destination: URL(string: "https://www.facebook.com/radioteateonair")!) {
                            if let uiImage = UIImage(named: "ic_facebook") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            } else {
                                Image(systemName: "f.square.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.instagram.com/radio_teateonair")!) {
                            if let uiImage = UIImage(named: "ic_instagram") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            } else {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.tiktok.com/@radioteateonair")!) {
                            if let uiImage = UIImage(named: "ic_tiktok") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            } else {
                                Image(systemName: "music.note.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.youtube.com/@radioteateonair4409")!) {
                            if let uiImage = UIImage(named: "ic_youtube") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
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
        .sheet(isPresented: $showModal) {
            if let modalType = currentModal {
                ModalContentView(modalType: modalType)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
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
        guard !streamURL.isEmpty, let url = URL(string: streamURL) else {
            print("Invalid or empty stream URL")
            return
        }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        // Start updating song info
        startSongInfoUpdater()
    }
    
    private func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
        songInfo = nil
        
        // Stop the timer
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func startSongInfoUpdater() {
        // Fetch immediately
        fetchSongInfo()
        
        // Then update every 10 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            fetchSongInfo()
        }
    }
    
    private func fetchSongInfo() {
        let jsonUrl = "https://nr14.newradio.it:8663/status-json.xsl"
        
        guard let url = URL(string: jsonUrl) else {
            print("❌ Invalid JSON URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching song info: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let icestats = json["icestats"] as? [String: Any],
                   let source = icestats["source"] as? [String: Any],
                   let fullTitle = source["yp_currently_playing"] as? String {
                    
                    print("🎵 Full title: \(fullTitle)")
                    
                    // Split by " - " to get artist and song
                    let parts = fullTitle.components(separatedBy: " - ")
                    let artist = parts.first?.trimmingCharacters(in: .whitespaces) ?? "Artista sconosciuto"
                    let song = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : "Titolo sconosciuto"
                    
                    DispatchQueue.main.async {
                        self.songInfo = SongInfo(artist: artist, song: song)
                        print("✅ Song info updated: \(artist) - \(song)")
                    }
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    ContentView()
}
