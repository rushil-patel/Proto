//
//  GamePlayScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import CoreMotion
import AudioToolbox

enum GameState {
    case Play, Pause, GameOver, Starting, GameWon
}

enum ColorMode {
    case None, Black, White
}



enum HeroAction {
    case Run, Jump, Idle
}


struct Constants {
    static let screenHeight: CGFloat = CCDirector.sharedDirector().viewSize().height
    static let screenWidth: CGFloat = CCDirector.sharedDirector().viewSize().width
}

class GamePlayScene: CCNode, CCPhysicsCollisionDelegate {

    
    //---User Activity State---//
    var userActivityState = UserState()
    //--------- END --------//
    
    //code connections
    var hero: Hero = CCBReader.load("Hero") as! Hero
    weak var levelNode: CCNode!
    weak var cameraTargetNode: CCNode!
    weak var pauseButton: CCButton!
    weak var gameTimerLabel: CCLabelTTF!
    weak var deathFlashNode: CCNode!
    weak var colorToggle: ColorToggle!
    var pauseMenu: PauseScene!
    
    //gameplay physics node connection
    weak var gamePhysicsNode: CCPhysicsNode!
    
    
    //Game variables
    var platforms: [Platform] = []
    var gameState: GameState = .Play
    var level: Level!
    var actionFollow: CCActionFollow!
    let motionManager = CMMotionManager()
    var yaw: Float = 0.0
    var gameTimer: Double = 0.0
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
    
    var loadingNextLevel = false
    
    //MARK: Game Dependent Variabes
    var jumpTime: Float = 0.7

    
    
