//
//  PlayerAnnotation.swift
//  TestMapViewAndSKScene
//
//  Created by Florent Poisson on 06/11/2015.
//  Copyright © 2015 Florent Poisson. All rights reserved.
//

import UIKit
import MapKit

class PlayerAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        if let coordinate = self.player?.coordinate {
            return coordinate
        }
        return CLLocationCoordinate2D()
    }
    
    var isOpponent: Bool = false
    weak var mapView: MKMapView?
    weak var player: PlayerEntity?
}
