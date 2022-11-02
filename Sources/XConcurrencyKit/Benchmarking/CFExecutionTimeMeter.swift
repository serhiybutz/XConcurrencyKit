//
//  CFExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// Benchmarking time meter based on the `CFAbsoluteTimeGetCurrent` function.
public struct CFExecutionTimeMeter: ExecutionTimeMeter & ExecutionTimeMeterReporting {
    // MARK: - State

    @usableFromInline
    var _totalSeconds: CFAbsoluteTime = 0

    @usableFromInline
    var _startedAt: CFAbsoluteTime = 0

    @usableFromInline
    var _iterations: Int = 0

    /// Should report in *nano*seconds.
    public var reportInNanosecs: Bool = false

    static let nsecPerSec: UInt64 = 1_000_000_000

    // MARK: - Initialization

    public init() {}

    // MARK: - UI (ExecutionTimeMeter)

    /// Start the measurement of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always)
    public mutating func start() {
        _startedAt = CFAbsoluteTimeGetCurrent()
    }

    /// Finish the measurement of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always) @discardableResult
    public mutating func finish() -> CFAbsoluteTime {
        let elapsed = CFAbsoluteTimeGetCurrent() - _startedAt
        _totalSeconds += elapsed
        _iterations += 1
        return elapsed
    }

    /// Merge overhead adjustments.
    public mutating func mergeOverheadAdjustments(_ adjustments: CFExecutionTimeMeter) {
        self = self - adjustments
    }

    // MARK: - UI (ExecutionTimeMeterReporting)

    /// Number of iterations performed.
    public var iterations: Int { _iterations }

    /// Total execution time.
    public var executionTime: TimeInterval {
        reportInNanosecs
            ? _totalSeconds * Double(CFExecutionTimeMeter.nsecPerSec)
            : _totalSeconds
    }

    /// Average execution time.
    public var averageExecutionTime: TimeInterval { executionTime / Double(_iterations) }

    /// Forcibly set the iteration counter to a custom value (convenient in some usage scenarios).
    public mutating func forceSetIterations(_ v: Int) {
        _iterations = v
    }
}
