//
//  NextHud.swift
//  Proto
//
//  Created by Rushil Patel on 8/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class NextHud: CCNode {
    
    
    func didLoadFromCCB() {
        
        userInteractionEnabled = true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("next_touch_began", object: nil)
    }
    
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("next_touch_ended", object: nil)
    }
}
