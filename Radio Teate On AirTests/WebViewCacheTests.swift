//
//  WebViewCacheTests.swift
//  Radio Teate On AirTests
//
//  Created by Lorenzo Cugini on 05/11/25.
//

import XCTest
@testable import Radio_Teate_On_Air

final class WebViewCacheTests: XCTestCase {
    
    var cache: WebViewCache!
    
    override func setUp() {
        super.setUp()
        cache = WebViewCache.shared
        // Reset cache state
        cache.scheduleHTML = nil
        cache.programsHTML = nil
        cache.scheduleReady = false
        cache.programsReady = false
    }
    
    // Test 1: Singleton pattern works correctly
    func testSingletonPattern() {
        let cache1 = WebViewCache.shared
        let cache2 = WebViewCache.shared
        XCTAssertTrue(cache1 === cache2, "WebViewCache should be a singleton")
    }
    
    // Test 2: Initial state is correct
    func testInitialState() {
        XCTAssertNil(cache.scheduleHTML, "Schedule HTML should be nil initially")
        XCTAssertNil(cache.programsHTML, "Programs HTML should be nil initially")
        XCTAssertFalse(cache.scheduleReady, "Schedule should not be ready")
        XCTAssertFalse(cache.programsReady, "Programs should not be ready")
    }
    
    // Test 3: HTML can be stored and retrieved correctly
    func testHTMLCaching() {
        let scheduleHTML = "<html><body>Schedule Content</body></html>"
        let programsHTML = "<html><body>Programs Content</body></html>"
        
        cache.scheduleHTML = scheduleHTML
        cache.programsHTML = programsHTML
        
        XCTAssertEqual(cache.scheduleHTML, scheduleHTML)
        XCTAssertEqual(cache.programsHTML, programsHTML)
    }
    
    // Test 4: Ready state can be toggled independently
    func testReadyStateManagement() {
        cache.scheduleReady = true
        cache.programsReady = false
        
        XCTAssertTrue(cache.scheduleReady)
        XCTAssertFalse(cache.programsReady, "States should be independent")
        
        cache.programsReady = true
        XCTAssertTrue(cache.scheduleReady)
        XCTAssertTrue(cache.programsReady)
    }
    
    // Test 5: Prefetch methods can be called without crashing
    func testPrefetchMethods() {
        // These should not throw or crash
        cache.prefetchAll()
        cache.prefetchSchedule()
        cache.prefetchPrograms()
        
        XCTAssertTrue(true, "All prefetch methods executed successfully")
    }
}