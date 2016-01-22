//
//  ViewController.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 19/06/15.
//  Copyright © 2015 Iman Zarrabian. All rights reserved.
//

import UIKit
import MapKit
import SpriteKit

class SceneViewController: UIViewController {

    @IBOutlet weak var gameView: UIView!
    
    // UI
    var mapView: MKMapView!
    var spriteView: SKView!
    var gameScene: GameScene!

    var userLocation: CLLocation?
    var targetID: Int?
    var playerID: Int?
    let locationManager = CLLocationManager()
    
    let debugMode = true
    
    @IBAction func goBack(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self

        handleLocationPermissions()
        
        self.addMapView()
        self.addGameView()
    }
    
    func addMapView() {
        self.mapView = MKMapView(frame: self.gameView.bounds)
        self.mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.gameView.addSubview(self.mapView)
    }
    
    func addGameView() {
        // Add game view
        self.spriteView = SKView(frame: self.gameView.bounds)
        self.spriteView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.spriteView.backgroundColor = UIColor.clearColor()
        self.spriteView.allowsTransparency = true;
        self.spriteView.userInteractionEnabled = false;
        self.gameView.addSubview(self.spriteView)
        
        // Add game scene
        print("gameView frame = \(self.gameView.frame)");
        self.gameScene = GameScene(size: self.gameView.bounds.size)
        self.gameScene.mapView = self.mapView
        self.gameScene.backgroundColor = UIColor.clearColor()
        self.spriteView.presentScene(self.gameScene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func getJSON(urlToRequest: String) -> NSData {
        let url = NSURL(string: urlToRequest)!
        return NSData(contentsOfURL: url)!
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary? {
        let pointsArray: NSDictionary?
        do {
            pointsArray = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        }
        catch _ {
            pointsArray = nil
        }
        return pointsArray
    }
}

extension SceneViewController: CLLocationManagerDelegate {
   
    func handleLocationPermissions() {
       // locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .Denied:
            //show error view
            break
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .AuthorizedWhenInUse:
            //All good
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        case .Restricted:
            //Npt user's fault -> Display error anyway but without the tap gesture
            break
        default:
            break
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        print("Current location: \(location)")

        if self.userLocation == nil {
            self.userLocation = location
            self.gameScene.loadPlayer(withId: self.playerID!, forLocation:location)
            self.gameScene.loadOpponentsTotems(forLocation:location)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        handleLocationPermissions()
    }
}

extension Double {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
    
    var radiansToDegrees : CGFloat {
        return CGFloat(self) * (180.0 / CGFloat(M_PI))
    }
}

extension SceneViewController {

//    func update() {
        
//        if fired {
//            let totalSteps = Double(shootPolyline!.pointCount) * percentOfFirePower

/*            if parcelAnnotationPosition + parcelStep >=  totalSteps {
                if percentOfFirePower == 1.0 {
                    let url = NSURL(string: "https://project-bomba.herokuapp.com/api/v1/users/\(playerID!)/points/\(targetID!)/hits")
                    let session = NSURLSession.sharedSession()
                    
                    let request = NSMutableURLRequest(URL: url!)
                    request.HTTPMethod = "POST"

                    let task = session.dataTaskWithRequest(request) {
                        data, response, error in
                        
                        if error != nil {
                            print("error=\(error)")
                            return
                        }
                        
                        print("response = \(response)")
                        
                        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("responseString = \(responseString)")
                    }
                    task.resume()
                }
                
                fired = false
                initValues()
                mapView.removeAnnotation(youAnnotation)
                mapView.removeAnnotation(targetAnnotation)
                initGame(false)
                return
            }*/
//            parcelAnnotationPosition += parcelStep;
//            let nextMapPoint = shootPolyline?.points()[Int(parcelAnnotationPosition)]
//            realParcelAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint!);
//            parcelAnnotationView.superview?.bringSubviewToFront(parcelAnnotationView)
//        }
//    }
    
    func getYouAnimatedImage() -> UIImageView {
        let imageview = UIImageView(frame: CGRectMake(0, 0, 150, 100))
        var arrayOfImages = [UIImage]()
        for s in 0..<4 {
            arrayOfImages.append(UIImage(named: "you\(s)")!)
        }
        
        imageview.animationImages = arrayOfImages
       // imageview.startAnimating()
        imageview.animationRepeatCount = 0
        imageview.animationDuration = 0.8
        return imageview
    }
    
    func getTargetAnimatedImage() -> UIImageView {
        let imageview = UIImageView(image: UIImage(assetIdentifier: .TargetAnimated))

        return imageview
    }
}


/*extension SceneViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinIdentifier = "Parcel"
        let youIdentitifer = "You"
        let targetIdentifier = "Target"
        var annotationView: MKAnnotationView?
        
        if youAnnotation == annotation as! MKPointAnnotation {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(youIdentitifer)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: youAnnotation, reuseIdentifier: youIdentitifer)
            }
            let animatedImageView = getYouAnimatedImage()
            animatedImageView.tag = 999
            view.backgroundColor = UIColor.redColor()

            annotationView?.centerOffset = CGPointMake(-animatedImageView.frame.size.width/2, -animatedImageView.frame.size.height);
            annotationView!.viewWithTag(999)?.removeFromSuperview()
            annotationView!.addSubview(animatedImageView)
            animatedImageView.startAnimating()
        }
        else if targetAnnotation == annotation as! MKPointAnnotation {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(targetIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: targetAnnotation, reuseIdentifier: targetIdentifier)
            }
            let animatedImageView = getTargetAnimatedImage()
            //animatedImageView.layer.borderWidth = 2.0
            annotationView?.centerOffset = CGPointMake(-animatedImageView.frame.size.width/2, -animatedImageView.frame.size.height);
            animatedImageView.tag = 999
            annotationView!.viewWithTag(999)?.removeFromSuperview()
            annotationView!.addSubview(animatedImageView)
            animatedImageView.startAnimating()

            //annotationView!.image = UIImage(assetIdentifier: .TargetImage)
        }
        else {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            }
            annotationView!.image = UIImage(assetIdentifier: .Bomb)
            annotationView?.centerOffset = CGPointMake(0, -80);

            parcelAnnotationView = annotationView
        }
        return annotationView!
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKPolyline else {
            return MKOverlayRenderer()
        }
        guard debugMode else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.redColor()
        renderer.alpha = 0.5
        return renderer
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for annotationView in views {
            if annotationView.annotation! as! MKPointAnnotation == parcelAnnotation!  {
                annotationView.superview?.bringSubviewToFront(annotationView)
            }
        }
    }
}*/


extension CLLocation {
    ///# distance
    ///Computes the distance in meters.
    /// - Parameter locationManager: the location mamager used to compute the entire data for the Google Places returned
    /// - Returns: A Signal Producer with Events of type [GooglePlace] (Array of Google Places) ( and evnetually an AppError.
    class func distance(from from: CLLocationCoordinate2D?, to:CLLocationCoordinate2D) -> CLLocationDistance {
        if let fromPoint = from {
            let from = CLLocation(latitude: fromPoint.latitude, longitude: fromPoint.longitude)
            let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
            return from.distanceFromLocation(to)
        }
        else {
            return 10_0000.0
        }
    }
}

