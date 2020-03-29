//
//  ThreadCollider.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// A helper tool that arranges intense race conditions for testing purposes, a "*thread collider*".
public final class ThreadCollider {
    // MARK: - Configuration

    public static var threads: Int = 10
    public static var runs: Int = 10_000

    // MARK: - State

    private let queue = DispatchQueue(label: "ThreadColliderQueue", qos: .userInteractive, attributes: .concurrent)

    // MARK: - Initialization

    /// Create an instance of `ThreadCollider`.
    public init() {}

    // MARK: - UI

    /// Subject a given `victim` block of code to intense race conditions for the process to complete.
    ///
    /// - Parameters:
    ///   - threads: The number of threads to spawn.
    ///   - runs: How many times `victim` must be subjected to race conditions.
    ///   - victim: The block (closure) to be subjected to race conditions.
    ///   - loopAroundPhase: The optional block (closure) to be subjected to race conditions when threads are in the "loop around" phase.
    public func collide(
        threads: Int = ThreadCollider.threads,
        runs: Int = ThreadCollider.runs,
        victim: @escaping () -> Void,
        loopAroundPhase: @escaping () -> Void = {}) {
        precondition(threads > 0)
        precondition(runs > 0)

        let barrier1 = Barrier(threads: threads)
        let barrier2 = Barrier(threads: threads)

        let group = DispatchGroup()
        for _ in 0..<threads {
            group.enter()
            queue.async {
                defer {
                    group.leave()
                }
                for _ in 0..<runs {
                    barrier1.rendezvous()
                    victim()
                    barrier2.rendezvous()
                    loopAroundPhase()
                }
            }
        }
        group.wait()
    }
}
