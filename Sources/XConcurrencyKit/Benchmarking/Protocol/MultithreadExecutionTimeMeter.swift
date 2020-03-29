//
//  MultithreadExecutionTimeMeter.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol MultithreadExecutionTimeMeter: AnyObject {
    associatedtype TimeMeter: ExecutionTimeMeter
    func allocate(threads: Int, measurements: Int)
    subscript(index: Int) -> TimeMeter { get set }
}
