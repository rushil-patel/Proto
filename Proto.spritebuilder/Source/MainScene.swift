import Foundation

class MainScene: CCNode {
    
    func launchGamePlay() {
        let gameScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameScene)
    }

}
