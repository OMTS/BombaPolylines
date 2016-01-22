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
    var selectedOpponent: PlayerEntity?
    
    // Cannon balls
    var cannonBalls = NSMutableArray()
    
    // Map view reference
    var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            
            // Map view single tap management
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "userDidTapMapView:")
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            mapView.addGestureRecognizer(tapGesture);

            let tapGesture2 = UITapGestureRecognizer(target: self, action: nil)
            tapGesture2.numberOfTapsRequired = 2;
            tapGesture2.numberOfTouchesRequired = 1;
            mapView.addGestureRecognizer(tapGesture2);
            
            tapGesture.requireGestureRecognizerToFail(tapGesture2)
            tapGesture.delegate = self
        }
    }
    
    // Scene layers
    let groundLayer: SKNode = SKNode()
    let effectsLayer: SKNode = SKNode()
    let playersLayer: SKNode = SKNode()
    
    // Controls UI
    var carretImageView: UIImageView!
    var carretInitialPosition: CGPoint!
    var carretCourseDistance: CGFloat = 0
    var firebutton: UIButton!
    var carretAngularAbscissa: CGFloat = 0
    var gaugeActivated = false
    
    var prevUpdateTime: NSTimeInterval = 0
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)

        // Setup scene layers
        self.addChild(self.groundLayer)
        self.addChild(self.playersLayer)
        self.addChild(self.effectsLayer)
        
        // Fire control UI setup
        self.setupFireControleUIIn(self.view!.superview!)
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
        self.updateCannonBallsWith(dt)
        
        // Z ordering
        var children = self.playersLayer.children
        children.sortInPlace { (node1, node2) -> Bool in
            if node1.position.y > node2.position.y
                || (node1.position.y == node2.position.y && node1.position.x > node2.position.x ) {
                return true
            }
            return false
        }
        
        self.playersLayer.removeAllChildren()
        for child in children {
            self.playersLayer.addChild(child)
        }
        
        // Update shooting gauge
        self.updateShootingGaugeWith(dt)
    }
    
    func updateCannonBallsWith(deltaTime: NSTimeInterval) {
        let cannonBallsToRemove = NSMutableIndexSet()
        var index = 0
        for entity in self.cannonBalls {
            if let cannonBall = entity as? CannonBallEntity {
                cannonBall.updateWithDeltaTime(deltaTime)
                
                if cannonBall.endOfTrip {
                    cannonBall.removeCannonBallFromNode()
                    cannonBallsToRemove.addIndex(index)
                    //self.runAction(SKAction.playSoundFileNamed("Explosion_feu_MH", waitForCompletion: false))
                    if let completion = cannonBall.completion {
                        completion()
                    }
                }
            }
            ++index
        }
        
        if cannonBallsToRemove.count > 0 {
            self.cannonBalls.removeObjectsAtIndexes(cannonBallsToRemove)
        }
    }
    
    func setupFireControleUIIn(view: UIView) {
        // Add controls container
        let containerWidth: CGFloat = 80.0
        let containerFrame = CGRect(x: view.bounds.size.width - containerWidth, y: 0, width: containerWidth, height: view.bounds.size.height)
        let containerView = UIView(frame: containerFrame)
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(containerView)
        
        // Add gauge
        let gaugeImage = UIImage(named: "JaugeBG")
        let gaugeImageView = UIImageView(image: gaugeImage)
        gaugeImageView.center = CGPoint(x: containerFrame.size.width/2.0, y: containerFrame.size.height/2.0 - 35.0)
        containerView.addSubview(gaugeImageView)
        
        self.carretCourseDistance = 108 * 2
        self.carretInitialPosition = CGPoint(x: gaugeImageView.center.x, y: gaugeImageView.center.y + self.carretCourseDistance/2)
        
        // Add carret
        let carretImage = UIImage(named: "JaugeCarret")
        self.carretImageView = UIImageView(image: carretImage)
        self.carretImageView.hidden = true
        self.carretImageView.center = self.carretInitialPosition
        containerView.addSubview(self.carretImageView)
        
        // Add fire button
        self.firebutton = UIButton(type: UIButtonType.Custom)
        self.firebutton.enabled = false
        let fireButtonOffImage = UIImage(named: "FireOFF")
        self.firebutton.setImage(fireButtonOffImage, forState: UIControlState.Normal)
        self.firebutton.setImage(UIImage(named: "FireON"), forState: UIControlState.Highlighted)
        self.firebutton.addTarget(self, action: "fireButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.firebutton.bounds = CGRect(origin: CGPointZero, size: (fireButtonOffImage?.size)!)
        self.firebutton.center = CGPoint(x: gaugeImageView.center.x, y: gaugeImageView.frame.origin.y + gaugeImageView.frame.size.height + 50.0)
        containerView.addSubview(self.firebutton)
    }
}

