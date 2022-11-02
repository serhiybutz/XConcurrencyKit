//
//  WithLockedTrait.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

protocol WithLockedTrait: NSLocking {}

extension WithLockedTrait {
    @inline(__always) @discardableResult
    func withLocked<T>(_ exec: () -> T) -> T {
        lock()
        defer { unlock() }
        return exec()
    }

    @inline(__always) @discardableResult
    func withLocked<T>(_ exec: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try exec()
    }
}
