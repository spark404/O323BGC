//
//  Storm32ParametersTests.swift
//  O323BGCTests
//
//  Created by Hugo Trippaers on 14/12/2020.
//

import XCTest
@testable import O323BGC

class Storm32ParametersTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsingParameterData() throws {
        let data = "ea01100e4605610014001e002003061814056e0014001e00cc01780584037b0032002800010000000e0000000000dd03000000000e00000000004701000000000e000100000018020000000000000e000000000000000a00040000000000e3feb60390012c0105000000000006fffa0090012c010600000000004afcb60390012c010700000001000500050000000000000000000200000000000000000000000000e80319000000190002000000fa0001002800320019001e00fa0000000300000000000100000001000e06000000000000050000000000000000004700430000000000dc054c046c0700000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff".hexaData
        let parameters = Storm32Parameters(data: data)
        
        XCTAssertNotNil(parameters, "Initializer failed (nil result)")
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testInitFailWithInvalidLength() throws {
        let dataWithCrc = "ea01100e4605610014001e002003061814056e0014001e00cc01780584037b0032002800010000000e0000000000dd03000000000e00000000004701000000000e000100000018020000000000000e000000000000000a00040000000000e3feb60390012c0105000000000006fffa0090012c010600000000004afcb60390012c010700000001000500050000000000000000000200000000000000000000000000e80319000000190002000000fa0001002800320019001e00fa0000000300000000000100000001000e06000000000000050000000000000000004700430000000000dc054c046c0700000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdcc46f".hexaData
        let parameters = Storm32Parameters(data: dataWithCrc)
        
        XCTAssertNil(parameters, "Expected initializer to fail")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
