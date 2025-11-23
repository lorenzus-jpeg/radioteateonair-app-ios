
//
//  ContentView.swift
//  @author lorenzus-jpeg
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

struct BottomLine: Shape {
    var phase: CGFloat
    var lineHeight: CGFloat
    var frequency: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let lineCount = Int(frequency) + 1
        let spacing = width / CGFloat(lineCount)
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for i in 0...lineCount {
            let currentX = CGFloat(i) * spacing
            let normalizedX = CGFloat(i) / CGFloat(lineCount)
            let angle = (normalizedX * frequency * 2 * .pi) + (phase * 2 * .pi)
            let lineY = height - lineHeight - sin(angle) * (lineHeight * 0.4)
            
            path.addLine(to: CGPoint(x: currentX, y: lineY))
            if i < lineCount {
                path.addLine(to: CGPoint(x: currentX + spacing, y: lineY))
            }
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct BottomPeak: Shape {
    var phase: CGFloat
    var peakHeight: CGFloat
    var frequency: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let spacing = width / CGFloat(Int(frequency) + 1)
        
        path.move(to: CGPoint(x: 0, y: height))
        
        var currentX: CGFloat = 0
        let halfSpacing = spacing / 2
        
        while currentX <= width {
            let normalizedX = currentX / width
            let angle = (normalizedX * frequency * 2 * .pi) + (phase * 2 * .pi)
            let peakValue = abs(sin(angle))
            let peakY = height - (peakValue * peakHeight * 0.8)
            
            path.addLine(to: CGPoint(x: currentX, y: peakY))
            path.addLine(to: CGPoint(x: currentX + halfSpacing, y: height))
            
            currentX += spacing
        }
        
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

struct AnimatedBottomLine: View {
    let lineHeight: CGFloat
    let frequency: CGFloat
    let duration: Double
    let greenShade: Color
    let startPhase: CGFloat
    
    @State private var phase: CGFloat
    
    init(lineHeight: CGFloat, frequency: CGFloat, duration: Double, greenShade: Color, startPhase: CGFloat = 0) {
        self.lineHeight = lineHeight
        self.frequency = frequency
        self.duration = duration
        self.greenShade = greenShade
        self.startPhase = startPhase
        self._phase = State(initialValue: startPhase)
    }
    
    var body: some View {
        BottomLine(phase: phase, lineHeight: lineHeight, frequency: frequency)
            .fill(greenShade)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = startPhase + 1
                }
            }
    }
}

struct AnimatedBottomPeak: View {
    let peakHeight: CGFloat
    let frequency: CGFloat
    let duration: Double
    let greenShade: Color
    let startPhase: CGFloat
    
    @State private var phase: CGFloat
    
    init(peakHeight: CGFloat, frequency: CGFloat, duration: Double, greenShade: Color, startPhase: CGFloat = 0) {
        self.peakHeight = peakHeight
        self.frequency = frequency
        self.duration = duration
        self.greenShade = greenShade
        self.startPhase = startPhase
        self._phase = State(initialValue: startPhase)
    }
    
