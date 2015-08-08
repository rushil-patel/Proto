//
//  ColorToggle.swift
//  Proto
//
//  Created by Rushil Patel on 7/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class ColorToggle: CCSprite {
    
    var colorMode = "black"
    
    weak var switchButtonBlack: CCSprite!
    weak var switchButtonWhite: CCSprite!
    
    func didLoadFromCCB() {
        
        userInteractionEnabled = true
    
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
            
        NSNotificationCenter.defaultCenter().postNotificationName("color_toggle", object: nil)
        
        if colorMode == "black" {
            colorMode = "white"
            switchButtonBlack.visible = false
            switchButtonWhite.visible = true
            
        } else if colorMode == "white" {
            colorMode = "black"
            switchButtonBlack.visible = true
            switchButtonWhite.visible = false
    
        }
        
    }
    
    
}
