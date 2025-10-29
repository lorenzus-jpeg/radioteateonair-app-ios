
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
        setupNotificationObservers()
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
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            print("🔔 Audio interruption began")
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && isPlaying {
                print("🔔 Resuming playback after interruption")
                player?.play()
            }
        @unknown default:
            break
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
            print("❌ Invalid stream URL")
            return
        }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        // CRITICAL: Setup Now Playing IMMEDIATELY when starting playback
        // This creates the notification with controls
        setupNowPlayingInfo()
        startSongInfoUpdater()
        
        print("▶️ Playback started - Now Playing notification active")
    }
    
    func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
        songInfo = nil
        
        // Clear the Now Playing notification
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        updateTimer?.invalidate()
        updateTimer = nil
        
        print("⏹️ Playback stopped - Now Playing notification cleared")
    }
    
    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        // Basic info - this shows in the notification
        nowPlayingInfo[MPMediaItemPropertyTitle] = songInfo?.song ?? "Radio Teate On Air"
        nowPlayingInfo[MPMediaItemPropertyArtist] = songInfo?.artist ?? "Live Stream"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Radio Teate On Air"
        
        // CRITICAL: Mark as live stream (no progress bar)
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 0
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        
        // Playback rate - MUST be set for controls to work
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Add artwork (logo) to the notification
        if let logoImage = UIImage(named: "ic_rtoa_logo") {
            let artwork = MPMediaItemArtwork(boundsSize: logoImage.size) { _ in logoImage }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        // Update the Now Playing Center
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        print("📱 Now Playing notification updated")
    }
    
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Remove all existing targets first to avoid duplicates
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        
        // PLAY button in notification/lock screen
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            print("🎵 Remote: Play command received")
            guard let self = self else { return .commandFailed }
            if !self.isPlaying {
                self.startPlayback()
            }
            return .success
        }
        
        // PAUSE button in notification/lock screen
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            print("⏸️ Remote: Pause command received")
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.stopPlayback()
            }
            return .success
        }
        
        // STOP button (some devices)
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] event in
            print("⏹️ Remote: Stop command received")
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.stopPlayback()
            }
            return .success
        }
        
        // Toggle Play/Pause (when user taps the notification)
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
            print("🔄 Remote: Toggle Play/Pause command received")
            guard let self = self else { return .commandFailed }
            self.togglePlayback()
            return .success
        }
        
        // Disable skip/seek commands (not applicable for live radio)
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
        
        print("✅ Remote controls configured (Play, Pause, Stop)")
    }
    
    private func startSongInfoUpdater() {
        // Fetch immediately
        fetchSongInfo()
        
        // Then update every 10 seconds
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
                        // Update the notification with new song info
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
        // Get existing info or create new
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        
        // Update song and artist
        nowPlayingInfo[MPMediaItemPropertyTitle] = song
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Radio Teate On Air"
        
        // CRITICAL: Keep these values to maintain live stream behavior
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 0
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Keep the artwork if it exists
        if nowPlayingInfo[MPMediaItemPropertyArtwork] == nil,
           let logoImage = UIImage(named: "ic_rtoa_logo") {
            let artwork = MPMediaItemArtwork(boundsSize: logoImage.size) { _ in logoImage }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        // Update Now Playing Center
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        print("📱 Now Playing notification updated with: \(song) - \(artist)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
        
        // Clean up remote commands
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
    }
}
