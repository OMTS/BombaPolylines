//
//  ViewController.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 19/06/15.
//  Copyright © 2015 Iman Zarrabian. All rights reserved.
//

import UIKit
import MapKit

struct Carret {
    enum Direction {
        case Up
        case Down
    }
    
    var direction = Direction.Down
    var initialPosition = -25.0
    var destinationPosition = -235.0
    var currentPosition = -235.0
    
    mutating func nextPosition() -> Double {
        let speed = 7.0
        switch direction {
        case .Down:
            if currentPosition - speed <= destinationPosition {
                direction = .Up
                currentPosition += speed
                return currentPosition
            }
            else {
                direction = .Down
                currentPosition -= speed
                return currentPosition
            }
        case .Up:
            if currentPosition + speed >= initialPosition {
                direction = .Down
                currentPosition -= speed
                return currentPosition
            }
            else {
                direction = .Up
                currentPosition += speed
                return currentPosition
            }
        }
    }
}


class SceneViewController: UIViewController {

    var shootPolyline: MKPolyline?
    var parcelAnnotation: MKPointAnnotation?
    var parcelAnnotationPosition: Int = 0
    var distance: CLLocationDistance = 0
    weak var parcelAnnotationView: MKAnnotationView!
    
    var targetPosition: CLLocation?
    var userLocation: CLLocation?
    var targetID: Int?
    var playerID: Int?
    let locationManager = CLLocationManager()
    
    var fired = false {
        willSet {
            self.fireButton.enabled = fired
        }
    }
    var youAnnotation: MKPointAnnotation!
    var targetAnnotation: MKPointAnnotation!
    let debugMode = false
    let topCarretMaxConstraint = -25.0
    let topCarretMinConstraint = -235.0
    var carretHasToMove = false
    
    var actualCarret = Carret(direction: .Down, initialPosition: -25.0, destinationPosition: -235.0, currentPosition: -235.0)
    var percentOfFirePower = 1.0
    
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var carret: UIImageView!
    @IBOutlet weak var carretTopConstraint: NSLayoutConstraint!
    
    
    func initValues() {
        carretHasToMove = false
        actualCarret = Carret(direction: .Down, initialPosition: -25.0, destinationPosition: -235.0, currentPosition: -235.0)
        percentOfFirePower = 1.0
    }
    
