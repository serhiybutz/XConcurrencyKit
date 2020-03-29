//
//  MutlithreadBenchmark.swift
//  XConcurrencyKit
//
//  Created by Serge Bouts on 3/29/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// A helper tool to perform mutlithread benchmarking.
public final class MutlithreadBenchmark {
    // MARK: - Configuration

    public static var threads: Int = 10
    public static var runs: Int = 10_000

    // MARK: - State

    private let queue = DispatchQueue(label: "MutlithreadBenchmarkQueue", qos: .userInteractive, attributes: .concurrent)

    // MARK: - Initialization

    /// Create an instance of `MutlithreadBenchmark`.
    public init() {}

    // MARK: - UI

    /// Perform a benchmarking of `subject` block.
    ///
    /// - Parameters:
    ///   - threads: The number of threads to spawn.
    ///   - runs: How many times the `subject` block should be benchmarked.
    ///   - prepareArgs: The closure that will be called before each `subject` benchmarking to prepare the argument for `subject`.
    ///   - subject: The closure with code benchmark, which accepts the argument prepared in `prepareArgs`.
    ///   - multithreadExecutionTimeMeter: The multithread execution time meter to use for benchmarking.
    ///   - overheadAdjustment: The closure to measure the overhead adjustment of `subject` closure calls to provide more accurate results in benchmarking.
    ///
    ///  Usage example:
    ///
    ///     import XConcurrencyKit
    ///     ...
    ///     let bank = Bank() // the benchmarked object
    ///     let mutlithreadTimeMeter = MultithreadMachExecutionTimeMeter()
    ///     let benchmark = MutlithreadBenchmark()
    ///     benchmark.perform(
    ///         threads: 10,
    ///         runs: 10_000,
    ///         prepareArgs: { () -> (from: Int, to: Int, amount: Int) in
    ///             let from = Int.random(in: 0..<bank.accounts.count)
    ///             let to = (from + Int.random(in: 1..<bank.accounts.count)) % bank.accounts.count
    ///             let amount = Int.random(in: -5...5)
    ///             return (from: from, to: to, amount: amount)
    ///         },
    ///         subject: { args in
    ///             if Int.random(in: 0..<100) <= 95 {
    ///                 bank.transfer(from: args.from, to: args.to, amount: args.amount)
    ///             } else {
    ///                 let total = bank.report().reduce(0, +)
    ///                 assert(total == BankMock.accountCount * BankMock.initialBalance)
    ///             }
    ///             NanoUtils.spinDelay(for: 0)
    ///         },
    ///         multithreadExecutionTimeMeter: mutlithreadTimeMeter,
    ///         overheadAdjustment: { _ in
    ///             NanoUtils.spinDelay(for: 0)
    ///         })
    ///
    ///     var timeMeter = mutlithreadTimeMeter.mergedReport.generate()
    ///     timeMeter.reportInNanosecs = true
    ///
    ///     print(timeMeter.averageExecutionTime)
    ///
    public func perform<M: MultithreadExecutionTimeMeter, A>(
        threads: Int = MutlithreadBenchmark.threads,
        runs: Int = MutlithreadBenchmark.runs,
        prepareArgs: @escaping () -> A,
        subject: @escaping (A) -> Void,
        multithreadExecutionTimeMeter: M,
        overheadAdjustment: @escaping (A) -> Void = {_ in}
    ) {
        precondition(threads > 0)
        precondition(runs > 0)

        let barrier1 = Barrier(threads: threads)
        let barrier2 = Barrier(threads: threads)

        multithreadExecutionTimeMeter.allocate(threads: threads, measurements: runs)

        let group = DispatchGroup()
        for threadIndex in 0..<threads {
            group.enter()
            queue.async {
                defer {
                    group.leave()
                }
                var dummy = M.TimeMeter()
                if var d = dummy as? PreservingExecutionTimeMeter {
                    d.allocate(measurements: runs)
                    dummy = d as! M.TimeMeter
                }
                for _ in 0..<runs {
                    barrier1.rendezvous()
                    let args = prepareArgs()
                    dummy.measure {
                        overheadAdjustment(args)
                    }
                    multithreadExecutionTimeMeter[threadIndex].measure {
                        subject(args)
                    }
                    barrier2.rendezvous()
                }
                multithreadExecutionTimeMeter[threadIndex].mergeOverheadAdjustments(dummy)
            }
        }
        group.wait()
    }

    /// Perform a benchmarking of `subject` block.
    ///
    /// - Parameters:
    ///   - threads: The number of threads to spawn.
    ///   - runs: How many times the `subject` block should be benchmarked.
    ///   - subject: The closure with code benchmark.
    ///   - multithreadExecutionTimeMeter: The multithread execution time meter to use for benchmarking.
    ///   - overheadAdjustment: The closure to measure the overhead adjustment of `subject` closure calls to provide more accurate results in benchmarking.
    ///
    ///  Usage example:
    ///
    ///     import XConcurrencyKit
    ///     ...
    ///     let bank = Bank() // the benchmarked object
    ///     let mutlithreadTimeMeter = MultithreadMachExecutionTimeMeter()
    ///     let benchmark = MutlithreadBenchmark()
    ///     benchmark.perform(
    ///         threads: 10,
    ///         runs: 10_000,
    ///         subject: { args in
    ///             let from = Int.random(in: 0..<bank.accounts.count)
    ///             let to = (from + Int.random(in: 1..<bank.accounts.count)) % bank.accounts.count
    ///             let amount = Int.random(in: -5...5)
    ///             if Int.random(in: 0..<100) <= 95 {
    ///                 bank.transfer(from: args.from, to: args.to, amount: args.amount)
    ///             } else {
    ///                 let total = bank.report().reduce(0, +)
    ///                 assert(total == BankMock.accountCount * BankMock.initialBalance)
    ///             }
    ///             NanoUtils.spinDelay(for: 0)
    ///         },
    ///         multithreadExecutionTimeMeter: mutlithreadTimeMeter,
    ///         overheadAdjustment: { _ in
    ///             NanoUtils.spinDelay(for: 0)
    ///         })
    ///
    ///     var timeMeter = mutlithreadTimeMeter.mergedReport.generate()
    ///     timeMeter.reportInNanosecs = true
    ///
    ///     print(timeMeter.averageExecutionTime)
    ///
    public func perform<M: MultithreadExecutionTimeMeter>(
        threads: Int = MutlithreadBenchmark.threads,
        runs: Int = MutlithreadBenchmark.runs,
        subject: @escaping () -> Void,
        multithreadExecutionTimeMeter: M,
        overheadAdjustment: @escaping () -> Void = {}
    ) {
        precondition(threads > 0)
        precondition(runs > 0)

        let barrier1 = Barrier(threads: threads)
        let barrier2 = Barrier(threads: threads)

        multithreadExecutionTimeMeter.allocate(threads: threads, measurements: runs)

        let group = DispatchGroup()
        for threadIndex in 0..<threads {
            group.enter()
            queue.async {
                defer {
                    group.leave()
                }
                var dummy = M.TimeMeter()
                if var d = dummy as? PreservingExecutionTimeMeter {
                    d.allocate(measurements: runs)
                    dummy = d as! M.TimeMeter
                }
                for _ in 0..<runs {
                    barrier1.rendezvous()
                    dummy.measure {
                        overheadAdjustment()
                    }
                    multithreadExecutionTimeMeter[threadIndex].measure {
                        subject()
                    }
                    barrier2.rendezvous()
                }
                multithreadExecutionTimeMeter[threadIndex].mergeOverheadAdjustments(dummy)
            }
        }
        group.wait()
    }
}
