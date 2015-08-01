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
    var powerState: PowerState = .None
    
    //Hero constants
    let lift: CGFloat = 5000.0
    
    func didLoadFromCCB() {
        
        state = .Idle
        
        self.scale = 0.3
    }
    
    
    func runAnim() {
        
        if self.colorMode == "black" {
            
            self.animationManager.runAnimationsForSequenceNamed("RunBlack")
            
        } else if self.colorMode == "white" {
            
            self.animationManager.runAnimationsForSequenceNamed("RunWhite")

            
        }
        
    }
    
    func idleAnim() {
        
        if self.colorMode == "black" {
            
            self.animationManager.runAnimationsForSequenceNamed("IdleBlack")
            
        } else if self.colorMode == "white" {
            
            self.animationManager.runAnimationsForSequenceNamed("IdleWhite")

        }
        
    }
    
    func jumpAnim() {
        
        if self.colorMode == "black" {
            
            self.animationManager.runAnimationsForSequenceNamed("JumpBlack")
            
        } else if self.colorMode == "white" {
            
            self.animationManager.runAnimationsForSequenceNamed("JumpWhite")
            
        }
    }
    
    
    // toggles hero's sprite (color) and animation sprite frame from current
    // to other
    func toggle() {
        if colorMode == "white" {
            
            colorMode = "black"
            
            let animName = self.animationManager.runningSequenceName

            if animName == "RunWhite" {
                
                self.runAnim()
                
            } else if animName == "JumpWhite" {
                
                self.jumpAnim()
                
            } else if animName == "IdleWhite" {
                
                self.idleAnim()
            }
        }
        else if colorMode == "black" {
            
            colorMode = "white"
            
            
            let animName = self.animationManager.runningSequenceName
            
            if animName == "RunBlack" {
                
                self.runAnim()
                
            } else if animName == "JumpBlack" {
                
                self.jumpAnim()
                
            } else if animName == "IdleBlack" {
                
                self.idleAnim()
            }
        }
    }

}