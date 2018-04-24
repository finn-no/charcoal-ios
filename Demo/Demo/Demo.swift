//
//  Demo.swift
//  Demo
//
//  Created by Holmsen, Henrik on 24/04/2018.
//  Copyright © 2018 FINN.no. All rights reserved.
//

import Foundation

enum Demo: String {
    case bottomsheet
    
    var title: String {
        return rawValue.capitalizingFirstLetter
    }
    
    static var all: [Demo] {
        return [
            .bottomsheet
        ]
    }
}
