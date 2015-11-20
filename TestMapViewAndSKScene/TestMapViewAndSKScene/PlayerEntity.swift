//
//  PlayerEntity.swift
//  TestMapViewAndSKScene
//
//  Created by Florent Poisson on 06/11/2015.
//  Copyright © 2015 Florent Poisson. All rights reserved.
//

import UIKit
import MapKit
import SpriteKit
import GameplayKit

class PlayerEntity : GKEntity {

    var playerId: Int = -1
    var name: String?
    var avatarNamed: String?
    var coordinate: CLLocationCoordinate2D?
    
    // Utility references
    var mapView: MKMapView?
    
    // Components
    var annotation: PlayerAnnotation?
    var avatar: AvatarComponent?
    
    func updateWithDeltaTime(seconds: NSTimeInterval, mapView: MKMapView, parentView: UIView) {
        // Update components if needed
        self.updateWithDeltaTime(seconds)
        
        // Update avatar position
        if let avatarSprite = self.avatar?.sprite, let annotation = self.annotation {
            var position = mapView.convertCoordinate(annotation.coordinate, toPointToView: parentView)
            position.y = parentView.bounds.size.height - position.y;
            if avatarSprite.position != position {
                avatarSprite.position = position;
            }
        }
    }
}
