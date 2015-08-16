//
//  InstructionalLevelScene.swift
//  Proto
//
//  Created by Rushil Patel on 8/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import CoreMotion

class InstructionalPlayScene: CCNode, CCPhysicsCollisionDelegate {
    
    
    //---User Activity State---//
    var userActivityState = UserState()
    //--------- END --------//

    weak var levelNode: CCNode!
    weak var gameTimerLabel: CCLabelTTF!
    weak var colorToggle: CCNode!
    weak var deathFlashNode: CCNode!
    weak var pauseButton: CCNode!
    var hero: Hero = CCBReader.load("Hero") as! Hero
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var cameraTargetNode: CCNode!
    
    
    var level: Level!
    var pauseMenu: PauseScene!
    
    
    var gameState: GameState = .Play
    let motionManager = CMMotionManager()
    var yaw: Float = 0.0
    var gameTimer: Double = 0.0
    var heroState: HeroAction = .Idle {
        willSet(newValue) {
            
            if newValue == .Idle && heroState != .Idle {
                hero.idleAnim()
            } else if newValue == .Jump && heroState != .Jump {
                hero.jumpAnim()
            } else if newValue == .Run && heroState != .Run {
                hero.runAnim()
            }
        }
    }
    var jumpTime: Float = 0.7
    var jumpScheduler: NSTimer?
    
    
    
