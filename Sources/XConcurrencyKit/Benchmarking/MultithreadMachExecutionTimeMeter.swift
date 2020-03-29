//
//  MultithreadMachExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public final class MultithreadMachExecutionTimeMeter: MultithreadExecutionTimeMeter {
    // MARK: - State

    @usableFromInline
    var timeMeters: [MachExecutionTimeMeter]!
    public func allocate(threads: Int, measurements: Int) {
        self.timeMeters = (0..<threads).map { _ in
            MachExecutionTimeMeter()
        }
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Access UI

    @inlinable @inline(__always)
    public subscript(index: Int) -> MachExecutionTimeMeter {
        get { timeMeters[index] }
        set { timeMeters[index] = newValue }
    }

    // MARK: - Report UI

    public var mergedReport: MergedReport { MergedReport(self) }
}
