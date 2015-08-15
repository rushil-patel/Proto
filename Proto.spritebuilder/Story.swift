//
//  Story.swift
//  SwitchRun
//
//  Created by Rushil Patel on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class Story: CCNode {
    
    
    
    func launchLevelSelect() {
        
        let levelSelectScene = CCScene()
        let levelSelect = CCBReader.load("LevelSelectScene") as! LevelSelectScene
        levelSelectScene.addChild(levelSelect)
        
        CCDirector.sharedDirector().replaceScene(levelSelectScene, withTransition: CCTransition(fadeWithDuration: 0.4))
        
    }
    
    
    func loadMainMenu() {
        
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
}