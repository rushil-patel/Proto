//
//  ResumeHud.swift
//  Proto
//
//  Created by Rushil Patel on 7/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class ResumeHud: CCNode {
    
    func didLoadFromCCB() {
        
        userInteractionEnabled = true
        
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
      
        NSNotificationCenter.defaultCenter().postNotificationName("resume_touch_begin", object: nil)
    }
    
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("resume_touch_ended", object: nil)
    }
}