//
//  NanoUtils.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Darwin

public struct NanoUtils {
    @usableFromInline
    static let machTimebaseInfo: mach_timebase_info_data_t = {
        var baseInfo = mach_timebase_info_data_t()
        guard mach_timebase_info(&baseInfo) == KERN_SUCCESS else { fatalError() }
        return baseInfo
    }()
    /// Convert tick units to nanoseconds.
    @inlinable @inline(__always)
    public static func nanosecsFromTickUnits(_ tickUnits: UInt64, startingAt tickUnits0: UInt64? = nil) -> UInt64 {
        return (tickUnits - (tickUnits0 ?? 0)) * UInt64(machTimebaseInfo.numer) / UInt64(machTimebaseInfo.denom)
    }
    /// Convert nanoseconds to tick units.
    @inlinable @inline(__always)
    public static func tickUnitsFromNanosecs(_ nano: UInt64) -> UInt64 {
        return nano * UInt64(machTimebaseInfo.denom) / UInt64(machTimebaseInfo.numer)
    }
    /// Spin delay for `nano` number of nanoseconds.
    @inlinable @inline(__always)
    public static func spinDelay(for nano: UInt64) {
        let deadline = mach_absolute_time() + tickUnitsFromNanosecs(nano)
        while mach_absolute_time() < deadline {}
    }
}
