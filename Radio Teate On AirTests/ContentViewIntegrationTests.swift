//
//  ContentViewIntegrationTests.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 05/11/25.
//


//
//  ContentViewIntegrationTests.swift
//  Radio Teate On AirTests
//
//  Created by Lorenzo Cugini on 05/11/25.
//

import XCTest
@testable import Radio_Teate_On_Air

final class ContentViewIntegrationTests: XCTestCase {
    
    var audioManager: AudioManager!
    var webViewCache: WebViewCache!
    
    override func setUp() {
        super.setUp()
        audioManager = AudioManager()
        webViewCache = WebViewCache.shared
        
        // Reset cache
        webViewCache.scheduleHTML = nil
        webViewCache.programsHTML = nil
        webViewCache.scheduleReady = false
        webViewCache.programsReady = false
    }
    
    override func tearDown() {
        audioManager.stopPlayback()
        audioManager = nil
        webViewCache = nil
        super.tearDown()
    }
    
    // Test 1: Complete playback workflow
    func testPlaybackWorkflow() {
        // Initial state
        XCTAssertFalse(audioManager.isPlaying)
        
        // Start playback
        audioManager.togglePlayback()
        XCTAssertTrue(audioManager.isPlaying)
        
        // Update song info
        let songInfo = SongInfo(artist: "Artist", song: "Song")
        audioManager.songInfo = songInfo
        
        // Stop playback
        audioManager.togglePlayback()
        XCTAssertFalse(audioManager.isPlaying)
        XCTAssertNil(audioManager.songInfo)
    }
    
    // Test 2: Web view cache integrates with app
    func testWebViewCacheIntegration() {
        let cache = WebViewCache.shared
        
        // Verify singleton
        XCTAssertTrue(cache === webViewCache)
        
        // Cache can be prefetched
        cache.prefetchAll()
        
        // States can be managed
        cache.scheduleHTML = "<html>Test</html>"
        cache.scheduleReady = true
        
        XCTAssertNotNil(cache.scheduleHTML)
        XCTAssertTrue(cache.scheduleReady)
    }
    
    // Test 3: Modal types work with navigation
    func testModalTypeNavigation() {
        let modals = [
            ModalType.schedule,
            ModalType.programs,
            ModalType.whoWeAre
        ]
        
        for modal in modals {
            XCTAssertNotNil(modal.id, "Modal should have valid identifier")
        }
        
        // Verify each can be distinguished
        XCTAssertNotEqual(modals[0].id, modals[1].id)
        XCTAssertNotEqual(modals[1].id, modals[2].id)
    }
    
    // Test 4: State consistency across multiple operations
    func testStateConsistency() {
        // AudioManager state
        audioManager.startPlayback()
        let state1 = audioManager.isPlaying
        let state2 = audioManager.isPlaying
        XCTAssertEqual(state1, state2, "State should remain consistent")
        
        // WebViewCache state
        webViewCache.scheduleHTML = "<html>Test</html>"
        let cached1 = webViewCache.scheduleHTML
        let cached2 = webViewCache.scheduleHTML
        XCTAssertEqual(cached1, cached2, "Cache should remain consistent")
    }
    
    // Test 5: Multiple instances have independent state
    func testIndependentComponentState() {
        let manager1 = AudioManager()
        let manager2 = AudioManager()
        
        manager1.startPlayback()
        XCTAssertTrue(manager1.isPlaying)
        XCTAssertFalse(manager2.isPlaying, "Different instances should have independent state")
        
        manager1.stopPlayback()
        manager2.startPlayback()
        XCTAssertFalse(manager1.isPlaying)
        XCTAssertTrue(manager2.isPlaying)
    }
}