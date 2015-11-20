//
//  CannonBallEntity.swift
//  TestMapViewAndSKScene
//
//  Created by Florent Poisson on 20/11/2015.
//  Copyright © 2015 Florent Poisson. All rights reserved.
//

import UIKit
import GameKit
import MapKit

class CannonBallEntity: GKEntity {

    static var speed: CGFloat = 30000.0 // pt/s

    var player: PlayerEntity
    var opponent: PlayerEntity
    private(set) var duration: NSTimeInterval = 0
    private(set) var elapsedTime: NSTimeInterval = 0
    private(set) var abscissa: CGFloat = 0
    private(set) var jumpHeight: CGFloat = 100.0
    
    var endOfTrip: Bool { return self.elapsedTime >= self.duration }
    
    let cannonBallSprite: SKSpriteNode = SKSpriteNode(imageNamed: "CannonBall")
    let cannonBallShadowSprite: SKSpriteNode = SKSpriteNode(imageNamed: "CannonBallShadow")
    
    init(withPlayer player: PlayerEntity, opponent: PlayerEntity) {
        self.player = player
        self.opponent = opponent
        
        // Get duration from distance and speed
        if let playerCoordinate = self.player.coordinate, let opponentCoordinate = self.opponent.coordinate {

            // Distance between players
            print("playerCoordinate = \(playerCoordinate)")
            print("opponentCoordinate = \(opponentCoordinate)")
            let playerLocation = CLLocation(latitude: playerCoordinate.latitude, longitude: playerCoordinate.longitude)
            let opponentLocation = CLLocation(latitude: opponentCoordinate.latitude, longitude: opponentCoordinate.longitude)
            let distance = playerLocation.distanceFromLocation(opponentLocation)
            
            self.duration = NSTimeInterval(CGFloat(distance)/CannonBallEntity.speed)
            
            print("distance = \(distance) / duration = \(self.duration)")
            
            
            self.cannonBallSprite.position = (self.player.avatar?.sprite.position)!
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        
        self.elapsedTime += seconds
        
        if (self.elapsedTime >= self.duration) {
            // End of the trip!
            self.elapsedTime = self.duration;
        }
        
        self.abscissa = CGFloat(self.elapsedTime/self.duration)
        
        if let playerSprite = self.player.avatar?.sprite, let opponentSprite = self.opponent.avatar?.sprite {
            let move = CGPoint(x: opponentSprite.position.x - playerSprite.position.x, y: opponentSprite.position.y - playerSprite.position.y)
            
            let scale = 1.0 + self.abscissa * (1 - self.abscissa)
            print("scale = \(scale)")
            var y = self.jumpHeight * 4.0 * self.abscissa * (1 - self.abscissa)
            y += move.y * self.abscissa
            y += playerSprite.position.y
            
            var x = move.x * self.abscissa
            x += playerSprite.position.x
            
            var yShadow = move.y * self.abscissa
            yShadow += playerSprite.position.y

            self.cannonBallSprite.position = CGPoint(x: x, y: y)
            self.cannonBallSprite.setScale(scale)
            self.cannonBallShadowSprite.position = CGPoint(x: x, y: yShadow)
            self.cannonBallShadowSprite.setScale(scale)
        }
    }
    
    /*
    // parabolic jump (since v0.8.2)
    CGFloat y = _height * 4 * frac * (1 - frac);
    y += _delta.y * t;
    
    CGFloat x = _delta.x * t;

    */
    
}
