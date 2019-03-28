//
//  ORKPasscodeResultTests.swift
//  ResearchKitTests
//
//  Created by Oscar San Juan on 3/28/19.
//  Copyright © 2019 researchkit.org. All rights reserved.
//

import XCTest
@testable import ResearchKit

class ORKPasscodeResultTests: XCTestCase {
    var result: ORKPasscodeResult!
    var identifier: String!
    let date = Date()
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKPasscodeResult(identifier: identifier)
    }
    
    func testInit() {
        result.isPasscodeSaved = true
        result.isTouchIdEnabled = false
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.isPasscodeSaved = true
        result.isTouchIdEnabled = false
        XCTAssertEqual(result.isPasscodeSaved, true)
        XCTAssertEqual(result.isTouchIdEnabled, false)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKPasscodeResult(identifier: identifier)
        newResult.isPasscodeSaved = true
        newResult.isTouchIdEnabled = false
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(result))
    }
}
