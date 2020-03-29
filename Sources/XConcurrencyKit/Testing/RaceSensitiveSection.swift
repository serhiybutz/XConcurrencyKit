//
//  RaceSensitiveSection.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// A helper tool to detect races.
public final class RaceSensitiveSection {
    // MARK: - Types

    public typealias TagRegisterHandler = (_ tag: Int?) -> Void
    public typealias TagRegisterClosure = (TagRegisterHandler) -> Void

    // MARK: - State

    @usableFromInline
    let _mutex = NSLock()

    @usableFromInline
    var _enteredExclusively = Set<Int?>()
    @usableFromInline
    var _hasExclusiveRace: Bool = true
    @usableFromInline
    var _exclusiveRaces: Int = 0
    @usableFromInline
    var _exclusivePasses: Int = 0

    @usableFromInline
    var _enteredNonExclusively: [Int?: Int] = [:]
    @usableFromInline
    var _nonExclusiveRaces: Int = 0
    @usableFromInline
    var _nonExclusiveBenignRaces: Int = 0
    @usableFromInline
    var _nonExclusivePasses: Int = 0

    // MARK: - Initializer

    public init() {}

    // MARK: - UI

    /// Resets state.
    public func reset() {
        _enteredExclusively = []
        _hasExclusiveRace = false
        _exclusiveRaces = 0
        _exclusivePasses = 0

        _enteredNonExclusively = [:]
        _nonExclusiveRaces = 0
        _nonExclusiveBenignRaces = 0
        _nonExclusivePasses = 0
    }

    /// Mark entrance to exclusive critical section.
    @inlinable @inline(__always)
    public func enterExclusive(register: TagRegisterClosure = { $0(nil) }) {
        _mutex.lock()
        defer { _mutex.unlock() }
        _hasExclusiveRace = false
        register { tag in
            if !_enteredExclusively.insert(tag).inserted {
                _hasExclusiveRace = true
            }
            // non-exclusive access also violates exclusive access
            if (_enteredNonExclusively[tag] ?? 0) != 0 {
                _hasExclusiveRace = true
            }
        }
    }

    /// Mark exit from exclusive critical section.
    @inlinable @inline(__always)
    public func exitExclusive(unregister: TagRegisterClosure = { $0(nil) }) {
        _mutex.lock()
        defer { _mutex.unlock() }
        unregister { tag in
            if _enteredExclusively.remove(tag) == nil {
                _hasExclusiveRace = true
            }
        }
        // yield
        if _hasExclusiveRace {
            _exclusiveRaces += 1
        }
        _exclusivePasses += 1
    }

    /// Run exclusive critical section.
    @inlinable @inline(__always) @discardableResult
    public func exclusiveCriticalSection<R>(_ section: () -> R, register: TagRegisterClosure = { $0(nil) }) -> R {
        enterExclusive(register: register)
        defer {
            exitExclusive(unregister: register)
        }
        return section()
    }

    /// Run throwing exclusive critical section.
    @inlinable @inline(__always) @discardableResult
    public func exclusiveCriticalSection<R>(_ section: () throws -> R, register: TagRegisterClosure = { $0(nil) }) throws -> R {
        enterExclusive(register: register)
        defer {
            exitExclusive(unregister: register)
        }
        return try section()
    }

    /// Mark entrance to non-exclusive critical section.
    @inlinable @inline(__always)
    public func enterNonExclusive(register: TagRegisterClosure = { $0(nil) }) {
        _mutex.lock()
        defer { _mutex.unlock() }
        register { tag in
            if addToDict(&_enteredNonExclusively, tag) > 1 {
                _nonExclusiveBenignRaces += 1
            }
            if _enteredExclusively.contains(tag) {
                _nonExclusiveRaces += 1
            }
        }
    }

    /// Mark exit from non-exclusive critical section.
    @inlinable @inline(__always)
    public func exitNonExclusive(unregister: TagRegisterClosure = { $0(nil) }) {
        _mutex.lock()
        defer { _mutex.unlock() }
        unregister { tag in
            removeFromDict(&_enteredNonExclusively, tag)
        }
        _nonExclusivePasses += 1
    }

    /// Run non-exclusive critical section.
    @inlinable @inline(__always) @discardableResult
    public func nonExclusiveCriticalSection<R>(_ section: () -> R, register: TagRegisterClosure = { $0(nil) }) -> R {
        enterNonExclusive(register: register)
        defer {
            exitNonExclusive(unregister: register)
        }
        return section()
    }

    /// Run throwing non-exclusive critical section.
    @inlinable @inline(__always) @discardableResult
    public func nonExclusiveCriticalSection<R>(_ section: () throws -> R, register: TagRegisterClosure = { $0(nil) }) throws -> R {
        enterNonExclusive(register: register)
        defer {
            exitNonExclusive(unregister: register)
        }
        return try section()
    }

    /// Races in exclusive critical section.
    public var exclusiveRaces: Int { _exclusiveRaces }

    /// Passes through exclusive critical section.
    public var exclusivePasses: Int { _exclusivePasses }

    /// Races in non-exclusive critical section.
    public var nonExclusiveRaces: Int { _nonExclusiveRaces }

    /// Benign races in non-exclusive critical section.
    public var nonExclusiveBenignRaces: Int { _nonExclusiveBenignRaces }

    /// Passes through non-exclusive critical section.
    public var nonExclusivePasses: Int { _nonExclusivePasses }

    /// Predicate of failure to detect a problem.
    public var noProblemDetected: Bool {
        _exclusiveRaces == 0 && _nonExclusiveRaces == 0
            && _enteredExclusively.isEmpty
            && !_enteredNonExclusively.values.contains { $0 != 0 }
    }

    // MARK: - Helpers

    @usableFromInline @inline(__always) @discardableResult
    func addToDict(_ dict: inout [Int?: Int], _ tag: Int?) -> Int {
        let counter = (dict[tag] ?? 0) + 1
        dict[tag] = counter
        return counter
    }

    @usableFromInline @inline(__always) @discardableResult
    func removeFromDict(_ dict: inout [Int?: Int], _ tag: Int?) -> Int {
        let counter = (dict[tag] ?? 0) - 1
        dict[tag] = counter
        return counter
    }
}
