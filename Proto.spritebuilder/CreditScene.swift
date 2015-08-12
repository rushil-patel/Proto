//
//  CreditScene.swift
//  SwitchRun
//
//  Created by Rushil Patel on 8/9/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class CreditScene: CCNode {
    
    
    func returnToMainMenu() {
        
        let scene = CCScene()
        let mainScene = CCBReader.load("MainScene") as! MainScene
        scene.addChild(mainScene)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 0.4))
        
    }
}