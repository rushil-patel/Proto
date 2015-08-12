import Foundation

class MainScene: CCNode {
    
    func launchTutorial() {
        
        let tutorialScene = CCScene()
        //CCBReader.loadAsScene("TutorialScene")
        let tutorial = CCBReader.load("TutorialScene")
        tutorialScene.addChild(tutorial)
        CCDirector.sharedDirector().presentScene(tutorialScene, withTransition: CCTransition(fadeWithDuration: 0.4))
    }
    
    func launchLevelSelect() {
        
        let levelSelectScene = CCScene()
        let levelSelect = CCBReader.load("LevelSelectScene") as! LevelSelectScene
        levelSelectScene.addChild(levelSelect)
        
        CCDirector.sharedDirector().presentScene(levelSelectScene, withTransition: CCTransition(fadeWithDuration: 0.4))
    }
    
    func launchCredits() {
        
        let creditScene = CCScene()
        let credit = CCBReader.load("Credits")
        creditScene.addChild(credit)
        
        CCDirector.sharedDirector().presentScene(creditScene, withTransition: CCTransition(fadeWithDuration: 0.3))
    }
}
