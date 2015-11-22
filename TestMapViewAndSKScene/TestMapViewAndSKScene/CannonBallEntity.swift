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

    var shootingCoordinate: CLLocationCoordinate2D!
    var targetCoordinate: CLLocationCoordinate2D!
    private(set) var duration: NSTimeInterval = 0
    private(set) var elapsedTime: NSTimeInterval = 0
    private(set) var jumpHeight: CGFloat = 100.0
    
    var endOfTrip: Bool { return self.elapsedTime >= self.duration }
    
    let cannonBallSprite: SKSpriteNode = SKSpriteNode(imageNamed: "CannonBall")
    let cannonBallShadowSprite: SKSpriteNode = SKSpriteNode(imageNamed: "CannonBallShadow")
    
    // Utility references
    weak var mapView: MKMapView!
    weak var renderView: SKView!
    
    init(withShootingCoordinate shootingCoordinate: CLLocationCoordinate2D, targetCoordinate: CLLocationCoordinate2D, inMapView mapView: MKMapView, renderView: SKView) {
        self.shootingCoordinate = shootingCoordinate
        self.targetCoordinate = targetCoordinate
        self.mapView = mapView
        self.renderView = renderView

        // Distance between players
        let shootingLocation = CLLocation(latitude: shootingCoordinate.latitude, longitude: shootingCoordinate.longitude)
        let opponentLocation = CLLocation(latitude: targetCoordinate.latitude, longitude: targetCoordinate.longitude)
        let distance = shootingLocation.distanceFromLocation(opponentLocation)
        
        // Get duration from distance and speed
        self.duration = NSTimeInterval(CGFloat(distance)/CannonBallEntity.speed)

        // Update sprite position
        var position = mapView.convertCoordinate(shootingCoordinate, toPointToView: renderView)
        position.y = renderView.bounds.size.height - position.y;
        self.cannonBallSprite.position = position;
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        
        self.elapsedTime += seconds
        
        if (self.elapsedTime >= self.duration) {
            // End of the trip!
            self.elapsedTime = self.duration;
        }
        
        let abscissa = CGFloat(self.elapsedTime/self.duration)
        
        var shootingPosition = self.mapView.convertCoordinate(self.shootingCoordinate, toPointToView: self.renderView)
        shootingPosition.y = self.renderView.bounds.size.height - shootingPosition.y;

        var targetPosition = self.mapView.convertCoordinate(self.targetCoordinate, toPointToView: self.renderView)
        targetPosition.y = self.renderView.bounds.size.height - targetPosition.y;

        let move = CGPoint(x: targetPosition.x - shootingPosition.x, y: targetPosition.y - shootingPosition.y)
        
        let scale = 1.0 + abscissa * (1 - abscissa)
        var y = self.jumpHeight * 4.0 * abscissa * (1 - abscissa)
        y += move.y * abscissa
        y += shootingPosition.y
            
        var x = move.x * abscissa
        x += shootingPosition.x
            
        var yShadow = move.y * abscissa
        yShadow += shootingPosition.y

        self.cannonBallSprite.position = CGPoint(x: x, y: y)
        self.cannonBallSprite.setScale(scale)
        self.cannonBallShadowSprite.position = CGPoint(x: x, y: yShadow)
        self.cannonBallShadowSprite.setScale(scale)
    }
}
