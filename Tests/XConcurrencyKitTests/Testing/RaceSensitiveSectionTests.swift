//
//  RaceSensitiveSectionTests.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
@testable
import XConcurrencyKit

final class RaceSensitiveSectionTests: XCTestCase {
    let sut = RaceSensitiveSection()

    override func setUp() {
        super.setUp()
        sut.reset()
    }

    func test_detects_races() {
        // Given

        let threadCollider = ThreadCollider()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            self.sut.exclusiveCriticalSection({
                // simulate some work
                let sleepVal = arc4random() & 31
                usleep(sleepVal)
            })

            // Race corral END
        })

        // Then

        let totalRuns = ThreadCollider.threads * ThreadCollider.runs
        XCTAssertEqual(sut.exclusivePasses, totalRuns)
        XCTAssertFalse(sut.noProblemDetected)
        XCTAssertTrue(sut.exclusiveRaces > 0)
        print("Race ratio: \(sut.exclusiveRaces * 100 / totalRuns)%")
    }

    func test2() {
        // Given

        let lock = NSLock()

        let threadCollider = ThreadCollider()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            if Bool.random() {
                lock.lock()
                self.sut.exclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 15
                    usleep(sleepVal)
                })
                lock.unlock()
            } else {
                self.sut.nonExclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 31
                    usleep(sleepVal)
                })
            }

            // Race corral END
        })

        // Then

        let totalRuns = ThreadCollider.threads * ThreadCollider.runs
        XCTAssertEqual(sut.exclusivePasses + sut.nonExclusivePasses, totalRuns)
        XCTAssertFalse(sut.noProblemDetected)
        print("Race ratio: \(sut.exclusiveRaces * 100 / totalRuns)%")
    }

    func test_no_exclusive_races_for_both_writing_and_reading_threads() {
        // Given

        var writingCount = 0
        var readingCount = 0
        let condition = NSCondition()

        let threadCollider = ThreadCollider()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            if Bool.random() {
                condition.lock()
                while writingCount > 0 || readingCount > 0 {
                    condition.wait()
                }
                writingCount += 1
                XCTAssertTrue(writingCount <= 1) // Then
                condition.broadcast()
                condition.unlock()

                self.sut.exclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 15
                    usleep(sleepVal)
                })

                condition.lock()
                writingCount -= 1
                XCTAssertTrue(writingCount >= 0) // Then
                condition.broadcast()
                condition.unlock()
            } else {
                condition.lock()
                while writingCount > 0 {
                    condition.wait()
                }
                readingCount += 1
                condition.broadcast()
                condition.unlock()

                self.sut.nonExclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 31
                    usleep(sleepVal)
                })

                condition.lock()
                readingCount -= 1
                XCTAssertTrue(readingCount >= 0) // Then
                condition.broadcast()
                condition.unlock()
            }

            // Race corral END
        })

        // Then

        let totalRuns = ThreadCollider.threads * ThreadCollider.runs
        XCTAssertEqual(sut.exclusivePasses + sut.nonExclusivePasses, totalRuns)
        XCTAssertTrue(sut.noProblemDetected)
        XCTAssertTrue(sut.nonExclusiveBenignRaces > 0)
        print("Non-exclusive benign access race ratio: \(sut.nonExclusiveBenignRaces * 100 / sut.nonExclusivePasses)%")
    }
}
