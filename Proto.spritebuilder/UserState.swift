//
//  UserState.swift
//  Proto
//
//  Created by Rushil Patel on 8/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class UserState {
    
    var bestTimes : [NSObject : AnyObject] = NSUserDefaults.standardUserDefaults().dictionaryForKey("bestTimesDictionary") ?? [NSObject : AnyObject]()
    var starsEarned: [NSObject : AnyObject] = NSUserDefaults.standardUserDefaults().dictionaryForKey("starsEarnedDictionary") ?? [NSObject : AnyObject]()

    
    func updateBestTimes(levelKey: String, timeValue: String) {
        
        //add/update key value pair to the persistent dictionary
        bestTimes.updateValue(timeValue, forKey: levelKey)
        NSUserDefaults.standardUserDefaults().setObject(bestTimes, forKey: "bestTimesDictionary")
        NSUserDefaults.standardUserDefaults().synchronize()

        
    }
    
    func updateStarsEarned(numStars: Int, levelKey : String) {
        
        //add/update key value pair to the persistent dictionary
        starsEarned.updateValue(numStars, forKey: levelKey)
        NSUserDefaults.standardUserDefaults().setObject(starsEarned, forKey: "starsEarnedDictionary")
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    init() {
        
        NSUserDefaults.standardUserDefaults().setObject(bestTimes, forKey: "bestTimesDictionary")
        NSUserDefaults.standardUserDefaults().setObject(starsEarned, forKey: "starsEarnedDictionary")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
        
    }
    
}