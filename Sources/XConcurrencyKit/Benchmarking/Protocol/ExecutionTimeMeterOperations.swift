//
//  ExecutionTimeMeterOperations.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public protocol ExecutionTimeMeterOperations: CustomStringConvertible {
    func union(with another: Self) -> Self
    func difference(with another: Self) -> Self
}

public func +<T: ExecutionTimeMeterOperations>(lhs: T, rhs: T) -> T { lhs.union(with: rhs) }
public func -<T: ExecutionTimeMeterOperations>(lhs: T, rhs: T) -> T { lhs.difference(with: rhs) }
