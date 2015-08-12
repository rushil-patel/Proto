//
//  Level.swift
//  Proto
//
//  Created by Rushil Patel on 7/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
//
//1-1 1.67
//1-2 3.33
//
//
//
//

import Foundation

class Level: CCNode {
    
    weak var endPortal: CCNode!
    
    //custom property
    var nextLevel: String = ""
    var currentLevel: String = ""
        //default position
    var startPosX: Float = 120
    var startPosY: Float = 106.5
    var threeStarTime: Float = 0.0
    
}