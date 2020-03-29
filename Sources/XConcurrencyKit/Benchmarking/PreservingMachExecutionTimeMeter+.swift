//
//  PreservingMachExecutionTimeMeter+.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

extension PreservingMachExecutionTimeMeter {
    public static func catenate(_ timeMeters: Self...) -> Self {
        catenate(timeMeters)
    }
    public static func catenate(_ timeMeters: [Self]) -> Self {
        var new = PreservingMachExecutionTimeMeter()
        new.allocate(measurements: timeMeters.map { $0.iterations }.reduce(0, +))
        new.measurements = timeMeters.map { $0.measurements }.reduce([], +)
        return new
    }
}
