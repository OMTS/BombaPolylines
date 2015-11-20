//
//  ViewController.swift
//  TestMapViewAndSKScene
//
//  Created by Florent Poisson on 06/11/2015.
//  Copyright © 2015 Florent Poisson. All rights reserved.
//

import UIKit
import MapKit
import SpriteKit

class ViewController: UIViewController {

    // UI
    var mapView: MKMapView!
    var gameView: SKView!
    var gameScene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addMapView()
        self.addGameView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMapView() {
        self.mapView = MKMapView(frame: self.view.bounds)
        self.mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.view.addSubview(self.mapView)
    }
    
    func addGameView() {
        // Add game view
        self.gameView = SKView(frame: self.view.bounds)
        self.gameView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.gameView.backgroundColor = UIColor.clearColor()
        self.gameView.allowsTransparency = true;
        self.gameView.userInteractionEnabled = false;
        self.view.addSubview(self.gameView)
        
        // Add game scene
        self.gameScene = GameScene(size: self.view.bounds.size)
        self.gameScene.mapView = self.mapView
        self.gameScene.backgroundColor = UIColor.clearColor()
        self.gameView.presentScene(self.gameScene)
    }
}


