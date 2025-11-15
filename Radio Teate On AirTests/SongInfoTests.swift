//
//  SongInfoTests.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 05/11/25.
//


//
//  SongInfoTests.swift
//  Radio Teate On AirTests
//
//  Created by Lorenzo Cugini on 05/11/25.
//

import XCTest
@testable import Radio_Teate_On_Air

final class SongInfoTests: XCTestCase {
    
    // Test 1: Basic initialization and property storage
    func testInitializationAndProperties() {
        let songInfo = SongInfo(artist: "The Beatles", song: "Hey Jude")
        
        XCTAssertEqual(songInfo.artist, "The Beatles")
        XCTAssertEqual(songInfo.song, "Hey Jude")
    }
    
    // Test 2: Handles empty strings gracefully
    func testEmptyStringHandling() {
        let emptyArtist = SongInfo(artist: "", song: "Test Song")
        let emptySong = SongInfo(artist: "Test Artist", song: "")
        let bothEmpty = SongInfo(artist: "", song: "")
        
        XCTAssertEqual(emptyArtist.artist, "")
        XCTAssertEqual(emptySong.song, "")
        XCTAssertEqual(bothEmpty.artist, "")
        XCTAssertEqual(bothEmpty.song, "")
    }
    
    // Test 3: Supports special characters and unicode
    func testSpecialCharactersAndUnicode() {
        let specialChars = SongInfo(artist: "Artista - Speciale #1", song: "Canzone - Bella")
        let withEmoji = SongInfo(artist: "Artist 🎤", song: "Song 🎵")
        let italian = SongInfo(artist: "Artista Italiano", song: "Canzone Bella")
        
        XCTAssertEqual(specialChars.artist, "Artista - Speciale #1")
        XCTAssertEqual(withEmoji.song, "Song 🎵")
        XCTAssertEqual(italian.artist, "Artista Italiano")
    }
    
    // Test 4: Handles long strings without issues
    func testLongStringHandling() {
        let longArtist = String(repeating: "A", count: 500)
        let longSong = String(repeating: "S", count: 500)
        let songInfo = SongInfo(artist: longArtist, song: longSong)
        
        XCTAssertEqual(songInfo.artist.count, 500)
        XCTAssertEqual(songInfo.song.count, 500)
    }
    
    // Test 5: Equality comparison works correctly
    func testEqualityComparison() {
        let song1 = SongInfo(artist: "Artist", song: "Song")
        let song2 = SongInfo(artist: "Artist", song: "Song")
        let song3 = SongInfo(artist: "Different Artist", song: "Song")
        
        XCTAssertEqual(song1, song2, "Identical SongInfo should be equal")
        XCTAssertNotEqual(song1, song3, "Different SongInfo should not be equal")
    }
}