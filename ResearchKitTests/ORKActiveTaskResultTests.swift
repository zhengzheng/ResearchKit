/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import ResearchKit

class ORKAmslerGridResultTests: XCTestCase {
    var result: ORKAmslerGridResult!
    var identifier: String!
    var image: UIImage!
    var path: UIBezierPath!
    
    override func setUp() {
        identifier = "RESULT"
        let bundle = Bundle(identifier: "org.researchkit.ResearchKit")
        image = UIImage(named: "amslerGrid", in: bundle, compatibleWith: nil)
        path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        result = ORKAmslerGridResult(identifier: identifier, image: image, path: [path], eyeSide: .left)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.image, image)
        XCTAssertEqual(result.path, [path])
        XCTAssertEqual(result.eyeSide, ORKAmslerGridEyeSide.left)
    }
    
    func testIsEqual() {
        XCTAssert(result .isEqual(result))
    }
}


class ORKHolePegTestResultTests: XCTestCase {
    var result: ORKHolePegTestResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKHolePegTestResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.movingDirection = ORKBodySagittal(rawValue: 2)!
        result.isDominantHandTested = true
        result.numberOfPegs = 2
        result.threshold = 2.0
        result.isRotated = false
        result.totalSuccesses = 10
        result.totalFailures = 5
        result.totalTime = 5.0
        result.totalDistance = 10.0
        result.samples = [2,4]
        
        XCTAssertEqual(result.movingDirection, ORKBodySagittal(rawValue: 2))
        XCTAssertEqual(result.isDominantHandTested, true)
        XCTAssertEqual(result.numberOfPegs, 2)
        XCTAssertEqual(result.threshold, 2.0)
        XCTAssertEqual(result.isRotated, false)
        XCTAssertEqual(result.totalSuccesses, 10)
        XCTAssertEqual(result.totalFailures, 5)
        XCTAssertEqual(result.totalTime, 5.0)
        XCTAssertEqual(result.totalDistance, 10.0)
        XCTAssertEqual(result.samples as! [Int], [2,4])
    }
}

class ORKPSATResultTests: XCTestCase {
    var result: ORKPSATResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "TESTS"
        result = ORKPSATResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.presentationMode = .auditory
        result.interStimulusInterval = 2
        result.stimulusDuration = 3
        result.length = 4
        result.totalCorrect = 5
        result.totalDyad = 2
        result.totalTime = 20
        result.initialDigit = 20
        
        let sample = ORKPSATSample()
        sample.answer = 20
        result.samples = [sample]
        
        XCTAssertEqual(result.presentationMode, ORKPSATPresentationMode.auditory)
        XCTAssertEqual(result.interStimulusInterval, 2)
        XCTAssertEqual(result.stimulusDuration, 3)
        XCTAssertEqual(result.length, 4)
        XCTAssertEqual(result.totalCorrect, 5)
        XCTAssertEqual(result.totalDyad, 2)
        XCTAssertEqual(result.totalTime, 20)
        XCTAssertEqual(result.initialDigit, 20)
        XCTAssertEqual(result.samples, [sample])
    }
    
    func testIsEqual() {
        XCTAssert(result .isEqual(result))
    }
}

class ORKRangeOfMotionResultTests: XCTestCase {
    var result: ORKRangeOfMotionResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKRangeOfMotionResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.start = 0
        result.finish = 50
        result.minimum = 10
        result.maximum = 50
        result.range = 10
        