    @IBAction func goBack(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func initUpdateLoop() {
        let displayLink = CADisplayLink(target: self, selector: "update")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self

        handleLocationPermissions()
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
    


    @IBAction func fire(sender: UIButton) {
        fireUp()
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
            let location = locations.first
            print("Current location: \(location)")
            if userLocation == nil {
                userLocation = location
                initUpdateLoop()
                initGame()
            }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        handleLocationPermissions()
    }
    
}

extension SceneViewController {
    func initGame(withRegionFit: Bool = true) {
        
        mapView.delegate = self
        distance = CLLocation.distance(from: userLocation!.coordinate, to: targetPosition!.coordinate)
        
        youAnnotation = MKPointAnnotation()
        youAnnotation.coordinate = userLocation!.coordinate
        mapView.addAnnotation(youAnnotation)
        
        targetAnnotation = MKPointAnnotation()
        targetAnnotation.coordinate = targetPosition!.coordinate
        mapView.addAnnotation(targetAnnotation)
        
        parcelAnnotation = MKPointAnnotation()
        parcelAnnotation!.title = "Parcel"
        parcelAnnotation!.coordinate = userLocation!.coordinate
        mapView.addAnnotation(parcelAnnotation!)

        
        if withRegionFit {
           // let startCoord = CLLocationCoordinate2DMake(39.013762, -94.400840)
           // let adjustedRegion = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(startCoord, 4800000, 4800000))
           // mapView.setRegion(adjustedRegion, animated: true)
            mapView.showAnnotations([youAnnotation, targetAnnotation], animated: true)
        }
        
        self.fireButton.enabled = false
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.carretHasToMove = true
            self.fireButton.enabled = true
        }
    }
    
    func computePolyline() {
        let lowLengthRange = 103.0
        let highLengthRange = 41.0

        func getStrengthPercent () -> Double {
            //-66
            //-132
            if self.carretTopConstraint.constant <= -66.0 &&
                self.carretTopConstraint.constant >= -132 {
                    return 1
            }
            else {
                if self.carretTopConstraint.constant <= -132.0 {
                    let p = (235.0 - Double(-self.carretTopConstraint.constant)) / lowLengthRange
                    return p
                }
                else {
                    let p = 1 + (66 - Double(-self.carretTopConstraint.constant)) / highLengthRange
                    return p
                }
            }
        }
        
        percentOfFirePower = getStrengthPercent()
        print("fired with \(percentOfFirePower * 100)%")
        let origianlDistance = CLLocation.distance(from: youAnnotation.coordinate, to: targetAnnotation.coordinate)
        
        print("distance between you and target \(origianlDistance/1000)")
        
        var newLat = 0.0
        var newLng = 0.0
        
        if targetAnnotation.coordinate.latitude > youAnnotation.coordinate.latitude {
            newLat = youAnnotation.coordinate.latitude + abs(youAnnotation.coordinate.latitude - targetAnnotation.coordinate.latitude) * percentOfFirePower
        }
        else {
            newLat = youAnnotation.coordinate.latitude - abs(youAnnotation.coordinate.latitude - targetAnnotation.coordinate.latitude) * percentOfFirePower
        }
        
        if targetAnnotation.coordinate.longitude > youAnnotation.coordinate.longitude {
            newLng = youAnnotation.coordinate.longitude + abs(youAnnotation.coordinate.longitude - targetAnnotation.coordinate.longitude) * percentOfFirePower
        }
        else {
            newLng = youAnnotation.coordinate.longitude - abs(youAnnotation.coordinate.longitude - targetAnnotation.coordinate.longitude) * percentOfFirePower
        }
        
        
        let newDistance = CLLocation.distance(from: youAnnotation.coordinate, to: CLLocationCoordinate2D(latitude: newLat, longitude: newLng))
        print("new distance between you and target \(newDistance/1000)")

        
        print("new Lat : \(newLat) new Lng: \(newLng)")
        var coordinates = [youAnnotation.coordinate, CLLocationCoordinate2D(latitude: newLat, longitude: newLng)]
        
        //Setting properties
        shootPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: 2)
        mapView.addOverlay(shootPolyline!)
    }
    
    func fireUp() {
        computePolyline()
        fired = true
        carretHasToMove = false
        parcelAnnotationPosition = 0
        //let LAX = CLLocation(latitude: 33.9424955, longitude: -118.4080684)
        parcelAnnotation!.coordinate = userLocation!.coordinate
    }

    func update() {
        guard let realParcelAnnotation = parcelAnnotation else {
            return
        }
        
        var parcelStep: Int
        if distance < 600_000 {
            parcelStep = 1
        }
        else if distance >= 600_000 && distance < 900_000 {
            parcelStep = 3
        }
        else {
            parcelStep = 10
        }
        
        if carretHasToMove {
            let nextPosition = actualCarret.nextPosition()
            self.carretTopConstraint.constant = CGFloat(nextPosition)
        }
        
        if fired {
            let totalSteps = Double(shootPolyline!.pointCount) * percentOfFirePower

            if parcelAnnotationPosition + parcelStep >=  Int(totalSteps) {
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
            }
            parcelAnnotationPosition += parcelStep;
            let nextMapPoint = shootPolyline?.points()[parcelAnnotationPosition]
            realParcelAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint!);
            parcelAnnotationView.superview?.bringSubviewToFront(parcelAnnotationView)
        }
    }
    
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



extension SceneViewController: MKMapViewDelegate {

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
}


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