    var body: some View {
        BottomPeak(phase: phase, peakHeight: peakHeight, frequency: frequency)
            .fill(greenShade)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = startPhase + 1
                }
            }
    }
}

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var currentModal: ModalType?
    @AppStorage("backgroundStyle") var backgroundStyle: String = "onde"
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ZStack {
                if backgroundStyle == "onde" {
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
                } else if backgroundStyle == "linee" {
                    AnimatedBottomLine(
                        lineHeight: 280,
                        frequency: 2,
                        duration: 8,
                        greenShade: Color(red: 0, green: 0.3, blue: 0.1).opacity(0.3),
                        startPhase: 0
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 240,
                        frequency: 2.5,
                        duration: 7,
                        greenShade: Color(red: 0, green: 0.35, blue: 0.12).opacity(0.35),
                        startPhase: 0.1
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 320,
                        frequency: 1.8,
                        duration: 9,
                        greenShade: Color(red: 0, green: 0.4, blue: 0.15).opacity(0.4),
                        startPhase: 0.2
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 200,
                        frequency: 3,
                        duration: 6,
                        greenShade: Color(red: 0, green: 0.45, blue: 0.18).opacity(0.45),
                        startPhase: 0.3
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 360,
                        frequency: 1.5,
                        duration: 10,
                        greenShade: Color(red: 0, green: 0.5, blue: 0.2).opacity(0.5),
                        startPhase: 0.4
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 180,
                        frequency: 3.5,
                        duration: 5.5,
                        greenShade: Color(red: 0, green: 0.55, blue: 0.22).opacity(0.55),
                        startPhase: 0.5
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 260,
                        frequency: 2.2,
                        duration: 7.5,
                        greenShade: Color(red: 0, green: 0.6, blue: 0.25).opacity(0.6),
                        startPhase: 0.6
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 300,
                        frequency: 1.6,
                        duration: 8.5,
                        greenShade: Color(red: 0.05, green: 0.65, blue: 0.28).opacity(0.65),
                        startPhase: 0.7
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 220,
                        frequency: 2.8,
                        duration: 6.5,
                        greenShade: Color(red: 0.1, green: 0.7, blue: 0.3).opacity(0.7),
                        startPhase: 0.8
                    )
                    
                    AnimatedBottomLine(
                        lineHeight: 340,
                        frequency: 1.4,
                        duration: 9.5,
                        greenShade: Color(red: 0.15, green: 0.75, blue: 0.32).opacity(0.75),
                        startPhase: 0.9
                    )
                } else if backgroundStyle == "picchi" {
                    AnimatedBottomPeak(
                        peakHeight: 280,
                        frequency: 2,
                        duration: 8,
                        greenShade: Color(red: 0, green: 0.3, blue: 0.1).opacity(0.3),
                        startPhase: 0
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 240,
                        frequency: 2.5,
                        duration: 7,
                        greenShade: Color(red: 0, green: 0.35, blue: 0.12).opacity(0.35),
                        startPhase: 0.1
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 320,
                        frequency: 1.8,
                        duration: 9,
                        greenShade: Color(red: 0, green: 0.4, blue: 0.15).opacity(0.4),
                        startPhase: 0.2
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 200,
                        frequency: 3,
                        duration: 6,
                        greenShade: Color(red: 0, green: 0.45, blue: 0.18).opacity(0.45),
                        startPhase: 0.3
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 360,
                        frequency: 1.5,
                        duration: 10,
                        greenShade: Color(red: 0, green: 0.5, blue: 0.2).opacity(0.5),
                        startPhase: 0.4
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 180,
                        frequency: 3.5,
                        duration: 5.5,
                        greenShade: Color(red: 0, green: 0.55, blue: 0.22).opacity(0.55),
                        startPhase: 0.5
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 260,
                        frequency: 2.2,
                        duration: 7.5,
                        greenShade: Color(red: 0, green: 0.6, blue: 0.25).opacity(0.6),
                        startPhase: 0.6
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 300,
                        frequency: 1.6,
                        duration: 8.5,
                        greenShade: Color(red: 0.05, green: 0.65, blue: 0.28).opacity(0.65),
                        startPhase: 0.7
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 220,
                        frequency: 2.8,
                        duration: 6.5,
                        greenShade: Color(red: 0.1, green: 0.7, blue: 0.3).opacity(0.7),
                        startPhase: 0.8
                    )
                    
                    AnimatedBottomPeak(
                        peakHeight: 340,
                        frequency: 1.4,
                        duration: 9.5,
                        greenShade: Color(red: 0.15, green: 0.75, blue: 0.32).opacity(0.75),
                        startPhase: 0.9
                    )
                }
            }
            .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 0) {
                    Button(action: {
                        currentModal = .schedule
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
                    
                    Button(action: {
                        currentModal = .programs
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
                    
                    Button(action: {
                        currentModal = .whoWeAre
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
                    
                    Button(action: {
                        currentModal = .settings
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                            Text("OPZIONI")
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
                
                VStack {
                    Divider()
                        .background(Color.gray)
                    
                    HStack(spacing: 25) {
                        if audioManager.isPlaying {
                            Button(action: {
                                audioManager.togglePlayback()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .transition(.scale.combined(with: .opacity))
                            
                            VStack(alignment: .leading, spacing: 6) {
                                if let info = audioManager.songInfo {
                                    Text(info.song)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(info.artist)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("Caricamento...")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                        } else {
                            Spacer()
                            
                            Button(action: {
                                audioManager.togglePlayback()
                            }) {
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
                    .animation(.easeInOut(duration: 0.3), value: audioManager.isPlaying)
                }
                .background(Color.black.opacity(0.3))
                
                VStack {
                    Divider()
                        .background(Color.gray)
                    
                    Text("Seguici su")
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
                        
                        Link(destination: URL(string: "https://open.spotify.com/user/bdubob5m8sthl8504ab0xx88y")!) {
                            if let uiImage = UIImage(named: "social_spotify") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            } else {
                                Image(systemName: "music.note")
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
        .onAppear {
            WebViewCache.shared.prefetchAll()
        }
        .sheet(item: $currentModal) { modalType in
            ModalContentView(modalType: modalType)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
        }
    }
}

#Preview {
    ContentView()
}
