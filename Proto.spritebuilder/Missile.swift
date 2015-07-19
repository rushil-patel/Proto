//
//  Missile.swift
//  Proto
//
//  Created by Rushil Patel on 7/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class Missile: CCSprite {
    
    //custom property
    var colorMode: String = ""
    
    func didLoadFromCCB() {
        self.scale =  0.6
    }
    
    func explode() {
        //run explostion animation
        self.removeFromParent()
    }
    
    
}