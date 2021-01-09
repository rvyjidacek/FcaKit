//
//  Extensions.swift
//  FormalConceptAnalysis
//
//  Created by Roman Vyjídáček on 11.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation


public typealias Attribute = Int

public typealias Object = Int

extension Set {
    func setmap<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}

extension String {
    
    init(repeating value: String, count: Int) {
        self.init()
        for _ in 0..<count {
            self.append(value)
        }
    }
    
}

extension Array {
    
    subscript(index: UInt64) -> Element {
        get {
            return self[Int(index)]
        }
        set {
            self[Int(index)] = newValue
        }
    }
}

public var subsets: [Int: [Int]] = [:]

#if os(Linux)
    typealias CFAbsoluteTime = Double
#endif

public typealias MeasureResult<T> = (averageTime: CFAbsoluteTime,
                              bestTime: CFAbsoluteTime,
                              worstTime: CFAbsoluteTime,
                              deviation: CFAbsoluteTime,
                              closureResult: T)

public func measure<T>(times: UInt = 1, closure: () -> T) -> MeasureResult<T> {
    let timer = Timer()
    var result: T!
    var executionTimes: [CFAbsoluteTime] = []
    
    for _ in 0..<times {
        timer.start()
        result = closure()
        executionTimes.append(timer.stop())
    }
    
    let averageTime = executionTimes.reduce(0, +) / Double(times)
    let bestTime = executionTimes.min()!
    let worstTime = executionTimes.max()!
    let deviation = executionTimes.map({ (averageTime - $0).magnitude }).reduce(0, +) / Double(executionTimes.count)
    
    return (averageTime, bestTime, worstTime, deviation, result)
}
