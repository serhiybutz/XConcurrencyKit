//
//  UInt64+.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import os.log

extension UInt64 {
    @usableFromInline @inline(__always)
    func subtractingIgnoringOverflow(_ rhs: Self) -> Self {
        let diff = self.subtractingReportingOverflow(rhs)
        if diff.overflow {
            os_log("### [%s] Subtraction overflow: %@", log: .default, type: .debug, "\(type(of: self))", "\(self) - \(rhs) = -\(UInt64.max - diff.partialValue + 1)")
            return 0
        } else {
            return diff.partialValue
        }
    }
}
