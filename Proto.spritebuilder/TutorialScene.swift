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
    weak var pauseButton: CCButton!
    var pauseMenu: PauseScene!
    
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
        progressState++
        
    }
    

    override func update(delta: CCTime) {
        
        if startYaw == nil {
        
            startYaw = motionManager.deviceMotion.attitude.yaw

        }
        print(startYaw)

        println(yaw)
        if let deviceMotion = motionManager.deviceMotion {
        
            let currentAttitude = deviceMotion.attitude
            yaw = Float(currentAttitude.yaw)
            // println("\(startYaw) : \(yaw)")
        }
        
        if gyroUserEnabled {
            
            yaw = clampf(yaw, Float(startYaw - 0.4), Float(startYaw + 0.4))
            
            if yaw > Float(startYaw) {
        
                hero.physicsBody.velocity.x = -700 * abs(CGFloat(yaw))
                
            } else if yaw < Float(startYaw) {
        
                hero.physicsBody.velocity.x = 700 * abs(CGFloat(yaw))
                
            } else {
        
                hero.physicsBody.velocity.x = 0
                
            }

            //recognize that the user has learned the moving mechanic
            if (yaw >= Float(startYaw + 0.25) || yaw <= Float(startYaw - 0.25)) && progressState == 0 {
            
                progressState++

            }
        }
        
    
        
        
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
            
        case 1:
             
            iPhoneFigure.runAction(CCActionFadeOut(duration: 0.3))
            userInteractionEnabled = true
            
        case 2:
            
            switchUserEnabled = true
            
            if switchUserEnabled {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("colorToggle"), name: "color_toggle", object: nil)

            }
        default:
            break
        }

       
    }
    
    
    // MARK: Observer selectors
    
    func colorToggle() {
        
        hero.toggle()
        
    }
    
    func loadMainMenu() {
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
    func resumeTutorial() {
        
        //animation has call back that will remove pauseMenu Node from gameScene
        pauseMenu.runAction(CCActionFadeOut(duration: 0.5))
        pauseButton.visible = true
        pauseMenu.removeFromParent()
        
        
    }
    
    func retryTutorial() {
        
        var tutorialScene = CCBReader.load("TutorialScene")
        
        var scene = CCScene()
        scene.addChild(tutorialScene)
        
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(moveInWithDirection: CCTransitionDirection(rawValue: 2)!, duration: 1.0))
    }
    
    // END Observer selectors
    
    func triggerGamePause() {
        
        hero.physicsBody.velocity = CGPointZero
        
        pauseButton.visible = false
        
        pauseMenu = CCBReader.load("PauseScene") as! PauseScene
        pauseMenu.cascadeOpacityEnabled = true
        self.addChild(pauseMenu)
        pauseMenu.runAction(CCActionFadeIn(duration: 0.1))
        
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
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