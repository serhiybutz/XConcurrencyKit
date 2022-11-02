//
//  MultithreadMachExecutionTimeMeter+MergedReport.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension MultithreadMachExecutionTimeMeter {
    public struct MergedReport {
        let multiTimeMeter: MultithreadMachExecutionTimeMeter
        init(_ multiTimeMeter: MultithreadMachExecutionTimeMeter) {
            self.multiTimeMeter = multiTimeMeter
        }
        public func generate() -> MachExecutionTimeMeter {
            var timeMeters = self.multiTimeMeter.timeMeters!
            let first = timeMeters.popLast()!
            var totalTimeMeter = timeMeters.map { $0 }.reduce(first, +)
            totalTimeMeter.forceSetIterations(totalTimeMeter.iterations * self.multiTimeMeter.timeMeters.count)
            return totalTimeMeter
        }
    }
}
