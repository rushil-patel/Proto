import Foundation

class MainScene: CCNode {
    
    func launchGamePlay() {
        let gameScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameScene, withTransition: CCTransition(fadeWithDuration: 1))
    }
    
    func launchTutorial() {
        
        let tutorialScene = CCBReader.loadAsScene("TutorialScene")
        CCDirector.sharedDirector().presentScene(tutorialScene, withTransition: CCTransition(fadeWithDuration: 1))
    }
}
