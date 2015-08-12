//
//  LevelSelectContent.swift
//  Proto
//
//  Created by Rushil Patel on 8/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class LevelSelectContent: CCNode {
    
    
    weak var levelSquare1: LevelSquare!
    weak var levelSquare2: LevelSquare!
    weak var levelSquare3: LevelSquare!
    weak var levelSquare4: LevelSquare!
    weak var levelSquare5: LevelSquare!
    weak var levelSquare6: LevelSquare!
    weak var levelSquare7: LevelSquare!
    weak var levelSquare8: LevelSquare!
    weak var levelSquare9: LevelSquare!
    weak var levelSquare10: LevelSquare!
    weak var levelSquare11: LevelSquare!
    weak var levelSquare12: LevelSquare!
    weak var levelSquare13: LevelSquare!
    weak var levelSquare14: LevelSquare!
    weak var levelSquare15: LevelSquare!
    weak var levelSquare16: LevelSquare!
    weak var levelSquare17: LevelSquare!
    weak var levelSquare18: LevelSquare!

    
    var totalStarsEarned = 0
    var totalStarsToEarn = 0

    var levelSquares: [LevelSquare] = []
    
    
    var userActivityState = UserState()
    
    
    func didLoadFromCCB(){
        
        
        levelSquares.append(levelSquare1)
        levelSquares.append(levelSquare2)
        levelSquares.append(levelSquare3)
        levelSquares.append(levelSquare4)
        levelSquares.append(levelSquare5)
        levelSquares.append(levelSquare6)
        levelSquares.append(levelSquare7)
        levelSquares.append(levelSquare8)
        levelSquares.append(levelSquare9)
        levelSquares.append(levelSquare10)
        levelSquares.append(levelSquare11)
        levelSquares.append(levelSquare12)
        levelSquares.append(levelSquare13)
        levelSquares.append(levelSquare14)
        levelSquares.append(levelSquare15)
        levelSquares.append(levelSquare16)
        levelSquares.append(levelSquare17)
        levelSquares.append(levelSquare18)
        
        
        
        for index in 0..<levelSquares.count {
            
            var starsEarned: Int?
            levelSquares[index].levelNumberLabel.string = levelSquares[index].name
            totalStarsToEarn += 3

            if index < 6 {

                starsEarned = userActivityState.starsEarned["Levels/Tut\(levelSquares[index].name)"] as? Int
            } else {

                starsEarned = userActivityState.starsEarned["Levels/Level\(levelSquares[index].name.toInt()! - 6)"] as? Int
            }
            if let starsEarned = starsEarned {
                if starsEarned == 1 {
                    
                    totalStarsEarned += 1
                    
                    levelSquares[index].starOne.visible = true
                    levelSquares[index].starTwo.visible = false
                    levelSquares[index].starThree.visible = false
                
                } else if starsEarned == 2 {
                    
                    totalStarsEarned += 2
                    
                    levelSquares[index].starOne.visible = true
                    levelSquares[index].starTwo.visible = true
                    levelSquares[index].starThree.visible = false
                } else if starsEarned == 3 {
                    
                    totalStarsEarned += 3
                    
                    levelSquares[index].starOne.visible = true
                    levelSquares[index].starTwo.visible = true
                    levelSquares[index].starThree.visible = true
                }
            } else {
                
                //level not finished
                
                levelSquares[index].starOne.visible = false
                levelSquares[index].starTwo.visible = false
                levelSquares[index].starThree.visible = false
            }
            
        }
        
    }

}