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
    weak var whiteSpike: CCNode!
    weak var endPortal: CCNode!
    weak var colorToggleNode: ColorToggle!
    weak var deathFlashNode: CCNode!
    var pauseMenu: PauseScene!
    
    var gyroUserEnabled = false
    var tapUserEnabled = false
    var switchUserEnabled = false
    var heroState: HeroAction = .Idle {
        willSet(newValue) {
            if newValue == .Idle && heroState != .Idle {
                //do nothing
            } else if newValue == .Jump && heroState != .Jump {
                hero.jumpAnim()
            } else if newValue == .Run && heroState != .Run {
                hero.runAnim()
            }
        }
    }
    
    var currentTutorialPage: CCNode!
    let motionManager = CMMotionManager()
    var yaw: Float = 0.0
    var jumpTime = 0.7
    var startSpikeCollisionDetection = false
    
    var jumpScheduler: NSTimer!
    
    var progressState = -1 {
       
        didSet {
            //ignore delay for first instruction
            //immediate pop up
            if progressState == 0 {
                
                displayInstruction()
                
            } else {
                
                //enable display for other instruction
                self.scheduleOnce(Selector("displayInstruction"), delay: 1.5)

            }
            
        }
        
    }


    let instructions: [String] = ["Tilt the device to move", "Tap anywhere on the screen to jump", "You can only pass through colors that are the same as you", "Use the lower left button to switch between black and white", "Avoid triangles that are not your color", "To complete each level get to the portal as fast as you can", "Tutorial Complete! Have Fun"]

    func didLoadFromCCB() {
        
        colorToggleNode.visible = false
        
        tutorialPhysicsNode.collisionDelegate = self

        if motionManager.deviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 1.0/60.0
            motionManager.startDeviceMotionUpdates()
            
            if motionManager.accelerometerAvailable {
                
                motionManager.accelerometerUpdateInterval = 1.0/60.0
                motionManager.startAccelerometerUpdates()
                
            } else {
                //alert cannot use gyroscope
            }
        }
        else {
            //alert cannot use gyroscope
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadMainMenu:"), name: "home_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resumeTutorial:"), name: "resume_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retryTutorial:"), name: "retry_touch_ended", object: nil)
    
    }
    
    
    override func onEnter() {
        
        super.onEnter()
        progressState++
        
    }
    
    override func onExit() {
        
        super.onExit()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }

    override func update(delta: CCTime) {
        
        /*if startYaw == nil {
        
            startYaw = motionManager.deviceMotion.attitude.yaw

        }*/

        
        if gyroUserEnabled {
            
            yaw = Float(motionManager.accelerometerData.acceleration.y) * Float(2.0)
            yaw = clampf(yaw, Float(-0.70), Float(0.70))
            
            
            if yaw < Float(0.01) && yaw > Float(-0.01) {
                yaw = 0.0
                
            } else  {
                
                if heroState != .Jump {
                    
                    heroState = .Run
                }
            }
            
            if yaw > Float(0.01) {
                
                hero.physicsBody.velocity.x = 650 * abs(CGFloat(yaw))
                
            } else if yaw < Float(0.01) {
                
                hero.physicsBody.velocity.x = -650 * abs(CGFloat(yaw))
                
            } else {
                
                hero.physicsBody.velocity.x = 0
                
            }
            
            //recognize that the user has learned the moving mechanic
            if (yaw >= Float(0.5) || yaw <= Float(-0.5)) && progressState == 0 {
            
                progressState++

            }
            
            let boundRight = CGPointZero.x + Constants.screenWidth
            let boundLeft = CGPointZero.x
            
            //hero.position is in percentage so I have to convert to points by multiplying by screen width
            if (hero.position.x * Constants.screenWidth) + hero.boundingBox().width/2 >= boundRight && yaw > 0 {
                
                hero.physicsBody.velocity.x = 0
                
            } else if (hero.position.x * Constants.screenWidth) - hero.boundingBox().width/2 <= boundLeft && yaw < 0{
                
                hero.physicsBody.velocity.x = 0
            }
        }
        
    
        
        
    }
    
    func applyJump() {
        
        heroState = .Jump
        if jumpTime == 0.7 {
            hero.physicsBody.velocity.y = CGFloat(300)
            jumpTime -= 0.06
        }
        else if jumpTime > 0.0 {
            
            hero.physicsBody.velocity.y = CGFloat(jumpTime * 10 * 50)
            jumpTime -= 0.015
            
        }  else {
            
            jumpScheduler!.invalidate()
            
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
            
            whiteSpike.opacity = 0.0
            whiteSpike.visible = true
            whiteSpike.runAction(CCActionSequence(array: [CCActionFadeIn(duration: 0.5), CCActionCallBlock(block: { self.startSpikeCollisionDetection = true })]))
            
        case 3:
            
            switchUserEnabled = true
            
            if switchUserEnabled {
                colorToggleNode.visible = true
                colorToggleNode.animationManager.runAnimationsForSequenceNamed("Pulse")
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("colorToggle:"), name: "color_toggle", object: nil)
            }
            
        case 4:
            colorToggleNode.animationManager.runAnimationsForSequenceNamed("Default Timeline")
            
            break

        case 5:
            
            endPortal.visible = true
            
        case 6:
            
            let loadMainMenu = CCActionCallFunc(target: self, selector: Selector("returnToMainMenu"))
            let delay = CCActionDelay(duration: 1.5)
            
            self.runAction(CCActionSequence(array: [delay, loadMainMenu]))
            
        default:
            
            break
        }

       
    }
    
    
    // MARK: Observer selectors
    
    func colorToggle(notification: NSNotification) {
        
        if switchUserEnabled == true {
            hero.toggle()
        
            if progressState == 3 {
            
                progressState++
            
            }
        }
        
    }
    
    func loadMainMenu(notification: NSNotification) {
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        pauseMenu.removeFromParent()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }

    //called when tutorial is complete
    func returnToMainMenu() {
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
    func resumeTutorial(notification: NSNotification) {
        
        //animation has call back that will remove pauseMenu Node from gameScene
        gyroUserEnabled = true
        pauseMenu.runAction(CCActionFadeOut(duration: 0.5))
        pauseButton.visible = true
        pauseMenu.removeFromParent()
        
        
    }
    
    func retryTutorial(notification: NSNotification) {
        
        var tutorialScene = CCBReader.load("TutorialScene")
        
        var scene = CCScene()
        scene.addChild(tutorialScene)
        
        pauseMenu.removeFromParent()
        
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(moveInWithDirection: CCTransitionDirection(rawValue: 2)!, duration: 1.0))
    }
    
    // END Observer selectors
    
    func triggerGamePause() {
        
        gyroUserEnabled = false
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
        
        if tapUserEnabled == false && progressState == 1{

            hero.physicsBody.velocity.y = 300
    
            progressState++
            tapUserEnabled = true
        }
        
        if heroState != .Jump {
            
            jumpScheduler = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("applyJump"), userInfo: nil, repeats: true)
        }
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, normalPlatform: CCNode!) -> ObjCBool {
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        heroState = .Run
        jumpTime = 0.7
        return true
        
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, whiteSpike: CCSprite!) -> ObjCBool {
        
        if hero.colorMode == "white"  && progressState == 2 && startSpikeCollisionDetection {
            //this should always run
            //user has not been allowed to switch colors yet
            progressState++
            return false
            
        } else if hero.colorMode == "white" && progressState != 2 {
            
            return false
            
        } else if hero.colorMode == "black" && progressState >= 4 && startSpikeCollisionDetection {
            
            startSpikeCollisionDetection = false
            gyroUserEnabled = false
            hero.deadAnim()
            hero.physicsBody.type = CCPhysicsBodyType(rawValue: 2)!
            deathFlashNode.runAction(CCActionSequence(array: [CCActionFadeIn(duration: 0.2), CCActionFadeOut(duration: 0.2)]))
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))


            let resetSequence = CCActionSequence(array: [CCActionDelay(duration: 1.5), CCActionCallBlock(block: {
                self.heroState = .Idle;
                hero.rotation = 0.0;
                hero.physicsBody.velocity = CGPointZero;
                hero.physicsBody.type = CCPhysicsBodyType(rawValue: 0)!
                hero.positionInPoints = CGPointMake(120, 106.5);
                self.gyroUserEnabled = true;
                self.startSpikeCollisionDetection = true
                
            })])
            
            hero.runAction(resetSequence)
            
            if progressState == 4 {
                progressState++
            }
           return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, endPortal: CCNode!) -> ObjCBool {
        
        if progressState >= 5 {
            gyroUserEnabled = false
            hero.physicsBody.velocity = CGPointZero
            hero.physicsBody.type = CCPhysicsBodyType(rawValue: 2)!
            hero.physicsBody.collisionMask = []
            
            let moveToPlatform = CCActionMoveTo(duration: 0.5, position: CGPointMake(self.endPortal.position.x, self.endPortal.position.y + self.endPortal.boundingBox().height/Constants.screenHeight))
            hero.runAction(CCActionSequence(array: [moveToPlatform, CCActionCallBlock(block: {progressState++})]))
           
        }
            
            return false
        
    }
}