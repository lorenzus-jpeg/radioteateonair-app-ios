//
//  AudioManagerTests.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 05/11/25.
//


//
//  AudioManagerTests.swift
//  Radio Teate On AirTests
//
//  Created by Lorenzo Cugini on 05/11/25.
//

import XCTest
@testable import Radio_Teate_On_Air
import AVFoundation

final class AudioManagerTests: XCTestCase {
    
    var audioManager: AudioManager!
    
    override func setUp() {
        super.setUp()
        audioManager = AudioManager()
    }
    
    override func tearDown() {
        audioManager.stopPlayback()
        audioManager = nil
        super.tearDown()
    }
    
    // Test 1: Initial state is correct (not playing, no song info)
    func testInitialState() {
        XCTAssertFalse(audioManager.isPlaying, "Should not be playing on init")
        XCTAssertNil(audioManager.songInfo, "SongInfo should be nil initially")
    }
    
    // Test 2: Playback toggle works (start/stop cycle)
    func testPlaybackToggle() {
        // Start playing
        audioManager.togglePlayback()
        XCTAssertTrue(audioManager.isPlaying, "Should be playing after toggle")
        
        // Stop playing
        audioManager.togglePlayback()
        XCTAssertFalse(audioManager.isPlaying, "Should stop after second toggle")
    }
    
    // Test 3: Direct start/stop methods work independently
    func testDirectPlaybackControl() {
        audioManager.startPlayback()
        XCTAssertTrue(audioManager.isPlaying, "Should play after startPlayback()")
        
        audioManager.stopPlayback()
        XCTAssertFalse(audioManager.isPlaying, "Should stop after stopPlayback()")
        XCTAssertNil(audioManager.songInfo, "SongInfo cleared on stop")
    }
    
    // Test 4: Song info updates and persists correctly
    func testSongInfoManagement() {
        let testSong = SongInfo(artist: "Test Artist", song: "Test Song")
        
        audioManager.startPlayback()
        audioManager.songInfo = testSong
        
        XCTAssertEqual(audioManager.songInfo?.artist, "Test Artist")
        XCTAssertEqual(audioManager.songInfo?.song, "Test Song")
    }
    
    // Test 5: Audio session is properly configured
    func testAudioSessionConfiguration() {
        let audioSession = AVAudioSession.sharedInstance()
        XCTAssertTrue(audioSession.availableCategories.contains(.playback),
                     "Playback category should be available")
    }
}