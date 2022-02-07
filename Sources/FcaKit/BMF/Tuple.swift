//
//  Tuple.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public struct Tuple: Hashable {
    let a: Int
    let b: Int
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(a.hashValue &* 31 &+ b.hashValue)
    }
}

public func ==(lhs: Tuple, rhs: Tuple) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b
}

