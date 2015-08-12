//
//  LevelCompleteScene.swift
//  Proto
//
//  Created by Rushil Patel on 7/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class LevelCompleteScene: CCNode {
    
    weak var nextLevelButton: CCNode!
    weak var retryButton: CCNode!
    weak var homeButton: CCNode!
    weak var bestTimeLabel: CCLabelTTF!
    weak var currentTimeLabel: CCLabelTTF!
    weak var currentTimeTextLabel: CCLabelTTF!
    weak var bestTimeTextLabel: CCLabelTTF!
    weak var newPrefixBestTimeLabel: CCLabelTTF!

    
    func shareButtonTapped() {
        var scene = CCDirector.sharedDirector().runningScene
        var node: AnyObject = scene.children[0]
        var screenshot = screenShotWithStartNode(node as! CCNode)
        
        let sharedText = "This is some default text that I want to share with my users. [This is where I put a link to download my awesome game]"
        let itemsToShare = [screenshot, sharedText]
        
        var excludedActivities = [ UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo]
        
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        if controller.respondsToSelector(Selector("popoverPresentationController")) {
            controller.popoverPresentationController?.sourceView = UIApplication.sharedApplication().keyWindow?.rootViewController?.view
        }
        
        controller.excludedActivityTypes = excludedActivities
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        var viewSize = CCDirector.sharedDirector().viewSize()
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height))
        rtx.begin()
        node.visit()
        rtx.end()
        return rtx.getUIImage()
    }

    
}