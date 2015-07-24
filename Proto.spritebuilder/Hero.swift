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
    
    weak var upperArmFront: CCSprite!
    weak var upperArmBack: CCSprite!
    weak var lowerArmBack: CCSprite!
    weak var lowerArmFront: CCSprite!
    weak var head: CCSprite!
    weak var torso: CCSprite!
    weak var lowerLegFront: CCSprite!
    weak var lowerLegBack: CCSprite!
    weak var upperLegFront: CCSprite!
    weak var upperLegBack: CCSprite!
    
    
    //Finite State
    var state: Action!
    var powerState: PowerState = .None
    
    //Hero constants
    let lift: CGFloat = 300.0
    
    func didLoadFromCCB() {
        state = .Idle
    }
    
    
    
    // toggles hero's sprite (color) and animation sprite frame from current
    // to other
    func toggle() {
        if colorMode == "white" {
            //let blackHeroSprite = CCSpriteFrame(imageNamed: "Assets/basicHeroBlack.png") as CCSpriteFrame
            //self.spriteFrame = blackHeroSprite
            
            torso.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/torsoBlack.png") as CCSpriteFrame
            upperArmFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperArmBlack.png") as CCSpriteFrame
            upperArmBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperArmBlack.png") as CCSpriteFrame
            lowerArmBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerArmBlack.png") as CCSpriteFrame
            lowerArmFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerArmBlack.png") as CCSpriteFrame
            head.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/headBlack.png") as CCSpriteFrame
            lowerLegFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerLegBlack.png") as CCSpriteFrame
            lowerLegBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerLegBlack.png") as CCSpriteFrame
            upperLegFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperLegBlack.png") as CCSpriteFrame
            upperLegBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperLegBlack.png") as CCSpriteFrame
            
            
            
            
            colorMode = "black"
        }
        else if colorMode == "black" {
            //let whiteHeroSprite = CCSpriteFrame(imageNamed: "Assets/basicHeroWhit.png") as CCSpriteFrame
            //self.spriteFrame = whiteHeroSprite
            
            torso.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/torsoWhite.png") as CCSpriteFrame
            upperArmFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperArmWhite.png") as CCSpriteFrame
            upperArmBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperArmWhite.png") as CCSpriteFrame
            lowerArmBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerArmWhite.png") as CCSpriteFrame
            lowerArmFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerArmWhite.png") as CCSpriteFrame
            head.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/headWhite.png") as CCSpriteFrame
            lowerLegFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerLegWhite.png") as CCSpriteFrame
            lowerLegBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/lowerLegWhite.png") as CCSpriteFrame
            upperLegFront.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperLegWhite.png") as CCSpriteFrame
            upperLegBack.spriteFrame = CCSpriteFrame(imageNamed: "Assets/Hero/upperLegWhite.png") as CCSpriteFrame
            
            colorMode = "white"
        }
    }

}