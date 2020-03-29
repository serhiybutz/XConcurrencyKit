//
//  ExecutionTimeMeterReporting.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public protocol ExecutionTimeMeterReporting: CustomStringConvertible {
    var iterations: Int { get }
    mutating func forceSetIterations(_ v: Int)
    var executionTime: TimeInterval { get }
    var averageExecutionTime: TimeInterval { get }
    var reportInNanosecs: Bool { get set }
}

extension ExecutionTimeMeterReporting {
    public var description: String { "(\(executionTime):\(iterations)=\(averageExecutionTime))" }
}
