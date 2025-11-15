//
//  ModalTypeTests.swift
//  Radio Teate On AirTests
//
//  Created by Lorenzo Cugini on 05/11/25.
//

import XCTest
@testable import Radio_Teate_On_Air

final class ModalTypeTests: XCTestCase {
    
    // Test 1: All modal cases can be instantiated
    func testModalCaseCreation() {
        let schedule = ModalType.schedule
        let programs = ModalType.programs
        let whoWeAre = ModalType.whoWeAre
        
        XCTAssertNotNil(schedule)
        XCTAssertNotNil(programs)
        XCTAssertNotNil(whoWeAre)
    }
    
    // Test 2: Each modal has correct unique identifier
    func testModalIdentifiers() {
        XCTAssertEqual(ModalType.schedule.id, "schedule")
        XCTAssertEqual(ModalType.programs.id, "programs")
        XCTAssertEqual(ModalType.whoWeAre.id, "whoWeAre")
    }
    
    // Test 3: All identifiers are unique (no duplicates)
    func testIdentifiersAreUnique() {
        let identifiers = Set([
            ModalType.schedule.id,
            ModalType.programs.id,
            ModalType.whoWeAre.id
        ])
        
        XCTAssertEqual(identifiers.count, 3, "All identifiers must be unique")
    }
    
    // Test 4: Modal types conform to Identifiable protocol
    func testIdentifiableConformance() {
        let schedule: any Identifiable = ModalType.schedule
        let programs: any Identifiable = ModalType.programs
        let whoWeAre: any Identifiable = ModalType.whoWeAre
        
        XCTAssertNotNil(schedule.id)
        XCTAssertNotNil(programs.id)
        XCTAssertNotNil(whoWeAre.id)
    }
    
    // Test 5: Modal equality works correctly
    func testModalEquality() {
        let schedule1 = ModalType.schedule
        let schedule2 = ModalType.schedule
        let programs = ModalType.programs
        
        XCTAssertEqual(schedule1, schedule2, "Same cases should be equal")
        XCTAssertNotEqual(schedule1, programs, "Different cases should not be equal")
    }
}