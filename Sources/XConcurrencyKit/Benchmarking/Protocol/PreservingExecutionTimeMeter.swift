//
//  PreservingExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol PreservingExecutionTimeMeter {
    mutating func allocate(measurements: Int)
}
