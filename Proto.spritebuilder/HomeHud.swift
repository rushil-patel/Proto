//
//  HomeHud.swift
//  Proto
//
//  Created by Rushil Patel on 7/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class HomeHud: CCNode {
    
    
    func didLoadFromCCB() {
        
        userInteractionEnabled = true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
      
        NSNotificationCenter.defaultCenter().postNotificationName("home_touch_began", object: nil)
    }
    
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("home_touch_ended", object: nil)
    }
}