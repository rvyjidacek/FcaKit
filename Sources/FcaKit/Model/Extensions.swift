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
