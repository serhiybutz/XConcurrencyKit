//
//  MultithreadMachExecutionPreservingTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public final class MultithreadMachExecutionPreservingTimeMeter: MultithreadExecutionTimeMeter {
    // MARK: - State

    @usableFromInline
    var timeMeters: [PreservingMachExecutionTimeMeter]!
    public func allocate(threads: Int, measurements: Int) {
        self.timeMeters = (0..<threads).map { _ in
            var result = PreservingMachExecutionTimeMeter()
            result.allocate(measurements: measurements)
            return result
        }
    }
    // MARK: - Initialization

    public init() {}

    // MARK: - Access UI

    @inlinable @inline(__always)
    public subscript(index: Int) -> PreservingMachExecutionTimeMeter {
        get { timeMeters[index] }
        set { timeMeters[index] = newValue }
    }

    // MARK: - Report UI

    public var mergedReport: MergedReport { MergedReport(self) }
    public var kMeansReport: KMeansReport { KMeansReport(self) }
}
