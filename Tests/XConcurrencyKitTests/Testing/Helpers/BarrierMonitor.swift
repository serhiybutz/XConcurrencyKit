//
//  BarrierMonitor.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
@testable import XConcurrencyKit

/// Monitors Barrier by first counting the incoming threads and making sure they are all in, then counting the outgoing threads and making sure they are all left.
///
/// Disambiguation: It is irrelevant to [synchronization monitor](https://en.wikipedia.org/wiki/Monitor_(synchronization)).
final class BarrierMonitor {
    enum State {
        case entering(maxThreadsIn: Int, threadsIn: Int)
        case full(maxThreadsIn: Int)
        case leaving(maxThreadsIn: Int, threadsIn: Int)
        case empty(maxThreadsIn: Int)

        static func initialState(maxThreadsIn: Int) -> Self {
            precondition(maxThreadsIn > 0)
            return .empty(maxThreadsIn: maxThreadsIn)
        }

        enum Event {
            case enter
            case leave
        }

        struct Error: Swift.Error {
            let msg: String
            init(_ msg: String) {
                self.msg = msg
            }
        }

        mutating func transition(event: Event) throws {
            switch (self, event) {
            case (.empty(let maxThreadsIn), .enter):
                self = .entering(maxThreadsIn: maxThreadsIn, threadsIn: 1)
            case (.entering(let maxThreadsIn, let threadsIn), .enter):
                if threadsIn + 1 < maxThreadsIn {
                    self = .entering(maxThreadsIn: maxThreadsIn, threadsIn: threadsIn + 1)
                } else {
                    self = .full(maxThreadsIn: maxThreadsIn)
                }
            case (.full(let maxThreadsIn), .leave):
                self = .leaving(maxThreadsIn: maxThreadsIn, threadsIn: maxThreadsIn - 1)
            case (.leaving(let maxThreadsIn, let threadsIn), .leave):
                if threadsIn > 1 {
                    self = .leaving(maxThreadsIn: maxThreadsIn, threadsIn: threadsIn - 1)
                } else {
                    self = .empty(maxThreadsIn: maxThreadsIn)
                }
            default:
                throw Error("Invalid transition: \(self)-\(event)")
            }
        }
    }

    private(set) var state: State {
        didSet {
            if case .full = state {
                runs += 1
            }
        }
    }

    private(set) var runs = 0

    private let lock = NSLock()

    init(maxThreadsIn: Int) {
        self.state = State.initialState(maxThreadsIn: maxThreadsIn)
    }

    func dispatch(event: State.Event) {
        do {
            try lock.withLocked {
                try state.transition(event: event)
            }
        } catch {
            fatalError("\(error)")
        }
    }

    var isEmpty: Bool {
        if case .empty = state {
            return true
        }
        return false
    }
}