        XCTAssertEqual(result.start, 0)
        XCTAssertEqual(result.finish, 50)
        XCTAssertEqual(result.minimum, 10)
        XCTAssertEqual(result.maximum, 50)
        XCTAssertEqual(result.range, 10)
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKReactionTimeResultTests: XCTestCase {
    var result: ORKReactionTimeResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKReactionTimeResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.timestamp = 10
        
        let fileResult = ORKFileResult()
        fileResult.fileURL = URL(fileURLWithPath: "FILEURL")
        result.fileResult = fileResult
        
        XCTAssertEqual(result.timestamp, 10)
        XCTAssertEqual(result.fileResult, fileResult)
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKSpatialSpanMemoryResultTests: XCTestCase {
    var result: ORKSpatialSpanMemoryResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKSpatialSpanMemoryResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testAttributes() {
        result.score = 0
        result.numberOfGames = 20
        result.numberOfFailures = 20
        
        let gameRecord = ORKSpatialSpanMemoryGameRecord()
        gameRecord.score = 10
        result.gameRecords = [gameRecord]
        
        XCTAssertEqual(result.score, 0)
        XCTAssertEqual(result.numberOfGames, 20)
        XCTAssertEqual(result.numberOfFailures, 20)
        XCTAssertEqual(result.gameRecords, [gameRecord])
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKSpeechRecognitionResultTests: XCTestCase {
    var result: ORKSpeechRecognitionResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "Result"
        result = ORKSpeechRecognitionResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        let transcription = SFTranscription()
        result.transcription = transcription
        
        XCTAssertEqual(result.transcription, transcription)
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKStroopResultTests: XCTestCase {
    var result: ORKStroopResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKStroopResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.startTime = 0
        result.endTime = 100
        result.color = "BLUE"
        result.text = "TEXT"
        result.colorSelected = "RED"
        
        XCTAssertEqual(result.startTime, 0)
        XCTAssertEqual(result.endTime, 100)
        XCTAssertEqual(result.color, "BLUE")
        XCTAssertEqual(result.text, "TEXT")
        XCTAssertEqual(result.colorSelected, "RED")
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKTappingIntervalResultTests: XCTestCase {
    var result: ORKTappingIntervalResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKTappingIntervalResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        let sample = ORKTappingSample()
        sample.duration = 20
        
        let stepViewSize = CGSize(width: 50, height: 50)
        let buttonRect1 = CGRect(x: 0, y: 0, width: 50, height: 50)
        let buttonRect2 = CGRect(x: 100, y: 100, width: 50, height: 50)
        
        result.samples = [sample]
        result.stepViewSize = stepViewSize
        result.buttonRect1 = buttonRect1
        result.buttonRect2 = buttonRect2
        
        XCTAssertEqual(result.samples, [sample])
        XCTAssertEqual(result.stepViewSize, stepViewSize)
        XCTAssertEqual(result.buttonRect1, buttonRect1)
        XCTAssertEqual(result.buttonRect2, buttonRect2)
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKTimedWalkResultTests: XCTestCase {
    var result: ORKTimedWalkResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKTimedWalkResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.distanceInMeters = 100
        result.timeLimit = 100
        result.duration = 20

        XCTAssertEqual(result.distanceInMeters, 100)
        XCTAssertEqual(result.timeLimit, 100)
        XCTAssertEqual(result.duration, 20)
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKToneAudiometryResultTests: XCTestCase {
    var result: ORKToneAudiometryResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKToneAudiometryResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.outputVolume = 100
        
        let sample = ORKToneAudiometrySample()
        sample.amplitude = 100
        sample.frequency = 100
        result.samples = [sample]
        
        XCTAssertEqual(result.outputVolume, 100)
        XCTAssertEqual(result.samples, [sample])
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKdBHLToneAudiometryResultTests: XCTestCase {
    var result: ORKdBHLToneAudiometryResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKdBHLToneAudiometryResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.outputVolume = 100
        result.tonePlaybackDuration = 360
        result.postStimulusDelay = 10
        result.headphoneType = "AIRPODS"
        
        let sample = ORKdBHLToneAudiometryFrequencySample()
        sample.frequency = 100
        result.samples = [sample]
        
        XCTAssertEqual(result.outputVolume, 100)
        XCTAssertEqual(result.tonePlaybackDuration, 360)
        XCTAssertEqual(result.postStimulusDelay, 10)
        XCTAssertEqual(result.headphoneType, "AIRPODS")
        XCTAssertEqual(result.samples, [sample])
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKTowerOfHanoiResultTests: XCTestCase {
    var result: ORKTowerOfHanoiResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKTowerOfHanoiResult(identifier: identifier)
    }
    
    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        result.puzzleWasSolved = false
        
        let moveOne = ORKTowerOfHanoiMove()
        moveOne.donorTowerIndex = 0
        moveOne.recipientTowerIndex = 1
        let moveTwo = ORKTowerOfHanoiMove()
        moveTwo.donorTowerIndex = 4
        moveTwo.recipientTowerIndex = 2
        result.moves = [moveOne, moveTwo]
        
        XCTAssertEqual(result.puzzleWasSolved, false)
        XCTAssertEqual(result.moves, [moveOne, moveTwo])
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}

class ORKTrailmakingResultTests: XCTestCase {
    
    var result: ORKTrailmakingResult!
    var identifier: String!
    
    override func setUp() {
        identifier = "RESULT"
        result = ORKTrailmakingResult(identifier: identifier)
    }

    func testInit() {
        XCTAssertEqual(result.identifier, identifier)
    }
    
    func testProperties() {
        let tap = ORKTrailmakingTap()
        tap.incorrect = false
        result.taps = [tap]
        result.numberOfErrors = 1
        
        XCTAssertEqual(result.taps, [tap])
        XCTAssertEqual(result.numberOfErrors, 1)
    }
    
    func testIsEqual() {
        XCTAssert(result.isEqual(result))
    }
}
