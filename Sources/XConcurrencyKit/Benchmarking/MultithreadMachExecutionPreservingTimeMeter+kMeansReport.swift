//
//  MultithreadMachExecutionPreservingTimeMeter+kMeansReport.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension MultithreadMachExecutionPreservingTimeMeter {
    public struct KMeansReport {
        public typealias MeasurementSummary = (maxNanosecs: UInt64, minNanosecs: UInt64)

        let multiTimeMeter: MultithreadMachExecutionPreservingTimeMeter
        init(_ multiTimeMeter: MultithreadMachExecutionPreservingTimeMeter) {
            self.multiTimeMeter = multiTimeMeter
        }
        public func generate() -> MeasurementSummary {
            let timeMeters = self.multiTimeMeter.timeMeters!
            let measurements = PreservingMachExecutionTimeMeter.catenate(timeMeters).measurements
            let kMeans = KMeans(points: measurements) { excludePoints in
                return [measurements.filter { !excludePoints.contains($0) }.min()!,
                        measurements.filter { !excludePoints.contains($0) }.max()!]
            }
            let clusters = kMeans.run()
            return MeasurementSummary(
                clusters
                    .map { NanoUtils.nanosecsFromTickUnits($0.centroid) }
                    .max()!,
                clusters
                    .map { NanoUtils.nanosecsFromTickUnits($0.centroid) }
                    .min()!
            )
        }
    }
}

extension UInt64: DataPoint {
    var value: UInt64 { self }
}