// MARK: Players management
extension GameScene {

    func loadPlayer(withId playerId: Int, forLocation location: CLLocation) {
        self.player = PlayerEntity()
        self.player.coordinate = location.coordinate
        self.player.name = "Moi"
        self.player.playerId = playerId
        self.player.avatarNamed = "Player-avatar"
        
        // Add to game scene
        self.addPlayerToScene(self.player)
    }
    
    func loadOpponentsTotems(forLocation location: CLLocation) {
        func getJSON(urlToRequest: String) -> NSData {
            let url = NSURL(string: urlToRequest)!
            return NSData(contentsOfURL: url)!
        }
        
        func parseJSON(inputData: NSData) -> NSArray? {
            let totemsArray: NSArray?
            do {
                totemsArray = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as? NSArray
            }
            catch _ {
                totemsArray = nil
            }
            return totemsArray
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {[weak self] () -> Void in
            if (self == nil) {
                return
            }
            
            let url = "https://project-bomba.herokuapp.com/api/v1/points?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)&limit=20&exclude_user_id=\(self!.player.playerId)"
            //exclude_user_id -> Exclu les points crées par ce user
            let totems = parseJSON(getJSON(url))! as! [[String:AnyObject]]
            
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                if (self == nil) {
                    return
                }
                
                for totem in totems {
                    print("totem = \(totem)")
                    
                    // "id"
                    // "user_id"
                    // "created_at"
                    // "updated_at"
                    // "latitude"
                    // "longitude"
                    // "eyes_id"
                    // "mouth_id"
                    // "body_id"
                    // "properties"
                    
                    let opponent = PlayerEntity()
                    opponent.playerId = totem["user_id"] as! Int
                    opponent.name = "Adversaire \(opponent.playerId)"
                    opponent.avatarNamed = "Opponent-avatar"
                    let latitude = totem["latitude"] as! CLLocationDegrees
                    let longitude = totem["longitude"] as! CLLocationDegrees
                    opponent.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self!.opponents.append(opponent)
                    
                    // Add to game scene
                    self!.addPlayerToScene(opponent, isOpponent: true)
                }
                
                // Center map on player and opponents totems
                self!.centerMapOnPlayers()
            })
        }
    }
    
    func loadTestOpponents() {
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
            // Player datas could be displayed here
            // ...

        } else {
            // Opponents
            self.selectOpponent(player)
        }
    }
    
    func selectOpponent(opponent: PlayerEntity) {
        self.selectedOpponent = opponent

        // Update opponents display
        let duration = 0.15
        let fadeInAction = SKAction.fadeAlphaTo(1.0, duration: duration)
        let fadeOutAction = SKAction.fadeAlphaTo(0.2, duration: duration)
        
        for opponent in self.opponents {
            if opponent == self.selectedOpponent {
                opponent.avatar?.sprite.runAction(fadeInAction.copy() as! SKAction)
            } else {
                opponent.avatar?.sprite.runAction(fadeOutAction.copy() as! SKAction)
            }
        }
        
        // Focus map on player & selected opponent
        self.mapView.showAnnotations([self.player.annotation!, self.selectedOpponent!.annotation!], animated: true)
        
        // Activate shoot controls
        self.activateShootingGauge()
        self.firebutton.enabled = true;
    }
    
    func unselectOpponent() {
        self.selectedOpponent = nil
        
        // Update opponents display
        let duration = 0.15
        let fadeInAction = SKAction.fadeAlphaTo(1.0, duration: duration)
        
        for opponent in self.opponents {
            opponent.avatar?.sprite.runAction(fadeInAction.copy() as! SKAction)
        }
    }
}

