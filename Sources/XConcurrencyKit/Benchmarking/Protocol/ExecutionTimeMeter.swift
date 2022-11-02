//
//  ExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol ExecutionTimeMeter {
    associatedtype TimeValue
    mutating func start()
    mutating func finish() -> TimeValue
    mutating func measure(_ exec: () -> Void)
    mutating func measure(_ exec: () throws -> Void) throws
    mutating func mergeOverheadAdjustments(_ adjustments: Self)
    init()
}
