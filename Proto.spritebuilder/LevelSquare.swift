//
//  LevelSqaure.swift
//  Proto
//
//  Created by Rushil Patel on 8/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class LevelSquare: CCNode  {
    
    weak var levelNumberLabel: CCLabelTTF!
    weak var starOne: CCSprite!
    weak var starTwo: CCSprite!
    weak var starThree: CCSprite!
    weak var levelButton: CCButton!
    
    
    func launchLevel(button : CCButton) {
        
        let gamePlayScene = CCScene()
        
        let buttonNum = button.parent.name.toInt()
        if buttonNum == 1 || buttonNum == 2 || buttonNum == 3 || buttonNum == 4 || buttonNum == 5 || buttonNum == 6 {
            let instructionalPlayScene = CCScene()
            let instructionalPlay = CCBReader.load("InstructionalPlay") as! InstructionalPlayScene
            
            let level = CCBReader.load("Levels/Tut\(button.parent.name)") as! Level
            
            instructionalPlay.level = level
            instructionalPlayScene.addChild(instructionalPlay)
            CCDirector.sharedDirector().presentScene(instructionalPlayScene, withTransition: CCTransition(fadeWithDuration: 1))

        }
        else {
            
            let gamePlayScene = CCScene()
            let gamePlay = CCBReader.load("Gameplay") as! GamePlayScene
            let level = CCBReader.load("Levels/Level\(button.parent.name.toInt()! - 6)") as! Level
            
            gamePlay.level = level
            gamePlayScene.addChild(gamePlay)
            CCDirector.sharedDirector().presentScene(gamePlayScene, withTransition: CCTransition(fadeWithDuration: 1))
        }

    }

    
}
