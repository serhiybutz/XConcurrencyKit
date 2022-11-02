//
//  MultithreadMachExecutionPreservingTimeMeter+MergedReport.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension MultithreadMachExecutionPreservingTimeMeter {
    public struct MergedReport {
        let multiTimeMeter: MultithreadMachExecutionPreservingTimeMeter
        init(_ multiTimeMeter: MultithreadMachExecutionPreservingTimeMeter) {
            self.multiTimeMeter = multiTimeMeter
        }
        public func generate() -> PreservingMachExecutionTimeMeter {
            let timeMeters = self.multiTimeMeter.timeMeters!
            return PreservingMachExecutionTimeMeter.catenate(timeMeters)
        }
    }
}
