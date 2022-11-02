//
//  CFExecutionTimeMeter+ExecutionTimeMeterOperations.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

extension CFExecutionTimeMeter: ExecutionTimeMeterOperations {
    public func union(with another: Self) -> Self {
        precondition(self.iterations == another.iterations)
        var new = CFExecutionTimeMeter()
        new.forceSetIterations(self._iterations)
        new._totalSeconds = self._totalSeconds + another._totalSeconds
        new.reportInNanosecs = self.reportInNanosecs
        return new
    }

    public func difference(with another: Self) -> Self {
        precondition(self.iterations == another.iterations)
        var new = CFExecutionTimeMeter()
        new.forceSetIterations(self.iterations)
        new._totalSeconds = self._totalSeconds -
            (another.reportInNanosecs
                ? another.executionTime / Double(CFExecutionTimeMeter.nsecPerSec)
                : another.executionTime)
        new.reportInNanosecs = self.reportInNanosecs
        return new
    }
}
