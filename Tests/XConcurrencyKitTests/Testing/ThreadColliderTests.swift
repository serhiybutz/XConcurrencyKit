//
//  ThreadColliderTests.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
@testable import XConcurrencyKit

final class ThreadColliderTests: XCTestCase {
    func test() {
        // Given

        let sut = ThreadCollider()

        let monitor = BarrierMonitor(maxThreadsIn: ThreadCollider.threads)

        // When

        sut.collide(victim: {
            monitor.dispatch(event: .enter)
            // simulate some work
            let sleepVal = arc4random() & 127
            usleep(sleepVal)
        }, loopAroundPhase: {
            monitor.dispatch(event: .leave)
        })

        // Then

        XCTAssertTrue(monitor.isEmpty)
        XCTAssertEqual(monitor.runs, ThreadCollider.runs)
    }
}
