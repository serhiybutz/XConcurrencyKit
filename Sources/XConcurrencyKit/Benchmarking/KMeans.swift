//
//  KMeans.swift
//  XConcurrencyKit
//
//  Created by Serhiy Butz on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

protocol DataPoint: CustomStringConvertible, Hashable {
    var value: UInt64 { get }
    init(_ value: UInt64)
}

extension DataPoint {
    func distance<Point: DataPoint>(to: Point) -> UInt64 {
        max(to.value, self.value) - min(to.value, self.value)
    }
}

/// A K-means clustering algorithm.
final class KMeans<Point: DataPoint> {
    // MARK: - Types

    final class Cluster: CustomStringConvertible {
        var points: [Point] = []
        var centroid: Point
        init(centroid: Point) {
            self.centroid = centroid
        }
        var description: String {
            "(points: \(points.count), centroid: \(centroid))"
        }
    }

    // MARK: - State

    private var points: [Point]
    private var clusters: [Cluster]
    private var centroids: [Point] { clusters.map{ $0.centroid } }
    private let seedCentroidComputation: (_ excluded: Set<Point>) -> [Point]

    // MARK: - Initialization

    init(points: [Point], seedCentroidComputation: @escaping (_ excluded: Set<Point>) -> [Point]) {
        precondition(!points.isEmpty)
        self.points = points
        self.seedCentroidComputation = seedCentroidComputation
        clusters = seedCentroidComputation([]).map { Cluster(centroid: $0) }
    }

    // MARK: - UI

    func run(maxIterations: Int = 100) -> [Cluster] {
        for _ in 0..<maxIterations {
            assignClosestClusters()
            let lastCentroids = centroids
            updateCentroids()
            if lastCentroids == centroids {
                return clusters
            }
        }
        return clusters
    }

    // MARK: - Helpers

    private func assignClosestClusters(excluded: Set<Point>? = nil) {
        clusters.forEach { $0.points.removeAll() }
        for point in points {
            if let ep = excluded, ep.contains(point) {
                continue
            }
            var lowestDistance = UInt64.max
            var closestCluster: Cluster!
            for (index, centroid) in centroids.enumerated() {
                if centroid.distance(to: point) < lowestDistance {
                    lowestDistance = centroid.distance(to: point)
                    closestCluster = clusters[index]
                }
            }
            closestCluster.points.append(point)
        }
        // Exclude anomalies
        var extraExcluded: Set<Point> = []
        for cluster in clusters {
            if cluster.points.count <= 50 {
                cluster.points.forEach { extraExcluded.insert($0) }
                let ep = (excluded ?? []).union(extraExcluded)
                clusters = seedCentroidComputation(ep).map { Cluster(centroid: $0) }
                assignClosestClusters(excluded: ep)
            }
        }
    }
    private func updateCentroids() {
        for cluster in clusters {
            let mean = cluster.points
                .map { $0.value }
                .mean
            cluster.centroid = Point(mean)
        }
    }
}

// MARK: - Array extensions

extension Array where Element == UInt64 {
    var sum: UInt64 { reduce(0, +) }
    var mean: UInt64 { sum / UInt64(count) }
}
