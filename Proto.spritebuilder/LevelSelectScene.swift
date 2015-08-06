//
//  LevelSelectScene.swift
//  Proto
//
//  Created by Rushil Patel on 8/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class LevelSelectScene: CCNode {
    
    
    func launchLevel(button : CCButton) {
        
        let gamePlayScene = CCScene()
        let gamePlay = CCBReader.load("Gameplay") as! GamePlayScene
        let level = CCBReader.load(button.name) as! Level
        gamePlay.level = level
        gamePlayScene.addChild(gamePlay)
        CCDirector.sharedDirector().presentScene(gamePlayScene, withTransition: CCTransition(fadeWithDuration: 1))
    }

}