import Foundation

class MainScene: CCNode {
    
    
    weak var playButton: CCButton!
    weak var creditsButton: CCButton!
    
    var userActivityState = UserState()
    
    
    // tutorial sequence removed 
    /*
    func launchTutorial() {
        
        let tutorialScene = CCScene()
        //CCBReader.loadAsScene("TutorialScene")
        let tutorial = CCBReader.load("TutorialScene")
        tutorialScene.addChild(tutorial)
        CCDirector.sharedDirector().presentScene(tutorialScene, withTransition: CCTransition(fadeWithDuration: 0.4))
    }
*/
    
    func launchLevelSelect() {
        
        if let playCheck = NSUserDefaults.standardUserDefaults().dictionaryForKey("starsEarnedDictionary") as? Dictionary<String, Int> {
            
            if playCheck.count <= 0 {
                
                launchPrologue()
                
            } else {
                
                let levelSelectScene = CCScene()
                let levelSelect = CCBReader.load("LevelSelectScene") as! LevelSelectScene
                levelSelectScene.addChild(levelSelect)
                
                CCDirector.sharedDirector().replaceScene(levelSelectScene, withTransition: CCTransition(fadeWithDuration: 0.4))
                
            }
            
        } else {
            
            launchPrologue()
            
        }

    }
    
    
    func launchPrologue() {
        
        playButton.enabled = false
        creditsButton.enabled = false
        
        let prologueScene = CCBReader.load("Prologue") as! Story
        
        self.addChild(prologueScene)
    }
    
    func launchCredits() {
        
        let creditScene = CCScene()
        let credit = CCBReader.load("Credits")
        creditScene.addChild(credit)
        
        CCDirector.sharedDirector().presentScene(creditScene, withTransition: CCTransition(fadeWithDuration: 0.3))
    }
}