// MARK: Shoot management
extension GameScene {
    
    func activateShootingGauge() {
        self.carretImageView.hidden = false

        // Set initial position
        self.carretAngularAbscissa = 0
        self.carretImageView.center = self.carretInitialPosition
        
        // Activate update
        self.gaugeActivated = true
    }
    
    func deactivateShootingGauge() {
        self.carretImageView.hidden = true
        
        // Deactivate update
        self.gaugeActivated = false
    }
    
    func updateShootingGaugeWith(deltaTime: NSTimeInterval) {
        if (self.gaugeActivated) {
            self.carretAngularAbscissa += CGFloat(deltaTime * M_PI)
            
            let abscissa = self.carretCourseDistance * (sin(self.carretAngularAbscissa) + 1)/2
            self.carretImageView.center.y = self.carretInitialPosition.y - abscissa
        }
    }
    
    func fireButtonTapped(sender: UIButton) {
        // Get carret abscissa
        let carretAbscissa = self.carretCourseDistance * (sin(self.carretAngularAbscissa) + 1)/2
        
        let topMissedLimit = CGFloat(108 + 40 + 2*14)
        let bottomMissedLimit = CGFloat(108)
        let topHeadShotLimit = CGFloat(108 + 40 + 14)
        let bottomHeadShotLimit = CGFloat(108 + 14)
        
        var damagePercent = 0.0
        var targetAbscissa: CGFloat = 1.0
        
        if carretAbscissa < bottomMissedLimit {
            // Cannon ball falls before reaching the opponent
            targetAbscissa = 0.5
            
        } else if carretAbscissa > topMissedLimit {
            // Cannon ball falls beyond the opponent
            targetAbscissa = 1.5

        } else if (carretAbscissa >= bottomHeadShotLimit
            && carretAbscissa <= topHeadShotLimit) {
            // Head shot man !
            damagePercent = 1
                
        } else if (carretAbscissa < bottomHeadShotLimit || carretAbscissa > topHeadShotLimit) {
            // Cannon ball reached the opponent but does not deal with a great damage amount
            damagePercent = 0.5
        }
        
        // Compute shooting target position
        let shootingPosition: CGPoint = self.mapView.convertCoordinate(self.player!.coordinate!, toPointToView: self.view)
        
        let opponentPosition: CGPoint = self.mapView.convertCoordinate(self.selectedOpponent!.coordinate!, toPointToView: self.view)
        
        var vector = CGPoint(x: opponentPosition.x - shootingPosition.x, y: opponentPosition.y - shootingPosition.y)
        vector.x *= targetAbscissa
        vector.y *= targetAbscissa
        
        let targetPosition = CGPoint(x: shootingPosition.x + vector.x, y: shootingPosition.y + vector.y)
        
        let targetCoordinate: CLLocationCoordinate2D = self.mapView.convertPoint(targetPosition, toCoordinateFromView: self.view)
        
        // Shoot a big cannon ball of the death !!!
        self.fireBigCannonBallFromLocation(self.player.coordinate!, toLocation: targetCoordinate) {
            print("--> BOUUUUUM !")
            // Apply damages to the targeted opponent at the end of the shoot
            // ...
        }
    }
    
    func fireBigCannonBallFromLocation(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D, completion: (()->Void)) {
        if (self.cannonBalls.count == 0) {
            let cannonBall = CannonBallEntity(withShootingCoordinate: fromLocation, targetCoordinate: toLocation, inMapView: self.mapView, renderView: self.view!)
            cannonBall.addCannonBallToGroundLayer(self.groundLayer, effectsLayer:self.effectsLayer)
            cannonBall.completion = completion
            self.cannonBalls.addObject(cannonBall)

            // self.runAction(SKAction.playSoundFileNamed("Tire_boulet_MH", waitForCompletion: false))
        }
    }
}

// MARK: Map view management
extension GameScene {
    
    func userDidTapMapView(tapGesture: UITapGestureRecognizer) {
        // This callback can be used to add totems on the map
        // ...
    }
    
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
        let region = MKCoordinateRegion(center:centerCoordinate , span:span)
        self.mapView.setRegion(region, animated: true)
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

extension GameScene: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view is MKAnnotationView {
            return false
        }
        return true
    }
}
