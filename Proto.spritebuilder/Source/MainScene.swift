import Foundation

class MainScene: CCNode {
    
    func launchGamePlay() {
        let gameScene =  CCScene()
        let gamePlay = CCBReader.load("Gameplay")
        gameScene.addChild(gamePlay)
        CCDirector.sharedDirector().presentScene(gameScene, withTransition: CCTransition(fadeWithDuration: 1))
    }
    
    func launchTutorial() {
        
        let tutorialScene = CCScene()
        //CCBReader.loadAsScene("TutorialScene")
        let tutorial = CCBReader.load("TutorialScene")
        tutorialScene.addChild(tutorial)
        CCDirector.sharedDirector().presentScene(tutorialScene, withTransition: CCTransition(fadeWithDuration: 1))
    }
    
    func launchLevelSelect() {
        
        let levelSelectScene = CCScene()
        let levelSelect = CCBReader.load("LevelSelectScene") as! LevelSelectScene
        levelSelectScene.addChild(levelSelect)
        
        CCDirector.sharedDirector().presentScene(levelSelectScene, withTransition: CCTransition(fadeWithDuration: 0.5))
    }
}