    func didLoadFromCCB() {
        
        
        
        //NSNOTIFICATION OBSERVERS
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleHeroColor:"), name: "color_toggle", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadMainMenu:"), name: "home_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resumeLevel:"), name: "resume_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retryLevel:"), name: "retry_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadNextLevel:"), name: "next_touch_ended", object: nil)

        
        gamePhysicsNode.collisionDelegate = self
        gamePhysicsNode.space.collisionBias = 0
        CCDirector.sharedDirector().fixedUpdateInterval = 1.0/180.0
        
        gameState = .Play
        gamePhysicsNode.position = CGPointZero
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0/60.0
            motionManager.startDeviceMotionUpdates()
            
            if motionManager.accelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 1.0/60.0
                motionManager.startAccelerometerUpdates()
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
                
        self.levelNode.addChild(level)
        
        if level.currentLevel == "Levels/Tut1" {
            
            userInteractionEnabled = false
            gameTimerLabel.visible = true
            colorToggle.scale = 0.001
            
        } else if level.currentLevel == "Levels/Tut2" {
            userInteractionEnabled = true
            gameTimerLabel.visible = true
            colorToggle.scale = 0.001
            
        } else if level.currentLevel == "Levels/Tut3" {
            
            userInteractionEnabled = true
            gameTimerLabel.visible = true
            colorToggle.scale = 0.001
            
        } else if level.currentLevel == "Levels/Tut4" {
            
            userInteractionEnabled = true
            gameTimerLabel.visible = true
            colorToggle.scale = 1.0
            self.animationManager.runAnimationsForSequenceNamed("PulseColorToggleButton")
            
            userInteractionEnabled = true
            gameTimerLabel.visible = true
            colorToggle.scale = 0.01
            
            
        } else if level.currentLevel == "Levels/Tut5" {
            
            
            userInteractionEnabled = true
            gameTimerLabel.visible = true
            colorToggle.scale = 1.0
            self.animationManager.runAnimationsForSequenceNamed("PulseColorToggleButton")
            
            
        } else if level.currentLevel == "Levels/Tut6" {
            
            userInteractionEnabled = true
            gameTimerLabel.visible = true
            colorToggle.scale = 1.0

            
        }
    }
    
    override func onExit() {
        super.onExit()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    
    override func  update(delta: CCTime) {
        
        if gameState == .Play {
            
            gameTimer = gameTimer + delta
            gameTimerLabel.string =  NSString(format: "%.2f", gameTimer) as String
            
            yaw = Float(motionManager.accelerometerData.acceleration.y) * Float(2.0)
            yaw = clampf(yaw, Float(-0.8), Float(0.8))
            
            if yaw < Float(0.01) && yaw > Float(-0.01) {
                yaw = 0.0
                if heroState != .Jump {
                    
                    //heroState = .Idle
                }
                
            } else  {
                if heroState != .Jump {
                    
                    //heroState = .Run
                }
            }
            
            if yaw > Float(0.01) {
                
                hero.physicsBody.velocity.x = 475 * abs(CGFloat(yaw))
                
            } else if yaw < Float(0.01) {
                
                hero.physicsBody.velocity.x = -475 * abs(CGFloat(yaw))
                
            } else {
                
                hero.physicsBody.velocity.x = 0
                
            }
            
            let boundRight = level.position.x + level.boundingBox().width
            let boundLeft = level.position.x
            
            if (hero.position.x * Constants.screenWidth + hero.boundingBox().width/2) >= boundRight && yaw > 0 {
                
                hero.physicsBody.velocity.x = 0
                
            } else if (hero.position.x * Constants.screenWidth - hero.boundingBox().width/2) <= boundLeft && yaw < 0 {
                
                hero.physicsBody.velocity.x = 0
            }
            
            
            //check for gameOver
            //hero anchor point is at 0.5, 0
            let heroHeight = hero.position.y * Constants.screenHeight + hero.boundingBox().height
            
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

    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if heroState == .Run || heroState == .Idle {
            if gameState == .Play {
                hero.physicsBody.velocity.y = 300
            }
            jumpScheduler = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("applyJump"), userInfo: nil, repeats: true)
            
            hero.jumpAnim()
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if let jumpScheduler = jumpScheduler {
            
            jumpScheduler.invalidate()
            
        }
    }
    
    func applyJump() {
        
        if gameState == .Play {
            
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
    }
    

    func triggerGamePause() {
        
        gameState = .Pause
        hero.physicsBody.velocity = CGPointZero
        heroState = .Idle
        colorToggle.visible = false
        
        gamePhysicsNode.paused = false

        
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
        heroState = .Idle
        hero.physicsBody.velocity = CGPointZero
        
        gameTimerLabel.visible = false
        colorToggle.visible = false

        
        gamePhysicsNode.paused = true


       
        if let jumpScheduler = jumpScheduler {
            
            jumpScheduler.invalidate()
            
        }
        
        //load up the level complete screen and set the time labels
        var levelCompleteScreen = CCBReader.load("LevelComplete", owner: self) as! LevelCompleteScene
        levelCompleteScreen.currentTimeLabel.string = gameTimerLabel.string
        
        //Handle Best Time/ Current Time stuff
        if let timeDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey("bestTimesDictionary") as? Dictionary<String, String> {
            
            let currentTime = gameTimerLabel.string
            
            //get bestTime if it exists
            if let bestTime = timeDictionary[level.currentLevel] {
                
                //compare both to bestTime and reset if needed
                if (currentTime as NSString).floatValue < (bestTime as NSString).floatValue {
                    
                    userActivityState.updateBestTimes(level.currentLevel, timeValue: currentTime)
                    levelCompleteScreen.bestTimeLabel.string = currentTime
                    levelCompleteScreen.newPrefixBestTimeLabel.visible = true
                    levelCompleteScreen.newPrefixBestTimeLabel.runAction(CCActionFadeIn(duration: 0.5))
                    levelCompleteScreen.bestTimeLabel.fontColor = levelCompleteScreen.newPrefixBestTimeLabel.fontColor

                
                    
                    //animate NEW BEST TIME SCORE
                    
                } else {
                    //set bestTimelabel to best time
                    levelCompleteScreen.bestTimeLabel.string = bestTime
                    
                }
                
            } else {
                
                //best time does not exist
                //set current time to best time
                userActivityState.updateBestTimes(level.currentLevel, timeValue: currentTime)
                levelCompleteScreen.bestTimeLabel.string = gameTimerLabel.string
                levelCompleteScreen.newPrefixBestTimeLabel.visible = true
                levelCompleteScreen.newPrefixBestTimeLabel.runAction(CCActionFadeIn(duration: 0.5))
                levelCompleteScreen.bestTimeLabel.fontColor = levelCompleteScreen.newPrefixBestTimeLabel.fontColor
                
            }
            
            
        }
        
        //Handle Stars Earned Stuff
        
        if let starsDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey("starsEarnedDictionary") as? Dictionary<String, Int> {
            
            let currentTime = (gameTimerLabel.string as NSString).floatValue
            
            if currentTime < 1.0 * level.threeStarTime {
                
                levelCompleteScreen.animationManager.runAnimationsForSequenceNamed("spawn3Stars")
                if let mostStarsEarned = starsDictionary[level.currentLevel] {
                    
                    if mostStarsEarned <= 3 {
                        
                        userActivityState.updateStarsEarned(3, levelKey: level.currentLevel)
                        
                    }
                    
                } else {
                    
                    userActivityState.updateStarsEarned(3, levelKey: level.currentLevel)
                }
                
            } else if currentTime < 1.5 * level.threeStarTime {
                
                levelCompleteScreen.animationManager.runAnimationsForSequenceNamed("spawn2Stars")
                
                if let mostStarsEarned = starsDictionary[level.currentLevel] {
                    
                    if mostStarsEarned < 2 {
                        
                        userActivityState.updateStarsEarned(2, levelKey: level.currentLevel)
                        
                    }
                    
                } else {
                    
                    userActivityState.updateStarsEarned(2, levelKey: level.currentLevel)
                }
                
                
            } else {
                
                levelCompleteScreen.animationManager.runAnimationsForSequenceNamed("spawn1Stars")
                if let mostStarsEarned = starsDictionary[level.currentLevel] {
                    
                    if mostStarsEarned < 1 {
                        
                        userActivityState.updateStarsEarned(1, levelKey: level.currentLevel)
                        
                    }
                } else {
                    
                    userActivityState.updateStarsEarned(1, levelKey: level.currentLevel)
                }
            }
            
        }
        
        //if level.currentLevel != "Levels/Tut7" {
            
            levelCompleteScreen.currentTimeLabel.visible = true
            levelCompleteScreen.currentTimeTextLabel.visible = true
            levelCompleteScreen.bestTimeLabel.visible = true
            levelCompleteScreen.bestTimeTextLabel.visible = true
        //}
        
        //animate the stars based user time
        
        self.addChild(levelCompleteScreen)
    }
    
    
    func triggerGameOver() {
        
        gameState = .GameOver
        pauseButton.removeFromParent()

        
        
        
        hero.physicsBody.velocity = CGPointZero
        hero.deadAnim()
        hero.physicsBody.type = CCPhysicsBodyType(rawValue: 2)!
        
        for child in level.children {
            child.stopAllActions()
        }
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        hero.physicsBody.velocity.x = 0
        hero.physicsBody.velocity.y = 0
        
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        if hero.colorMode == "white" {
            deathFlashNode.colorRGBA = CCColor(red: 1.0, green: 1.0, blue: 1.0)
            
        } else if hero.colorMode == "black" {
            deathFlashNode.colorRGBA = CCColor(red: 0.0, green: 0.0, blue: 0.0)
        }
        deathFlashNode.runAction(CCActionSequence(array: [CCActionFadeIn(duration: 0.2), CCActionFadeOut(duration: 0.2)]))
        
        let restartLevel = CCActionCallBlock {
            
            var gameScene = CCBReader.load("InstructionalPlay") as! InstructionalPlayScene
            gameScene.level = CCBReader.load(self.level.currentLevel) as! Level
            
            var scene = CCScene()
            scene.addChild(gameScene)
            CCDirector.sharedDirector().replaceScene(scene)
            
        }
        
        self.runAction(CCActionSequence(array: [CCActionDelay(duration: 0.5), restartLevel]))
        
    }
    
    
    func loadNextLevel(notification: NSNotificationCenter) {
        var scene = CCScene()
        
        
        if level.nextLevel == "Levels/Level1" {
            var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
            gameScene.level = CCBReader.load(level.nextLevel) as! Level
            
            scene.addChild(gameScene)
    
        
        } else {
        
            var instructionScene = CCBReader.load("InstructionalPlay") as! InstructionalPlayScene
            instructionScene.level = CCBReader.load(level.nextLevel) as! Level
        
            scene.addChild(instructionScene)
        }
        
        CCDirector.sharedDirector().replaceScene(scene)
        
    }
    
    func loadMainMenu(notification: NSNotification) {
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
    func resumeLevel(notification: NSNotification) {
        
        if gamePhysicsNode.paused == true {
            gamePhysicsNode.paused = false
        }
        
        //animation has call back that will remove pauseMenu Node from gameScene
        pauseMenu.runAction(CCActionFadeOut(duration: 0.5))
        pauseButton.visible = true
        pauseMenu.removeFromParent()
        gameState = .Play
        
        
    }
    
    func retryLevel(notification: NSNotification) {
        
        var instructionScene = CCBReader.load("InstructionalPlay") as! InstructionalPlayScene
        instructionScene.level = CCBReader.load(level.currentLevel) as! Level
        
        var scene = CCScene()
        scene.addChild(instructionScene)
        
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(moveInWithDirection: CCTransitionDirection(rawValue: 2)!, duration: 1.0))
    }
    
    func toggleHeroColor(notification: NSNotificationCenter) {
        hero.toggle()
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, blackPlatform: Platform!) -> ObjCBool {
        
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
            
            heroState = .Run
            
            return true
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, normalPlatform: CCNode!) -> ObjCBool {
        
                
            heroState = .Run
            
            //reset jump timer for next jump
            jumpTime = 0.7

        return true
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, whitePlatform: Platform!) -> ObjCBool {
        
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
            
            heroState = .Run
            
            return true
            
        }
        
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero : Hero!, blackSpike: CCSprite!) -> ObjCBool {
        
        if hero.colorMode == "black" {
            
            return false
            
        }
        else {
            
            if gameState != .GameOver {
                
                triggerGameOver()
                
            }
            
            return false
    
        }
    }
    
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero : Hero!, whiteSpike: CCSprite!) -> ObjCBool {
        
        if hero.colorMode == "white" {
            
            return false
            
        } else {
            
            if gameState != .GameOver {
                
                hero.physicsBody.collisionMask = []
                triggerGameOver()
                
            }
            
            return false
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, endPortal: CCSprite!) -> ObjCBool {
        
        hero.physicsBody.velocity = CGPointZero
        
        if gameState != .GameWon {
            
            let triggerWin = CCActionCallFunc(target: self, selector: Selector("triggerLevelWon"))
            pauseButton.visible = false

            let moveToPlatform = CCActionMoveTo(duration: 1.0, position: CGPointMake(level.endPortal.position.x, level.endPortal.position.y + level.endPortal.boundingBox().height))
            
            hero.runAction(CCActionSequence(array: [moveToPlatform, triggerWin]))
        }
        
        gameState = .GameWon
        return false
    }
    
    
    
    
    
    
    
}
