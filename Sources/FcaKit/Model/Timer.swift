//
//  Timer.swift
//  FCA
//
//  Created by Roman Vyjídáček on 06.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import CoreFoundation

class Timer {
    
    let startTime:CFAbsoluteTime
    
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
