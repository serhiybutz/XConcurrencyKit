//
//  MachExecutionTimeMeter+ExecutionTimeMeterOperations.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

extension MachExecutionTimeMeter: ExecutionTimeMeterOperations {
    public func union(with another: Self) -> Self {
        precondition(self.iterations == another.iterations)
        var new = MachExecutionTimeMeter()
        new.forceSetIterations(self.iterations)
        new._total = self._total + another._total
        new.reportInNanosecs = self.reportInNanosecs
        return new
    }

    public func difference(with another: Self) -> Self {
        precondition(self.iterations == another.iterations)
        var new = MachExecutionTimeMeter()
        new.forceSetIterations(self.iterations)
        new._total = self._total.subtractingIgnoringOverflow(another._total)
        new.reportInNanosecs = self.reportInNanosecs
        return new
    }
}
