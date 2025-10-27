
//
//  AudioManager.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var songInfo: SongInfo?
    
    private var player: AVPlayer?
    private var updateTimer: Timer?
    private let streamURL = "https://nr14.newradio.it:8663/radioteateonair"
    
    init() {
        setupAudioSession()
        setupRemoteControls()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            print("✅ Audio session configured for background playback")
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    func startPlayback() {
        guard let url = URL(string: streamURL) else {
            print("Invalid stream URL")
            return
        }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        setupNowPlayingInfo()
        startSongInfoUpdater()
    }
    
    func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
        songInfo = nil
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Radio Teate On Air"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Live Stream"
        
        if let logoImage = UIImage(named: "ic_rtoa_logo") {
            let artwork = MPMediaItemArtwork(boundsSize: logoImage.size) { _ in logoImage }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if !self.isPlaying {
                self.startPlayback()
            }
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.stopPlayback()
            }
            return .success
        }
        
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.stopPlayback()
            }
            return .success
        }
    }
    
    private func startSongInfoUpdater() {
        fetchSongInfo()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.fetchSongInfo()
        }
    }
    
    private func fetchSongInfo() {
        let jsonUrl = "https://nr14.newradio.it:8663/status-json.xsl"
        
        guard let url = URL(string: jsonUrl) else {
            print("❌ Invalid JSON URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
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
                    
                    let parts = fullTitle.components(separatedBy: " - ")
                    let artist = parts.first?.trimmingCharacters(in: .whitespaces) ?? "Artista sconosciuto"
                    let song = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : "Titolo sconosciuto"
                    
                    DispatchQueue.main.async {
                        self?.songInfo = SongInfo(artist: artist, song: song)
                        self?.updateNowPlayingInfo(artist: artist, song: song)
                        print("✅ Song info updated: \(artist) - \(song)")
                    }
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func updateNowPlayingInfo(artist: String, song: String) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