    //Mark: Schedulers
    var jumpScheduler: NSTimer?

    
    func didLoadFromCCB() {
        
        gamePhysicsNode.space.collisionBias = 0
        CCDirector.sharedDirector().fixedUpdateInterval = 1.0/180.0
        
        //lock orientation to landscape left
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleHeroColor:"), name: "color_toggle", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadMainMenu:"), name: "home_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resumeLevel:"), name: "resume_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retryLevel:"), name: "retry_touch_ended", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadNextLevel:"), name: "next_touch_ended", object: nil)
        
        //enable user inteaction
        userInteractionEnabled = true
        
       //gamePhysicsNode.debugDraw = true
        
        //set physics collision delegate to self
        gamePhysicsNode.collisionDelegate = self
        
        
        if CCDirector.sharedDirector().paused {
        
            CCDirector.sharedDirector().resume()
        }
        
        
        //initialize game variables
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
        
        if level == nil {
            level = CCBReader.load("Levels/Level1") as! Level
        }
        
        //level will be set from previous level
        levelNode.addChild(level)
        
        hero.position = CGPointMake(CGFloat(level.startPosX), CGFloat(level.startPosY))

        cameraTargetNode.position.x =  Constants.screenWidth/2
        cameraTargetNode.position.y = Constants.screenHeight/2
        
        actionFollow = CCActionFollow(target: cameraTargetNode , worldBoundary: level.boundingBox())
        gamePhysicsNode.runAction(actionFollow)
    
    }
    
    override func onExit() {
        super.onExit()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func fixedUpdate(delta: CCTime) {
        cameraTargetNode.position.x = Constants.screenWidth/2 - CGFloat(level.startPosX) + hero.position.x
        cameraTargetNode.position.y = Constants.screenHeight/2 - CGFloat(level.startPosY) + hero.position.y
        
    }
    
    override func update(delta: CCTime) {
        
    
            if gameState == .Play {
                
                gameTimer = gameTimer + delta
                gameTimerLabel.string =  NSString(format: "%.2f", gameTimer) as String
                
                yaw = Float(motionManager.accelerometerData.acceleration.y) * Float(2.0)
                yaw = clampf(yaw, Float(-0.80), Float(0.80))
        
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
                
                if hero.position.x + hero.boundingBox().width/2 >= boundRight && yaw > 0{
        
                    hero.physicsBody.velocity.x = 0
                    
                } else if hero.position.x - hero.boundingBox().width/2 <= boundLeft && yaw < 0{
                    
                    hero.physicsBody.velocity.x = 0
                }
        
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
    
    
    //MARK: Touch Handling
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
            if heroState == .Run || heroState == .Idle {
                if gameState == .Play {
                    hero.physicsBody.velocity.y = 300
                }
                jumpScheduler = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("applyJump"), userInfo: nil, repeats: true)

                hero.jumpAnim()
            }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if let jumpScheduler = jumpScheduler {
        
            jumpScheduler.invalidate()
        
        }
        

        
    }

    
    func triggerGamePause() {
        
        gamePhysicsNode.paused = true
        
        gameState = .Pause
        hero.physicsBody.velocity = CGPointZero
        
        pauseButton.visible = false
        colorToggle.visible = false

        pauseMenu = CCBReader.load("PauseScene") as! PauseScene
        pauseMenu.cascadeOpacityEnabled = true
        self.addChild(pauseMenu)
        pauseMenu.runAction(CCActionFadeIn(duration: 0.1))
    
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
    }
    
    func triggerLevelWon() {
        
        gamePhysicsNode.paused = true
        
        gameState = .GameWon
        gamePhysicsNode.stopAction(actionFollow)
        hero.idleAnim()
        hero.physicsBody.velocity = CGPointZero
        hero.physicsBody.type = CCPhysicsBodyType(rawValue: 2)!
        
        gameTimerLabel.visible = false
        colorToggle.visible = false

        pauseButton.removeFromParent()
        
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
                    userActivityState.updateBestTimes(level.currentLevel, timeValue: currentTime)
                    levelCompleteScreen.bestTimeLabel.string = gameTimerLabel.string
                    levelCompleteScreen.newPrefixBestTimeLabel.visible = true
                    levelCompleteScreen.newPrefixBestTimeLabel.runAction(CCActionFadeIn(duration: 0.5))
                    levelCompleteScreen.bestTimeLabel.fontColor = levelCompleteScreen.newPrefixBestTimeLabel.fontColor
                    
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
        
        //animate the stars based user time
        
        
            
        self.addChild(levelCompleteScreen)
    }
    

    
    
    func triggerGameOver() {
       
        
        gameState = .GameOver
        pauseButton.removeFromParent()
        gamePhysicsNode.stopAction(actionFollow)
        
        hero.physicsBody.velocity = CGPointZero
        hero.deadAnim()
        hero.physicsBody.type = CCPhysicsBodyType(rawValue: 2)!
        
        for child in level.children {
            child.stopAllActions()
        }
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    
        
        
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
            
            var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
            gameScene.level = CCBReader.load(self.level.currentLevel) as! Level
            
            var scene = CCScene()
            scene.addChild(gameScene)
            CCDirector.sharedDirector().replaceScene(scene)
        }
        
        self.runAction(CCActionSequence(array: [CCActionDelay(duration: 1.5), restartLevel]))
    }
    
    func retryLevel(notification: NSNotification) {

        var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
        gameScene.level = CCBReader.load(level.currentLevel) as! Level
        
        var scene = CCScene()
        scene.addChild(gameScene)
        
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(moveInWithDirection: CCTransitionDirection(rawValue: 2)!, duration: 1.0))
    
    }
    
    func loadNextLevel(notification: NSNotification) {
        
        gameState = .Pause
        if loadingNextLevel == false {
            
            if level.nextLevel == "End" {
                
                
                let epilogue = CCBReader.load("Epilogue")
                self.addChild(epilogue)
                userInteractionEnabled = false
                NSNotificationCenter.defaultCenter().removeObserver(self)
                
                
            } else {
            
                var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
                gameScene.level = CCBReader.load(level.nextLevel) as! Level
        
                var scene = CCScene()
                scene.addChild(gameScene)
        
                CCDirector.sharedDirector().replaceScene(scene)
                loadingNextLevel = true
            }
        }
    }
    

    func resumeLevel(notification: NSNotification) {
        
        colorToggle.visible = true
        pauseMenu.runAction(CCActionFadeOut(duration: 0.5))
        pauseButton.visible = true
        pauseMenu.removeFromParent()
        gameState = .Play
        
        if gamePhysicsNode.paused == true {
            gamePhysicsNode.paused = false
        }
        
    }
    
    
    func loadMainMenu(notification: NSNotification) {
        
        var mainMenu = CCBReader.load("MainScene")
        var scene = CCScene()
        
        scene.addChild(mainMenu)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: CCTransition(fadeWithDuration: 1.0))
    }
    
    
    //selector: toggles the sprites color
    func toggleHeroColor(notification: NSNotification) {
        hero.toggle()
    }
    
    
    func applyJump() {
        
        if gameState == .Play {
            heroState = .Jump
            
            let boundTop = level.position.y + level.boundingBox().height
            
            if hero.position.y + hero.boundingBox().height >= boundTop && heroState == .Jump {
                jumpScheduler!.invalidate()
                jumpTime = 0
            } else {
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
        
        
    }
    
    
    //MARK: Collision Handling
    
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
        
        if heroState != .Idle {

            hero.runAnim()
        }
        
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
                
                triggerGameOver()
                
            }
            
            return false
        }
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, endPortal: CCSprite!) -> ObjCBool {
    
        hero.physicsBody.velocity = CGPointZero
        
        if gameState != .GameWon {
            
            pauseButton.visible = false
            let triggerWin = CCActionCallFunc(target: self, selector: Selector("triggerLevelWon"))
            let moveToPlatform = CCActionMoveTo(duration: 1.0, position: CGPointMake(level.endPortal.position.x, level.endPortal.position.y + level.endPortal.boundingBox().height))
            
            hero.runAction(CCActionSequence(array: [moveToPlatform, triggerWin]))
                        
        } 
        gameState = .GameWon
        

        return false
        
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, whiteSpike spike1: CCSprite!, whiteSpike spike2: CCSprite!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, blackSpike spike1: CCSprite!, blackSpike spike2: CCSprite!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, whiteSpike: CCSprite!, whitePlatform: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, whiteSpike: CCSprite!, blackPlatform: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, blackSpike: CCSprite!, whitePlatform: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, blackSpike: CCSprite!, blackPlatform: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, blackSpike: CCSprite!, whiteSpike: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, blackSpike: CCSprite!, normalPlatform: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, whiteSpike: CCSprite!, normalPlatform: CCNode!) -> ObjCBool {
        return false
    }
    
    
    
}



