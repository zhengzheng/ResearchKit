//
//  ORKActiveStepTests.swift
//  ResearchKitTests
//
//  Created by Oscar San Juan on 1/29/19.
//  Copyright © 2019 researchkit.org. All rights reserved.
//

import XCTest
@testable import ResearchKit

class ORKActiveStepTests: XCTestCase {
    
    var activeStepTest: ORKActiveStep!
    
    override func setUp() {
        activeStepTest = ORKActiveStep(identifier: "Test")
    }
    
    func testIdentifier() {
        XCTAssert(activeStepTest.identifier == "Test")
    }
    
    func testStartsFinished(){
        activeStepTest.stepDuration = -1
        XCTAssertFalse(activeStepTest.startsFinished())
        
        activeStepTest.stepDuration = 2
        XCTAssertFalse(activeStepTest.startsFinished())
        
        activeStepTest.stepDuration = 0
        XCTAssert(activeStepTest.startsFinished())
    }
    
    func testHasCountdown(){
        // stepDuration > 0 && shouldShowDefaultTimer = true -> true
        activeStepTest.shouldShowDefaultTimer = true
        activeStepTest.stepDuration = -1
        XCTAssertFalse(activeStepTest.hasCountDown())
        
        activeStepTest.stepDuration = 0
        XCTAssertFalse(activeStepTest.hasCountDown())
        
        activeStepTest.stepDuration = 1
        activeStepTest.shouldShowDefaultTimer = false
        XCTAssertFalse(activeStepTest.hasCountDown())
        
        activeStepTest.shouldShowDefaultTimer = true
        XCTAssert(activeStepTest.hasCountDown())
    }
    
    func testHasTitle(){
        activeStepTest.title = ""
        XCTAssertFalse(activeStepTest.hasTitle())
        
        activeStepTest.title = nil
        XCTAssertFalse(activeStepTest.hasTitle())
        
        activeStepTest.title = "This should work"
        XCTAssert(activeStepTest.hasTitle())
    }
    
    func testHasText(){
        activeStepTest.text = ""
        XCTAssertFalse(activeStepTest.hasText())
        
        activeStepTest.text = nil
        XCTAssertFalse(activeStepTest.hasText())
        
        activeStepTest.text = "THIS SHOULD WORK"
        XCTAssert(activeStepTest.hasText())
    }
    
    func testHasVoice(){
        
        activeStepTest.spokenInstruction = nil
        XCTAssertFalse(activeStepTest.hasVoice())
        
        activeStepTest.spokenInstruction = ""
        XCTAssertFalse(activeStepTest.hasVoice())
        
        activeStepTest.spokenInstruction = "Do jumping jacks"
        activeStepTest.finishedSpokenInstruction = nil
        XCTAssert(activeStepTest.hasVoice())
        
        activeStepTest.spokenInstruction = nil
        activeStepTest.finishedSpokenInstruction = ""
        XCTAssertFalse(activeStepTest.hasVoice())
        
        activeStepTest.finishedSpokenInstruction = "Good job"
        XCTAssert(activeStepTest.hasVoice())
        
    }
}
