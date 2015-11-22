//
//  GameScene.swift
//  TestMapViewAndSKScene
//
//  Created by Florent Poisson on 06/11/2015.
//  Copyright © 2015 Florent Poisson. All rights reserved.
//

import UIKit
import MapKit
import SpriteKit

class GameScene: SKScene {

    // Players
    var player: PlayerEntity!
    var opponents = [PlayerEntity]()
    
    // Cannon balls
    var cannonBalls = NSMutableArray()
    
    // Map view reference
    var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    // Scene layers
    let effectsLayer: SKNode = SKNode()
    let playersLayer: SKNode = SKNode()
    
    var prevUpdateTime: NSTimeInterval = 0
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)

        // Setup scene layers
        self.addChild(self.playersLayer)
        self.addChild(self.effectsLayer)
        
        // Load players
        self.loadPlayer()
        self.loadOpponents()
        self.centerMapOnPlayers()
    }

    override func update(currentTime: NSTimeInterval) {
        // Get delta time
        let dt = currentTime - self.prevUpdateTime
        self.prevUpdateTime = currentTime;

        // Update players
        self.player?.updateWithDeltaTime(dt, mapView: self.mapView!, parentView: self.view!)
        for opponent in self.opponents {
            opponent.updateWithDeltaTime(dt, mapView: self.mapView!, parentView: self.view!)
        }
        
        // Update cannon balls
        let cannonBallsToRemove = NSMutableIndexSet()
        var index = 0
        for entity in self.cannonBalls {
            if let cannonBall = entity as? CannonBallEntity {
                cannonBall.updateWithDeltaTime(dt)

                if cannonBall.endOfTrip {
                    cannonBall.cannonBallSprite.removeFromParent()
                    cannonBall.cannonBallShadowSprite.removeFromParent()
                    cannonBallsToRemove.addIndex(index)
                    self.runAction(SKAction.playSoundFileNamed("Explosion_feu_MH", waitForCompletion: false))
                }
            }
            ++index
        }
        
        if cannonBallsToRemove.count > 0 {
            self.cannonBalls.removeObjectsAtIndexes(cannonBallsToRemove)
        }
    }
}

// MARK: Players management
extension GameScene {

    func loadPlayer() {
        // Load...
        self.player = PlayerEntity()
        self.player.coordinate = CLLocationCoordinate2D(latitude: 48.867460, longitude: 2.346767)
        self.player.name = "Moi"
        self.player.playerId = 0
        self.player.avatarNamed = "Player-avatar"
        
        // Add to game scene
        self.addPlayerToScene(self.player)
    }
    
    func loadOpponents() {
        // Load...
        let opponentCount = 8
        
        for index in 0..<opponentCount {
            let opponent = PlayerEntity()
            opponent.playerId = index + 1
            opponent.name = "Adversaire \(opponent.playerId)"
            opponent.avatarNamed = "Opponent-avatar"
            let angle = Double(index)*2.0*M_PI/Double(opponentCount)
            let latitude = self.player.coordinate!.latitude + cos(angle)*0.4
            let longitude = self.player.coordinate!.longitude + sin(angle)*0.5
            opponent.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.opponents.append(opponent)
            
            // Add to game scene
            self.addPlayerToScene(opponent, isOpponent: true)
        }
    }
    
    func addPlayerToScene(player: PlayerEntity, isOpponent: Bool = false) {
        // Add player annotation to map view
        if player.coordinate != nil {
            let playerAnnotation = PlayerAnnotation()
            playerAnnotation.player = player
            playerAnnotation.isOpponent = isOpponent
            self.mapView.addAnnotation(playerAnnotation)
            player.annotation = playerAnnotation

            // Add avatar sprite to game scene
            player.avatar = AvatarComponent(forPlayer: player)
            if let avatar = player.avatar {
                self.playersLayer.addChild(avatar.sprite!)
                player.addComponent(avatar)
            }
        }
    }
    
