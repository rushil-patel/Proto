//
//  TutorialScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import CoreMotion


class TutorialScene: CCScene, CCPhysicsCollisionDelegate {
    
    
    weak var princess: CCNode!
    weak var hero: Hero!
    weak var instructionLabel: CCLabelTTF!
    weak var tutorialPhysicsNode: CCPhysicsNode!
    weak var iPhoneFigure: CCNode!
    
    var gyroUserEnabled = false
    var tapUserEnabled = false
    var switchUserEnabled = false
    
    var currentTutorialPage: CCNode!
    let motionManager = CMMotionManager()
    var yaw: Float = 0.0
    var startYaw: Double!
    var jumpTime = 0.7
    
    var jumpScheduler: NSTimer!
    
    var progressState = -1 {
       
        didSet {
            
            self.scheduleOnce(Selector("displayInstruction"), delay: 1.5)
            
        }
        
    }

    
    let instructions: [String] = ["Tilt the device to move", "Tap anywhere on screen to jump", "Use the lower left button to switch between black and white"]

    func didLoadFromCCB() {
        
        tutorialPhysicsNode.collisionDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resumeLevel"), name: "color_toggle", object: nil)

        if motionManager.deviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 1.0/60.0
            motionManager.startDeviceMotionUpdates()
            
            if motionManager.gyroAvailable {
                
                motionManager.gyroUpdateInterval = 1.0/60.0
                motionManager.startGyroUpdates()
            }
            else {
                //alert cannot use gyroscope
            }
        }
        else {
            //alert cannot use gyroscope
        }
    
    }
    
    
    override func onEnter() {
        
        super.onEnter()
        
    }
    

    override func update(delta: CCTime) {
        
        
        /*if startYaw == nil {
        
            startYaw = motionManager.deviceMotion.attitude.yaw
        }
        
        if let deviceMotion = motionManager.deviceMotion {
        
            let currentAttitude = deviceMotion.attitude
            yaw = Float(currentAttitude.yaw)
            // println("\(startYaw) : \(yaw)")
        }
        
        if gyroUserEnabled {
            
            yaw = clampf(yaw, Float(0.4), Float(-0.4))
            
            if yaw > Float(startYaw + 0.05) {
        
                hero.physicsBody.velocity.x = -700 * abs(CGFloat(yaw))
                
            } else if yaw < Float(startYaw - 0.05) {
        
                hero.physicsBody.velocity.x = 700 * abs(CGFloat(yaw))
                
            } else {
        
                hero.physicsBody.velocity.x = 0
                
            }
         */
            yaw = 0.5
            //recognize that the user has learned the moving mechanic
            if (yaw >= 0.2 || yaw <= -0.2) && progressState == -1 {
                
                progressState++

            }
        //}
        //*/
    
        
        
    }
    
    func applyJump() {
        
        if jumpTime == 0.7 {
            
            hero.physicsBody.velocity.y = CGFloat(300)
            jumpTime -= 0.08
        }
        else if jumpTime > 0.0 {
            
            hero.physicsBody.velocity.y = CGFloat(jumpTime * 10 * 50)
            jumpTime -= 0.02
            
        }  else {
            
            jumpScheduler!.invalidate()
            hero.state = .Fall
            
        }
        
        
    }
    

    
    func displayInstruction() {
        
        if progressState < instructions.count && progressState >= 0 {
            instructionLabel.string = instructions[progressState]
            self.animationManager.runAnimationsForSequenceNamed("instructify")
        }
        
        switch progressState {
            
        case 0:
            iPhoneFigure.runAction(CCActionFadeIn(duration: 0.5))
            gyroUserEnabled = true
            progressState++
            
        case 1:
            
            iPhoneFigure.runAction(CCActionFadeOut(duration: 0.3))
            userInteractionEnabled = true
            
        case 2:
            
            switchUserEnabled = true
            
            if switchUserEnabled {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("recognizeSwitchToggle"), name: "color_toggle", object: nil)

            }
        default:
            break
        }

       
    }
    
     override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if tapUserEnabled == false {
            
            progressState++
            tapUserEnabled = true
        }
        
        if hero.state != .Jump && hero.state != .Fall {
            
            jumpScheduler = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("applyJump"), userInfo: nil, repeats: true)
            hero.state = .Jump
        }
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if hero.state == .Jump || hero.state == .Fall {
            jumpScheduler.invalidate()
            hero.state = .Fall
        }
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, normalPlatform: CCNode!) -> ObjCBool {
        
        hero.state = .Idle
        jumpTime = 0.7
        return true
        
    }
}