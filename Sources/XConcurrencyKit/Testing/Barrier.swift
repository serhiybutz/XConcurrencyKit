//
//  Barrier.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// A thread barrier that blocks execution of threads until all of them gather together (rendezvous) and then unleashes them all at once.
public final class Barrier {
    // MARK: - State

    @usableFromInline
    let threads: Int
    @usableFromInline
    var count: Int = 0
    @usableFromInline
    let mutex = NSLock()
    @usableFromInline
    let semaphore = DispatchSemaphore(value: 0)

    // MARK: - Initialization

    /// Create an instance of *Barrier*.
    ///
    /// - Parameter threads: The number of threads expected for rendezvous.
    public init(threads: Int) {
        self.threads = threads
    }

    // MARK: - UI

    /// Arrange a rendezvous of threads.
    @inlinable @inline(__always)
    public func rendezvous() {
        mutex.lock()
        defer {
            mutex.unlock()
            semaphore.wait() // <<- thread waiting point
        }
        count += 1
        if count == threads {
            count = 0
            (0..<threads).forEach { _ in semaphore.signal() }
        }
    }
}
