//
//  S32ParameterControllerTests.swift
//  O323BGCTests
//
//  Created by Hugo Trippaers on 17/12/2020.
//

import XCTest
@testable import O323BGC

class S32ParameterControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRetrieveParameters() throws {
        let underTest = S32ParameterController(storm32BGC: Storm32BGCSimulator(fileDescriptor: -1))
        
        let actual = underTest.retrieveParameters()
        
        XCTAssertNotNil(actual, "Failed to retrieve parameters")
        XCTAssertGreaterThan(actual!.count, 0, "No parameters returned from device")
    }

    func testRetrieveParameterByName() throws {
        let underTest = S32ParameterController(storm32BGC: Storm32BGCSimulator(fileDescriptor: -1))

        let actual = underTest.retrieveParameterByName("Pitch P")
        
        XCTAssertNotNil(actual, "Failed to retrieve parameter Pitch P")
        XCTAssertEqual(actual?.name, "Pitch P")
        XCTAssertEqual(actual?.position, 0)
        XCTAssertEqual(actual?.type, "Int16")
        XCTAssertEqual(actual?.minValue, 0)
        XCTAssertEqual(actual?.maxValue, 3000)
        XCTAssertEqual(actual?.defaultValue, 400)
        XCTAssertEqual(actual?.steps, 10)
    }

    func testRetrieveNumericParameterByName() throws {
        let underTest = S32ParameterController(storm32BGC: Storm32BGCSimulator(fileDescriptor: -1))

        let actual = underTest.retrieveParameterByName("Pitch P") as? S32NumericParameter
        
        XCTAssertNotNil(actual, "Failed to cast parameter Pitch P to S32NumericParameter")
        XCTAssertEqual(actual!.integerValue, 490)
        XCTAssertEqual(actual!.stringValue, "490")
    }

    func testRetrieveStringParameterByName() throws {
        let underTest = S32ParameterController(storm32BGC: Storm32BGCSimulator(fileDescriptor: -1))

        let actual = underTest.retrieveParameterByName("Pan Mode Default Setting") as? S32StringParameter
        
        XCTAssertNotNil(actual, "Failed to cast parameter Pitch P to S32NumericParameter")
        XCTAssertEqual(actual!.integerValue, 0)
        XCTAssertEqual(actual!.stringValue, "hold hold pan")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
