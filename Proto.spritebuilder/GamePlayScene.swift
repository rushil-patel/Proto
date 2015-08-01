//
//  GamePlayScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import CoreMotion

enum GameState {
    case Play, Pause, GameOver, Starting, GameWon
}

enum Action {
    case Run, Jump, Idle, Fall
}

enum ColorMode {
    case None, Black, White
}

enum PowerState  {
    case None, SlowMotion, Shield
}

struct Constants {
    static let slowMotionCoeff: Float = 0.5
    static let powerFrequency: Float = 0.5
    static let screenHeight: CGFloat = CCDirector.sharedDirector().viewSize().height
    static let screenWidth: CGFloat = CCDirector.sharedDirector().viewSize().width
}

class GamePlayScene: CCNode, CCPhysicsCollisionDelegate {
    
    //code connection
    weak var hero: Hero!
    weak var heartCounterLabel: CCLabelTTF!
    weak var levelNode: CCNode!
    weak var cameraTargetNode: CCNode!
    weak var pauseButton: CCButton!

    var pauseMenu: PauseScene!
    
    //gameplay physics node connection
    weak var gamePhysicsNode: CCPhysicsNode!
    
    
    //Game variables
    var platforms: [Platform] = []
    var gameState: GameState = .Play
    var level: Level!
    var actionFollow: CCActionFollow!
    var didStartTap: Bool = true
    let motionManager = CMMotionManager()
    var startYaw : Double!
    var yaw: Float = 0.0
    
