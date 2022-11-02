//
//  PreservingMachExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// Preserving the measurements history, a benchmarking time meter based on the `mach_absolute_time` function.
public struct PreservingMachExecutionTimeMeter: ExecutionTimeMeter & ExecutionTimeMeterReporting {
    // MARK: - State

    @usableFromInline
    var measurements: [UInt64] = [] // in tick units

    @usableFromInline
    var _startedAt: UInt64 = 0

    /// Should report in *nano*seconds.
    public var reportInNanosecs: Bool = false

    static let nsecPerSec: UInt64 = 1_000_000_000

    // MARK: - Initialization

    public init() {}

    // MARK: - UI

    /// Starts the measurement of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always)
    public mutating func start() {
        _startedAt = mach_absolute_time()
    }

    /// Finishes the measurement of a benchmarked region of code (during one iteration).
    @inlinable @inline(__always) @discardableResult
    public mutating func finish() -> UInt64 {
        let elapsed = mach_absolute_time() - _startedAt
        measurements.append(elapsed)
        return elapsed
    }

    // MARK: - UI (ExecutionTimeMeterReporting)

    /// Number of iterations performed.
    public var iterations: Int { measurements.count }

    /// Total execution time.
    public var executionTime: TimeInterval {
        let total = measurements.reduce(0, +)
        return reportInNanosecs
            ? TimeInterval(NanoUtils.nanosecsFromTickUnits(total))
            : TimeInterval(NanoUtils.nanosecsFromTickUnits(total)) / Double(MachExecutionTimeMeter.nsecPerSec)
    }

    /// Average execution time.
    public var averageExecutionTime: TimeInterval { executionTime / Double(iterations) }

    /// Forcibly sets the iteration counter to a custom value, which is convenient in some usage scenarios.
    public mutating func forceSetIterations(_ v: Int) {
        // no-op
    }

    /// Merge overhead adjustments.
    mutating public func mergeOverheadAdjustments(_ adjustments: Self) {
        precondition(measurements.count == adjustments.iterations)
        measurements.indices.forEach {
            measurements[$0] = measurements[$0].subtractingIgnoringOverflow(adjustments[$0])
        }
    }

    /// Get measurement by index.
    public subscript(index: Int) -> UInt64 { measurements[index] }
}

// MARK: - PreservingExecutionTimeMeter

extension PreservingMachExecutionTimeMeter: PreservingExecutionTimeMeter {
    public mutating func allocate(measurements: Int) {
        self.measurements.reserveCapacity(measurements)
    }
}
