//
//  UpdatableSet.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 07/02/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public struct UpdatableSet {
    
    private var items: [BitSet]
    
    public var count: Int {
        return items.count
    }
    
    public init(size: Int) {
        items = (0..<size).map({ (i) -> BitSet in  BitSet(size: size) })
    }
    
    public func get(index: Int) -> BitSet {
        return items[index]
    }
    
    public mutating func set(index: Int, set: BitSet) {
        items[index] = set
    }
}

extension UpdatableSet: Hashable {


}
