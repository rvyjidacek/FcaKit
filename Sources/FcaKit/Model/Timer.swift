//
//  Timer.swift
//  FCA
//
//  Created by Roman Vyjídáček on 06.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import CoreFoundation

public class Timer {
    
    let startTime:CFAbsoluteTime
    
    var endTime:CFAbsoluteTime?
    
    public init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    public var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
