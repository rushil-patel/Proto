//
//  Hero.swift
//  Proto
//
//  Created by Rushil Patel on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum Action {
    case Run, Jump, Idle, Fall
}

class Hero: CCSprite {
    
    //Custom Properties
    var colorMode: String = ""
    
    //Hero constants    
    func didLoadFromCCB() {
        
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
    
    func deadAnim() {
        
        if self.colorMode == "black" {
           
            self.visible = false
            
            var popParticle = CCBReader.load("DeathPop") as! CCParticleSystem
            popParticle.startColor = CCColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            popParticle.startColorVar = CCColor(red: 0, green: 0, blue: 0, alpha: 0)
            popParticle.endColor = CCColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            popParticle.endColorVar = CCColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            popParticle.blendAdditive = false
            popParticle.position = CGPointMake(self.positionInPoints.x, self.positionInPoints.y + self.boundingBox().height/2)
            
            self.parent.addChild(popParticle)
            
        } else if self.colorMode == "white" {
            
            self.visible = false
            
            var popParticle = CCBReader.load("DeathPop") as! CCParticleSystem
            popParticle.position = CGPointMake(self.positionInPoints.x, self.positionInPoints.y + self.boundingBox().height/2)
            
            self.parent.addChild(popParticle)
            
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