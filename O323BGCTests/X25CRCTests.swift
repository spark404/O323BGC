//
//  X25CRCTests.swift
//  O323BGCTests
//
//  Created by Hugo Trippaers on 08/12/2020.
//

import XCTest
@testable import O323BGC

class X25CRCTests: XCTestCase {
    func testCalculate() {
        let x25CRC = X25CRC()
        
        let versionString =
            "76302e39360000000000000000000000" +
            "4f6c6c69572033323342474300000000" +
            "76312e33302046313033524300000000" +
            "60005f0003ff" // + "6eee6f"
        
        let input = versionString.hexaData
        let expected: UInt16 = 0xee6e
        
        let actual = x25CRC.calculate(data: input)
        XCTAssertEqual(actual, expected, "Checksums don't match")
    }
}
