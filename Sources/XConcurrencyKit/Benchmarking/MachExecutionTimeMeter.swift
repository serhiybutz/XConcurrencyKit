//
//  MachExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// Benchmarking time meter based on the `mach_absolute_time` function.
public struct MachExecutionTimeMeter: ExecutionTimeMeter & ExecutionTimeMeterReporting {
    // MARK: - State

    @usableFromInline
    var _total: UInt64 = 0 // in tick units

    @usableFromInline
    var _startedAt: UInt64 = 0

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
        _startedAt = mach_absolute_time()
    }

    /// Finish the measurement of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always) @discardableResult
    public mutating func finish() -> UInt64 {
        let elapsed = mach_absolute_time() - _startedAt
        _total += elapsed
        _iterations += 1
        return elapsed
    }

    /// Merge overhead adjustments.
    public mutating func mergeOverheadAdjustments(_ adjustments: MachExecutionTimeMeter) {
        self = self - adjustments
    }

    // MARK: - UI (ExecutionTimeMeterReporting)

    /// Number of iterations performed.
    public var iterations: Int { _iterations }

    /// Total execution time.
    public var executionTime: TimeInterval {
        reportInNanosecs
            ? TimeInterval(NanoUtils.nanosecsFromTickUnits(_total))
            : TimeInterval(NanoUtils.nanosecsFromTickUnits(_total)) / Double(MachExecutionTimeMeter.nsecPerSec)
    }

    /// Average execution time.
    public var averageExecutionTime: TimeInterval { executionTime / Double(_iterations) }

    /// Forcibly set the iteration counter to a custom value (convenient in some usage scenarios).
    public mutating func forceSetIterations(_ v: Int) {
        _iterations = v
    }
}
