//
//  Hero.swift
//  Proto
//
//  Created by Rushil Patel on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Hero: CCSprite {
    
    //Custom Properties
    var colorMode: String = ""
    
    
    //Finite State
    var state: Action!
    
    
    //Hero constants
    let lift: CGFloat = 400.0
    
    func didLoadFromCCB() {
        state = .Idle
    }
    
    
    // toggles hero's sprite (color) and animation sprite frame from current
    // to other
    func toggle() {
        if colorMode == "white" {
            let blackHeroSprite = CCSpriteFrame(imageNamed: "Assets/basicHeroBlack.png") as CCSpriteFrame
            self.spriteFrame = blackHeroSprite
            
            colorMode = "black"
        }
        else if colorMode == "black" {
            let whiteHeroSprite = CCSpriteFrame(imageNamed: "Assets/basicHeroWhit.png") as CCSpriteFrame
            self.spriteFrame = whiteHeroSprite
            
            colorMode = "white"
        }
    }

}