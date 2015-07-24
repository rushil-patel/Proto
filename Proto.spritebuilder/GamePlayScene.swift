//
//  GamePlayScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum GameState {
    case Play, Pause, GameOver, SlowMotion
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
    
    //Hero code connection
    weak var hero: Hero!
    weak var distanceLabel: CCLabelTTF!
    weak var jumpLife: CCSprite!
    
    //gameplay physics node connection
    weak var gamePhysicsNode: CCPhysicsNode!
    
    
    //Game variables
    var platforms: [Platform] = []
    var gameState: GameState = .Play
    var gamePauseActive: Bool = false
    var gameOverActive: Bool = false
    var powerUps: [PowerUp] = []
    var missiles: [Missile] = []

    
    //MARK: Game Dependent Variabes
    var gameSpeed: Float = 20.0
    var maxAirTimeSquared: Float = 2.0
    var minPlatformSpacing: Float = 100.0 * 1.0
    var maxPlatformSpacing: Float = 100.0 * 2.0
    var distanceTraveled: Float = 0
    var warningSprite: Alert?
    var missile: Missile?
    var curPowerUp: PowerUp!
    
    
    //Mark: Schedulers
    var jumpScheduler: NSTimer?
    var accelScheduler: NSTimer?
    var accelStartScheduler: NSTimer?
    var warningScheduler: NSTimer?
    var missileScheduler: NSTimer?
    var slowMotionScheduler: NSTimer?
    var powerScheduler: NSTimer?

    
    
    func didLoadFromCCB() {
        
        //enable user inteaction
        userInteractionEnabled = true
        
        //gamePhysicsNode.debugDraw = true
        
        //set physics collision delegate to self
        gamePhysicsNode.collisionDelegate = self
        
        
        //set gameStart accelerator scheduler
        accelStartScheduler = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("accelStart"), userInfo: nil, repeats: true)
        
        //set missile spawner
        missileScheduler = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: Selector("spawnMissile"), userInfo: nil, repeats: true)
        
        
        //power Scheduler
        powerScheduler = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("spawnPowerUp"), userInfo: nil, repeats: false)
        
        
        if CCDirector.sharedDirector().paused {
        
            CCDirector.sharedDirector().resume()
        }
        
        //initialize game variables
        gameSpeed = 10.0
        maxAirTimeSquared = 2.0
        minPlatformSpacing = 100.0 * 1.0
        maxPlatformSpacing = 100.0 * 2.0
        distanceTraveled = 0
        platforms = []
        gameState = .Play
        hero.position = CGPointMake(96, 130)
        gamePhysicsNode.position = CGPointZero
        
        gamePauseActive = false
        gameOverActive = false
        
        //initialize two platforms for the start
        spawnPlatform()
        spawnPlatform()
        
        powerUps.append(CCBReader.load("SlowMotionPower") as! PowerUp)
        powerUps.append(CCBReader.load("ShieldPower") as! PowerUp)
        
    }
    
    override func update(delta: CCTime) {
        if hero.state == .Run {
            println("running")
        }
        //println("\(convertToWorldSpace(gamePhysicsNode.convertToNodeSpace(hero.position)).y) .. ")
        //println(gamePhysicsNode.position.y)
        var motionCoeff: Float = 1.0
        if hero.powerState == .SlowMotion {
            motionCoeff = Constants.slowMotionCoeff
        }
        
        if gameState == .Play {
            
            let gamePhysX = gamePhysicsNode.position.x - CGFloat(gameSpeed) * CGFloat(delta) * CGFloat(motionCoeff)
            let gamePhysY = gamePhysicsNode.position.y
            gamePhysicsNode.position = ccp(gamePhysX, gamePhysY)
            
            //update hero's velocity with gameSpeed
            hero.position = CGPointMake(hero.position.x + CGFloat(delta) * CGFloat(gameSpeed) * CGFloat(motionCoeff), hero.position.y)
            
            if hero.state == .Idle {
                
                //accelerate Game speed from 0 -> 100 (for beginning game and slow downs
                hero.state = .Run
                
            }
            
            if  -gamePhysicsNode.position.x > platforms.first!.boundingBox().width + platforms.first!.position.x {
                
                let oldPlatform = platforms.removeAtIndex(0)
                oldPlatform.removeFromParent()
                spawnPlatform()
            }
            
            if missiles.count > 0 {
                
                if -gamePhysicsNode.position.x > missiles.first!.boundingBox().width + missiles.first!.position.x {
                    
                    let oldMissile = missiles.removeAtIndex(0)
                    oldMissile.removeFromParent()
                }
            }
            
            distanceTraveled += gameSpeed * Float(delta)
            updateDistanceLabel()
            
            //check for gameOver
            let heroHeight = hero.position.y + hero.boundingBox().height / 2
            
            if heroHeight < 0 {
                
                //hero has fallen below screen GAME OVER
                gameState = .GameOver
            }
            
            
        } else if gameState == .Pause {
            
            if !gamePauseActive {
                
                triggerGamePause()
            }
            
        } else {
            
            if !gameOverActive {
                
                triggerGameOver()
            }
        }
    }
    
    //MARK: Touch Handling
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if hero.state == .Run || hero.state == .Fall {
            jumpScheduler = NSTimer.scheduledTimerWithTimeInterval( 0.05, target: self, selector: Selector("applyJump"), userInfo: nil, repeats: true)
            hero.state = .Jump
            
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        //hero enters falling state
        hero.state = .Fall
        //hero.physicsBody.applyForce(CGPointMake(0, 1000))
        
        
    }
    
    func spawnMissile() {
        if warningSprite == nil {

            var sprite: CCSpriteFrame
            warningSprite = CCBReader.load("Alert") as? Alert
            
            
            if CCRANDOM_0_1() < 0.5 {
                
                sprite = CCSpriteFrame(imageNamed: "Assets/whiteWarning.png")
                warningSprite!.colorMode = "white"
                
            } else {
                
                sprite = CCSpriteFrame(imageNamed: "Assets/blackWarning.png")
                warningSprite!.colorMode = "black"
            }
            
            warningSprite!.spriteFrame = sprite
            warningSprite!.scale = 0.3
            warningSprite!.positionType.corner = CCPositionReferenceCorner.BottomRight
            warningSprite!.position = CGPointMake(0.0, hero.position.y)
            warningSprite!.anchorPoint = CGPointMake(1.0, 0.0)
            
            
            self.addChild(warningSprite)
            
            if missileScheduler?.timeInterval > 10 {
                
                missileScheduler?.timeInterval.advancedBy(-2)
            }
            else if missileScheduler?.timeInterval > 10 {
                
                missileScheduler?.timeInterval.advancedBy(2)
                
            } else {
                
                if CCRANDOM_0_1()  > 0.5 {
                    
                    missileScheduler?.timeInterval.advancedBy(-2)
                }
                else {
                    
                    missileScheduler?.timeInterval.advancedBy(2)
                }
            }
            
            
        }
        let params: [CCNode] = [warningSprite!, hero]
        warningScheduler = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("setWarningDestination"), userInfo: params, repeats: true)
    }
    
    func setWarningDestination() {
        
        let params = warningScheduler?.userInfo as! [CCNode]
        let tween = CCActionMoveTo(duration: 0.4, position: CGPointMake(params[0].position.x, params[1].position.y))
        let blink = CCActionBlink(duration: 0.4, blinks: UInt(warningSprite!.blinkRate++))
        
        if warningSprite!.blinkRate < 5 {
            
            warningSprite!.runAction(tween)
            warningSprite!.runAction(blink)
            
        } else {
            
            warningScheduler?.invalidate()
            
            if warningSprite!.colorMode == "white" {
                
                missile = CCBReader.load("WhiteMissile") as? Missile
            }
            else {
                missile = CCBReader.load("BlackMissile") as? Missile
            }
            
            
                let missileX = -gamePhysicsNode.position.x + CCDirector.sharedDirector().viewSize().width
            let missileY = warningSprite!.position.y
            missile!.position = ccp(missileX, missileY)
            missile!.physicsBody.velocity.x = -350
            gamePhysicsNode.addChild(missile)
            missiles.append(missile!)
            
            
            warningSprite!.stopAllActions()
            warningSprite!.removeFromParent()
            warningSprite = nil
            
            
        }
        
    }
    
    
    
    //spawns new platform randomly spaced
    func spawnPlatform() {
        
        var lastPlatformPosition: CGPoint = CGPointZero
        var lastPlatformLength: CGFloat = 0.0
        var platform: Platform
        if platforms.count > 0 {
            
            lastPlatformPosition = platforms.last!.position
            lastPlatformLength = platforms.last!.boundingBox().width
            
            let randNum = CCRANDOM_0_1()
            
            if randNum > 0.5 {
                
                platform = CCBReader.load("WhitePlatform") as! Platform
                
            } else {
                
                platform = CCBReader.load("BlackPlatform") as! Platform
                
            }
            
        } else {
            
            if hero.colorMode == "white" {
                
                platform = CCBReader.load("BlackPlatform") as! Platform
                
            } else {
                
                platform = CCBReader.load("WhitePlatform") as! Platform
                
            }
            
        }
        
        platform.randomizeLength()
        platform.position = ccp(lastPlatformPosition.x + lastPlatformLength, platform.position.y)
        platform.scaleY = 0.5
        if platforms.count > 0 {
            let spacing = CCRANDOM_0_1() * (maxPlatformSpacing - minPlatformSpacing) + minPlatformSpacing
            platform.position.x += CGFloat(spacing)
            platform.position.y += CGFloat(Int(CCRANDOM_0_1() * 10) * 10)
        }
        println(platform.position)
        
        platforms.append(platform)
        gamePhysicsNode.addChild(platform)
        
    }
    
    func spawnPowerUp() {
        
       // if CCRANDOM_0_1() < Constants.powerFrequency {
        if curPowerUp != nil {
            removeFromParent()
        }
        
        let randIndex: Int = Int(CCRANDOM_0_1() * Float(powerUps.count))
        
        curPowerUp = powerUps[randIndex]
        let lastPlatform = platforms.last!
 
        curPowerUp.position.x = lastPlatform.position.x + lastPlatform.boundingBox().width * CGFloat(CCRANDOM_0_1())
        curPowerUp.position.y = lastPlatform.position.y + lastPlatform.boundingBox().height + CGFloat(CCRANDOM_0_1()) * Constants.screenHeight
        clampf(Float(curPowerUp.position.y), Float(lastPlatform.boundingBox().height) + Float(lastPlatform.position.y), Float(Constants.screenHeight - lastPlatform.boundingBox().height))
       // }
        gamePhysicsNode.addChild(curPowerUp)
    }
    
    
    func updateDistanceLabel() {
        distanceLabel.string = "\(Int(distanceTraveled) / 50)m"
    }
    
    
    
    func triggerGamePause() {
        // CCDirector.sharedDirector().pause()
        gamePauseActive = true
        
        if let accelScheduler = accelStartScheduler {
            accelStartScheduler?.invalidate()
        }
        
        if let accelStartScheduler = accelScheduler {
            accelStartScheduler.invalidate()
        }
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        if let missileScheduler = missileScheduler {
            missileScheduler.invalidate()
        }
        
    }
    
    
    func triggerGameOver() {
        gameOverActive = true
        
        if let accelScheduler = accelStartScheduler {
            accelStartScheduler?.invalidate()
        }
        
        if let accelStartScheduler = accelScheduler {
            accelStartScheduler.invalidate()
        }
        
        if let jumpScheduler = jumpScheduler {
            jumpScheduler.invalidate()
        }
        
        if let missileScheduler = missileScheduler {
            missileScheduler.invalidate()
        }
        
        // CCDirector.sharedDirector().pause()
        
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOverScene
        self.addChild(gameOverScreen)
        
        
    }
    
    func restartGame() {
        
        var gameScene = CCBReader.load("Gameplay") as! GamePlayScene
        
        var scene = CCScene()
        scene.addChild(gameScene)
        //CCDirector.sharedDirector().resume()
        CCDirector.sharedDirector().replaceScene(scene)
    }
    
    
    
    //selector: toggles the sprites color
    func toggleHeroColor() {
        hero.toggle()
    }
    
    
    func applyJump() {
                
        if jumpLife.scaleY > 0 {
            jumpLife.scaleY -= 0.1
            hero.physicsBody.velocity.y = hero.lift
println("1")
        }
        else {
            jumpScheduler!.invalidate()
            //hero.state = .Fall
            println("2")
        }
        
        
    }
    
    
    
    //called from accelStartScheduler every .05 seconds
    func accelStart() {
        gameSpeed *= 1.1
        
        if gameSpeed >= 400  && hero.powerState != .SlowMotion {
            
            accelStartScheduler!.invalidate()
            
            //set gameSpeed accelerator scheduler
            accelScheduler = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("speedUpGame"), userInfo: nil, repeats: true)
        }
    }
    
    
    //called from accelScheduler every 2 seconds
    func speedUpGame() {
        
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
    
    func endSlowMotionMode() {
        hero.powerState = .None
    }
    
    
    
    //MARK: Collision Handling
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, blackPlatform: Platform!) -> ObjCBool {
        println("..")
        
        if hero.colorMode == "black" {
            
            return false
            
        } else {
            
            // return to run state after hitting ground
            //    if hero.state == .Fall {
            
            jumpLife.scaleY = 1.0
            hero.state = .Run
            
            let move = CCActionEaseBackOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0, 2)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let sequence = CCActionSequence(array: [move, moveBack])
            runAction(sequence)
            
            //  }
            return true
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, whitePlatform: Platform!) -> ObjCBool {
        println(".")
        if hero.colorMode == "white" {
            
            return false
            
        } else {
            
            // if hero.state == .Fall {
            jumpLife.scaleY = 1.0
            hero.state = .Run
            
            let move = CCActionEaseBackOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0, 2)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let sequence = CCActionSequence(array: [move, moveBack])
            runAction(sequence)
            //}
            return true
            
        }
        
    }
    
    func missileRemoved(missileToRemove missile: Missile) {

        let explosion = CCBReader.load("MissileExplosion") as! CCParticleSystem
        explosion.autoRemoveOnFinish = true
        explosion.position = missile.position
        missile.parent.addChild(explosion)
        missile.removeFromParent()
    }
    
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, whiteMissile: Missile!) -> ObjCBool {
        if hero.colorMode == "black" && hero.powerState != .Shield {
            missiles.removeAtIndex(find(missiles, whiteMissile)!)
            //run explosion animation
        
                gamePhysicsNode.space.addPostStepBlock({ () -> Void in
                self.missileRemoved(missileToRemove: whiteMissile)
                }, key: missile)
            
            return true
            
        } else {
            return false
        }
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, blackMissile: Missile!) -> ObjCBool {
        if hero.colorMode == "white" && hero.powerState != .Shield {
           
            return true
            
        } else {
            
            return false
        }
        
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, powerUp: PowerUp!) -> ObjCBool {
        
        println("power collided")
        if powerUp.powerType == "Shield" {
            
            
        } else if powerUp.powerType == "SlowMotion" {
            
            hero.powerState = .SlowMotion
        }
        
        slowMotionScheduler = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("endSlowMotionMode"), userInfo: nil, repeats: false)
        powerUp.removeFromParent()
        return false
    }
}