    func removePlayerFromScene(player: PlayerEntity) {
        // Remove avatar sprite from game scene
        if let avatar = player.avatar {
            avatar.sprite!.removeFromParent()
            player.removeComponentForClass(avatar.dynamicType)
            player.avatar = nil
        }
        
        // Remove player annotation from map view
        if let annotation = player.annotation {
            self.mapView.removeAnnotation(annotation)
            player.annotation = nil
        }
    }
    
    func userDidTapPlayer(player: PlayerEntity) {
        // Player
        if player === self.player {
            print("--> player tapped")
            // ...

        } else {
            // Opponents
            if let playerCoordinate = self.player.coordinate, let opponentCoordinate = player.coordinate {
                self.fireBigCannonBallFromLocation(playerCoordinate, toLocation: opponentCoordinate)
            }
        }
    }
}

// MARK: Shoot management
extension GameScene {
    
    func fireBigCannonBallFromLocation(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        let cannonBall = CannonBallEntity(withShootingCoordinate: fromLocation, targetCoordinate: toLocation, inMapView: self.mapView, renderView: self.view!)
        self.effectsLayer.addChild(cannonBall.cannonBallShadowSprite)
        self.effectsLayer.addChild(cannonBall.cannonBallSprite)
        self.cannonBalls.addObject(cannonBall)
        
        self.runAction(SKAction.playSoundFileNamed("Tire_boulet_MH", waitForCompletion: false))
    }
}

// MARK: Map view management
extension GameScene {
    
    func getAllPlayersAnnotations() -> [MKAnnotation] {
        // Get all annotations
        var annotations = [MKAnnotation]()
        
        if let annotation = self.player.annotation {
            annotations.append(annotation)
        }
        
        for opponent in self.opponents {
            if let annotation = opponent.annotation {
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
    
    func centerMapOnPlayers() {
        
        let annotations = self.getAllPlayersAnnotations()
        
        // Get region borders
        var minCoordinates = CLLocationCoordinate2D(latitude:90.0, longitude:180.0)
        var maxCoordinates = CLLocationCoordinate2D(latitude:-90.0, longitude:-180.0)
        
        for annotation in annotations {
            if minCoordinates.latitude > annotation.coordinate.latitude {
                minCoordinates.latitude = annotation.coordinate.latitude
            }
            if minCoordinates.longitude > annotation.coordinate.longitude {
                minCoordinates.longitude = annotation.coordinate.longitude
            }
            if maxCoordinates.latitude < annotation.coordinate.latitude {
                maxCoordinates.latitude = annotation.coordinate.latitude
            }
            if maxCoordinates.longitude < annotation.coordinate.longitude {
                maxCoordinates.longitude = annotation.coordinate.longitude
            }
        }
        
        // Set region
        let centerCoordinate = CLLocationCoordinate2D(latitude:(minCoordinates.latitude + maxCoordinates.latitude)/2.0, longitude: (minCoordinates.longitude + maxCoordinates.longitude)/2.0)
        let span = MKCoordinateSpan(latitudeDelta: (maxCoordinates.latitude - minCoordinates.latitude)*1.25, longitudeDelta: (maxCoordinates.longitude - minCoordinates.longitude)*1.25)
        self.mapView.region = MKCoordinateRegion(center:centerCoordinate , span:span)
    }
}

// MARK: <MKMapViewDelegate>
extension GameScene: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let playerAnnotation = annotation as? PlayerAnnotation {
            let annotationView = PlayerAnnotationView()
            annotationView.player = playerAnnotation.player
            if let avatarSize = annotationView.player?.avatar?.sprite.size {
                annotationView.bounds = CGRect(x: 0, y: 0, width: avatarSize.width, height: avatarSize.height)
                annotationView.centerOffset = CGPoint(x: 0, y: -avatarSize.height/2.0)
            }
            return annotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let playerAnnotationView = view as? PlayerAnnotationView, let player = playerAnnotationView.player {
            self.userDidTapPlayer(player)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
}
