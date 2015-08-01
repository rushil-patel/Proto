//
//  ColorToggle.swift
//  Proto
//
//  Created by Rushil Patel on 7/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class ColorToggle: CCNode {
    
    
    func didLoadFromCCB() {
        
        userInteractionEnabled = true
    
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
            
        NSNotificationCenter.defaultCenter().postNotificationName("color_toggle", object: nil)
    }
    
    
}
