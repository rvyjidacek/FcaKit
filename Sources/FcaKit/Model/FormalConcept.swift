//
//  FormalConcept.swift
//  FCA
//
//  Created by Roman Vyjídáček on 11.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class FormalConcept: Bicluster {

    public override func hash(into hasher: inout Hasher) {
        hasher.combine(objects.hashValue)
    }
    
}

