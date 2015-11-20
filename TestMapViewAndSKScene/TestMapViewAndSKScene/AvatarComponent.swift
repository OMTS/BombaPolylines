//
//  AvatarComponent.swift
//  TestMapViewAndSKScene
//
//  Created by Florent Poisson on 13/11/2015.
//  Copyright © 2015 Florent Poisson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class AvatarComponent: GKComponent {
    
    var sprite: SKSpriteNode!

    static func getAvatarSprite(forPlayer player: PlayerEntity) -> SKSpriteNode? {
        var sprite: SKSpriteNode!
        
        if let avatarNamed = player.avatarNamed {
            // Set avatar image
            sprite = SKSpriteNode(imageNamed: avatarNamed)
            sprite.setScale(0.2)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.05)
            
            // Animate a little bit
            let scaleDuration = 0.5
            let downScale = SKAction.scaleYTo(0.185, duration: scaleDuration/2.0)
            let upScale = SKAction.scaleYTo(0.2, duration: scaleDuration/2.0)
            let scaleSequence = SKAction.sequence([downScale, upScale])
            scaleSequence.timingMode = SKActionTimingMode.EaseInEaseOut
            let scaleRepeat = SKAction.repeatActionForever(scaleSequence)
            
            let rotationAngle = CGFloat(4.0*M_PI/180.0)
            sprite.zRotation = rotationAngle
            let rotationDuration = 1.0
            let rotateRight = SKAction.rotateToAngle(-rotationAngle, duration: rotationDuration/2.0)
            let rotateLeft = SKAction.rotateToAngle(rotationAngle, duration: rotationDuration/2.0)
            let rotateSequence = SKAction.sequence([rotateRight, rotateLeft])
            rotateSequence.timingMode = SKActionTimingMode.EaseInEaseOut
            let rotateRepeat = SKAction.repeatActionForever(rotateSequence)
            
            let delayAction = SKAction.waitForDuration(0, withRange: 1)
            
            sprite.runAction(SKAction.sequence([delayAction, SKAction.group([scaleRepeat, rotateRepeat])]))
        }
        
        return sprite
    }
    
    init?(forPlayer player: PlayerEntity) {
        super.init()
    
        self.sprite = AvatarComponent.getAvatarSprite(forPlayer: player)
        
        if (self.sprite == nil) {
            return nil
        }
    }
}
