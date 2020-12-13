//
//  ExtensionsTests.swift
//  O323BGCTests
//
//  Created by Hugo Trippaers on 09/12/2020.
//

import XCTest
@testable import O323BGC

class ExtensionTests: XCTestCase {
    func testBitsExtensionForUInt8() {
        let testValue: UInt8 = 0b00001001
        
        XCTAssertTrue(testValue.bit(0), "Bit 0 should be set")
        XCTAssertFalse(testValue.bit(4), "Bit 4 should be unset")
    }

    func testBitsExtensionForUInt16() {
        let testValue: UInt16 = 0b0001100100100001
        
        XCTAssertTrue(testValue.bit(12), "Bit 12 should be set")
        XCTAssertFalse(testValue.bit(3), "Bit 3 should be unset")
    }
}
