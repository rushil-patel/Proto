//
//  PauseScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class PauseScene: CCNode  {
    
    weak var retryButton: RetryHud!
    weak var homeButton: HomeHud!
    weak var resumeButton: ResumeHud!
    
    override func onEnter() {
        
        super.onEnter()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onPressHomeButton"), name: "home_touch_begin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onPressResumeButton"), name: "resume_touch_begin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onPressRetryButton"), name: "retry_touch_begin", object: nil)
    }
    
    override func onExit() {
        super.onExit()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onPressRetryButton() {
        

    }
    
    func onPressResumeButton() {
      
    }
    
    func onPressHomeButton() {
        
        
    }
}