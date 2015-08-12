//
//  LevelSelectScene.swift
//  Proto
//
//  Created by Rushil Patel on 8/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class LevelSelectScene: CCNode {
    
    weak var levelSelectContent: LevelSelectContent!
    weak var homeButton: CCButton!
    weak var totalStarLabel: CCLabelTTF!
    
    
    func didLoadFromCCB() {
        
        updateStarsCollectedLabel()
    }
    
    
    func loadMainMenu() {
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
    func updateStarsCollectedLabel() {
        
        let starsCollected = levelSelectContent.totalStarsEarned
        let totalStars = levelSelectContent.totalStarsToEarn
        
        totalStarLabel.string = "\(starsCollected)/\(totalStars)"
    }
    
   }