//
//  ExecutionTimeMeter+.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension ExecutionTimeMeter {
    /// Measure the execution time of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always)
    public mutating func measure(_ exec: () -> Void) {
        start()
        defer { _ = finish() }
        exec()
    }

    /// Measure the execution time of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always)
    public mutating func measure<R>(_ exec: () -> R) -> R {
        start()
        defer { _ = finish() }
        return exec()
    }

    /// Measure the execution time of a benchmarked region of code (during one iteration). Throwing version.
    @inlinable @inline(__always)
    public mutating func measure(_ exec: () throws -> Void) throws -> Void {
        start()
        defer { _ = finish() }
        try exec()
    }

    /// Measure the execution time of a benchmarked region of code (during one iteration). Throwing version.
    @inlinable @inline(__always)
    public mutating func measure<R>(_ exec: () throws -> R) throws -> R {
        start()
        defer { _ = finish() }
        return try exec()
    }
}
