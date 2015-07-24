//
//  Platform.swift
//  Proto
//
//  Created by Rushil Patel on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class Platform: CCSprite {
    
    //initialize to unkown, ccb custom property will override if set
    
    func randomizeLength() {
        let rand = CCRANDOM_0_1()
        
        if rand < 0.33 {
            
            self.scaleX = 1
        }
        else if rand >= 0.33 && rand < 0.66 {
            
            self.scaleX = 1.3
        }
        else {
            
            self.scaleX = 1.6
        }
    }
    
    
}