//
//  BarrierTests.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
@testable import XConcurrencyKit

final class BarrierTests: XCTestCase {
    let queue = DispatchQueue(label: "test", qos: .userInteractive, attributes: .concurrent)

    static let concurrentThreads = 50
    static let runs = 10_000

    func test() {
        // Given

        let sut1 = Barrier(threads: BarrierTests.concurrentThreads)
        let sut2 = Barrier(threads: BarrierTests.concurrentThreads)

        let monitor = BarrierMonitor(maxThreadsIn: BarrierTests.concurrentThreads)

        // When

        let g = DispatchGroup()
        for _ in 0..<BarrierTests.concurrentThreads {
            queue.async {
                for _ in 0..<BarrierTests.runs {
                    // Run BEGIN

                    g.enter()
                    defer {
                        g.leave()
                    }

                    sut1.rendezvous()
                    // Race corral BEGIN

                    monitor.dispatch(event: .enter)

                    // simulate some work
                    let sleepVal = arc4random() & 127
                    usleep(sleepVal)

                    // Race corral END
                    sut2.rendezvous()

                    monitor.dispatch(event: .leave)

                    // Run END
                }
            }
        }
        g.wait()

        // Then

        XCTAssertTrue(monitor.isEmpty)
        XCTAssertEqual(monitor.runs, BarrierTests.runs)
    }
}
