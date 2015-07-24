//
//  GameOverScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class GameOverScene: CCNode {
 
    
    weak var restartButton: CCButton!
    var score: Int = 0
    
    func setScore(userScore score: Int) {
        self.score = score
    }

}