    //MARK: Game Dependent Variabes
    var gameSpeed: Float = 0
    var maxAirTimeSquared: Float = 2.0
    var minPlatformSpacing: Float = 100.0 * 1.0
    var maxPlatformSpacing: Float = 100.0 * 2.0
    var heartsCollected: Int = 0
    var jumpTime: Float = 0.7
    //-1 = left , 0 = unset, 1 = right
    var lastHeroDirection = 0
    
    
    //Mark: Schedulers
    var jumpScheduler: NSTimer?
    var slowMotionScheduler: NSTimer?
    var onEnterDelay: NSTimer?
    var moveScheduler: NSTimer?

    
    func didLoadFromCCB() {
        
        //lock orientation to landscape left
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleHeroColor"), name: "color_toggle", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadMainMenu"), name: "home_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resumeLevel"), name: "resume_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retryLevel"), name: "retry_touch_ended", object: nil)
        
        //enable user inteaction
        userInteractionEnabled = true
        
        //gamePhysicsNode.debugDraw = true
        
        //set physics collision delegate to self
        gamePhysicsNode.collisionDelegate = self
        
        
        if CCDirector.sharedDirector().paused {
        
            CCDirector.sharedDirector().resume()
        }
        
        
        //initialize game variables
        heartsCollected = 0
        gameState = .Play
        gamePhysicsNode.position = CGPointZero
        didStartTap = true
        
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
        
        if level == nil {
            level = CCBReader.load("Levels/Level1") as! Level
        }
        
        //level will be set from previous level
        levelNode.addChild(level)
        
        hero.position = CGPointMake(CGFloat(level.startPosX), CGFloat(level.startPosY))

        cameraTargetNode.position.x =  Constants.screenWidth/2
        
        actionFollow = CCActionFollow(target: cameraTargetNode , worldBoundary: level.boundingBox())
        gamePhysicsNode.runAction(actionFollow)
        
    }
    
    override func onExit() {
        super.onExit()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func fixedUpdate(delta: CCTime) {

        cameraTargetNode.position.x = Constants.screenWidth/2 - CGFloat(level.startPosX) + hero.position.x
        
    }
    
    override func update(delta: CCTime) {
        
        if startYaw == nil {
            startYaw = motionManager.deviceMotion.attitude.yaw
            
        }


        if let deviceMotion = motionManager.deviceMotion {
            let currentAttitude = deviceMotion.attitude
            yaw = Float(currentAttitude.yaw)
           // println("\(startPitch) : \(pitch)")
        }

        
        if didStartTap == true {
            
            if gameState == .Play {
        
                yaw = clampf(yaw, Float(0.4), Float(-0.4))
                
                if yaw < Float(startYaw + 0.01) && yaw > Float(startYaw - 0.01) {
                    yaw = Float(startYaw)
                    hero.state = .Idle
                
                } else  {
                    if hero.state != .Jump || hero.state != .Fall {
                        
                        hero.state = .Run
                    }
                }
                
                if yaw > Float(startYaw + 0.05) {
                    
                    hero.physicsBody.velocity.x = -700 * abs(CGFloat(yaw))

                } else if yaw < Float(startYaw - 0.05) {
                    
                    hero.physicsBody.velocity.x = 700 * abs(CGFloat(yaw))

                } else {
                   
                    hero.physicsBody.velocity.x = 0

                }

                
                
               /* if hero.physicsBody.velocity.x < 150 {
                    hero.physicsBody.velocity.x += 10
                    hero.physicsBody.velocity.x *= 2
                }
               
                */
                        
               /* if hero.state == .Idle {
                    
                    //accelerate Game speed from 0 -> 100 (for beginning game and slow downs
                    hero.state = .Run
                    
                }
                */
                
                //check for gameOver
                let heroHeight = hero.position.y + hero.boundingBox().height / 2
                
                if heroHeight < 0 {
                    
                    //hero has fallen below screen GAME OVER
                    if gameState != .GameOver {
                        triggerGameOver()
                    }
                }
                
                
            } else if gameState == .Pause {
                
                
            } else if gameState == .GameOver {
                
                
            } else if gameState == .GameWon {
                
            }
        }
    }
    
    
    //MARK: Touch Handling
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if didStartTap {
            if hero.state == .Run || hero.state == .Idle {
               
                hero.physicsBody.velocity.y = 300
                jumpScheduler = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("applyJump"), userInfo: nil, repeats: true)
                hero.state = .Jump
                hero.jumpAnim()
            }
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {

        if didStartTap == false {
            didStartTap = true
        } else {
            
            if let jumpScheduler = jumpScheduler {
                jumpScheduler.invalidate()
                hero.state == .Fall
            }
        }
        
    }


    func updateHeartCounter() {
        heartCounterLabel.string = "\(heartsCollected)"
    }
    
    func triggerGamePause() {
        
       // CCDirector.sharedDirector().pause()
        gameState = .Pause
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
    
    func triggerLevelWon() {
        
        gameState = .GameWon
        gamePhysicsNode.stopAction(actionFollow)
        hero.idleAnim()
        hero.physicsBody.velocity = CGPointZero

        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        
        var levelCompleteScreen = CCBReader.load("LevelComplete", owner: self) as! LevelCompleteScene
        self.addChild(levelCompleteScreen)
    }
    

    
    
    func triggerGameOver() {
        
        gameState = .GameOver
        gamePhysicsNode.stopAction(actionFollow)
        
        hero.physicsBody.velocity.x = 0
        hero.physicsBody.velocity.y = 0
        
        gameState = .GameOver
        
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        // CCDirector.sharedDirector().pause()
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOverScene
        self.addChild(gameOverScreen)
        
        
    }
    
    func retryLevel() {

        var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
        gameScene.level = CCBReader.load(level.currentLevel) as! Level
        
        var scene = CCScene()
        scene.addChild(gameScene)
        
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(moveInWithDirection: CCTransitionDirection(rawValue: 2)!, duration: 1.0))
    }
    
    func loadNextLevel() {
        
        var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
        gameScene.level = CCBReader.load(level.nextLevel) as! Level
        
        var scene = CCScene()
        scene.addChild(gameScene)
        
        CCDirector.sharedDirector().replaceScene(scene)

    }
    

    func resumeLevel() {
        
        //animation has call back that will remove pauseMenu Node from gameScene
        pauseMenu.runAction(CCActionFadeOut(duration: 0.5))
        pauseButton.visible = true
        pauseMenu.removeFromParent()
        
        
    }
    
    func loadMainMenu() {
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
    
    //selector: toggles the sprites color
    func toggleHeroColor() {
        hero.toggle()
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
            //hero.state = .Fall
            
        }
        
        
    }
    
    
    
    //called from accelStartScheduler every .05 seconds
/*    func accelStart() {
        gameSpeed *= 1.1
        
        if gameSpeed >= 400  && hero.powerState != .SlowMotion {
            
            accelStartScheduler!.invalidate()
            
            //set gameSpeed accelerator scheduler
            accelScheduler = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("speedUpGame"), userInfo: nil, repeats: true)
        }
    }
*/    
    
    //called from accelScheduler every 2 seconds
    /*func speedUpGame() {
        
        if gameSpeed <= 1000 && hero.powerState != .SlowMotion {
            gameSpeed *=  1 + log10(gameSpeed) / (gameSpeed * log2(gameSpeed) * 5)
        } else if hero.powerState != .SlowMotion {
            //do nothing
        } else {
            gameSpeed *= 1 + (1 / (gameSpeed * gameSpeed))
        }
        
        maxAirTimeSquared = Float(Constants.screenHeight/hero.lift + ((-2 * Constants.screenHeight)/gamePhysicsNode.gravity.y))
        maxPlatformSpacing = sqrt(maxAirTimeSquared) * gameSpeed
        minPlatformSpacing = gameSpeed * 1.0
        
    }
*/

    
    
    
    //MARK: Collision Handling
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, blackPlatform: Platform!) -> ObjCBool {
        
        if hero.colorMode == "black" {
            
            return false
            
        } else {
            
            hero.runAnim()

            //invalidate jump scheduler
            if let jumpScheduler = jumpScheduler {
                jumpScheduler.invalidate()
            }
            //reset jump timer for next jump
            jumpTime = 0.7

            hero.state = .Run
            
            return true
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, normalPlatform: CCNode!) -> ObjCBool {
        
        if hero.state != .Idle {

            hero.runAnim()
        }
        
        hero.state = .Run
        
        //reset jump timer for next jump
        jumpTime = 0.7
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, whitePlatform: Platform!) -> ObjCBool {
        
        if hero.colorMode == "white" {
            
            return false
            
        } else {
            
            hero.runAnim()
            
            //invalidate jump scheduler
            if let jumpScheduler = jumpScheduler {
                jumpScheduler.invalidate()
            }
            
            //reset jump timer for next jump
            jumpTime = 0.7

            hero.state = .Run
            
            return true
            
        }
        
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero : Hero!, blackSpike: CCSprite!) -> ObjCBool {
        
        if hero.colorMode == "black" {
            return false
        }
        else {
            triggerGameOver()
            return true
        }
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero : Hero!, whiteSpike: CCSprite!) -> ObjCBool {
        
        if hero.colorMode == "white" {
                return false
            
        } else {
            
            triggerGameOver()
            return true
        }
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero : Hero!, heart : CCSprite!) -> ObjCBool {
        
        heartsCollected++
        updateHeartCounter()
        heart.removeFromParent()
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, princess: CCSprite!) -> ObjCBool {

        triggerLevelWon()
        return false
    }
    
}



