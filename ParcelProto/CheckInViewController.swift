//
//  CheckInViewController.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 18/09/15.
//  Copyright © 2015 Iman Zarrabian. All rights reserved.
//

import UIKit
import MapKit

class CheckInViewController: UIViewController {

    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var playerID: Int?

    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lngLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        // Fallback on earlier versions
        handleLocationPermissions()
    }
    
    
    
    
    @IBAction func createPoint(sender: UIButton) {
        guard let userLoc = userLocation else {
            return
        }
        
        
        let dict = ["point" : ["latitude" : userLoc.coordinate.latitude, "longitude" : userLoc.coordinate.longitude]]
        
        let url = NSURL(string: "https://project-bomba.herokuapp.com/api/v1/users/\(playerID!)/points")
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPMethod = "POST"

        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch _ {
            return
        }
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
    
    func getJSON(urlToRequest: String) -> NSData {
        let url = NSURL(string: urlToRequest)!
        return NSData(contentsOfURL: url)!
    }
    
    func parseJSON(inputData: NSData) -> NSArray? {
        let pointsArray: NSArray?
        do {
            pointsArray = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as? NSArray
        }
        catch _ {
            pointsArray = nil
        }
        return pointsArray
    }

}


extension CheckInViewController: CLLocationManagerDelegate {
    
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
        let myLocation = locations.first
        guard let location = myLocation else {
            return
        }
        userLocation = location
        latLabel.text = "lat: \(userLocation!.coordinate.latitude)"
        lngLabel.text = "lng: \(userLocation!.coordinate.longitude)"
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        handleLocationPermissions()
    }
    
    
    

}
