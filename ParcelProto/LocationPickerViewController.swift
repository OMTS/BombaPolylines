//
//  LocationPickerViewController.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 17/07/15.
//  Copyright © 2015 Iman Zarrabian. All rights reserved.
//

import UIKit
import MapKit

class LocationPickerViewController: UIViewController {
    
    var points = [[String:AnyObject]]()
    var playerID: Int?
    let arrayOfUserNames = ["Iman","Arnaud","Jérémie","Eddy","Marine","Florent","Jérôme","Karim","Florian","Jenny"]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alpha = 0.0

        loader.startAnimating()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        // Fallback on earlier versions
        handleLocationPermissions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "mapSegue" else {
            return
        }
        guard let vc = segue.destinationViewController as? SceneViewController else {
            return
        }
        guard let cell = sender as? LocationCell else {
            return
        }
        
        let indexPath = tableView.indexPathForCell(cell)
        let location = points[(indexPath?.row)!]
        let lat = location["latitude"] as! Float
        let lng = location["longitude"] as! Float
        
        vc.targetID = location["id"] as? Int
        vc.playerID = playerID
        vc.targetPosition = CLLocation(latitude: Double(lat), longitude: Double(lng))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension LocationPickerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return points.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        
        var point = points[indexPath.row]
        cell.nameLabel.text = "Point \(indexPath.row + 1)"
        
        let lat = point["latitude"] as! Float
        let lng = point["longitude"] as! Float

        cell.latitudeLabel.text = "\(lat)"
        cell.longitudeLabel.text = "\(lng)"
        let id = point["user_id"] as! Int
        cell.userName.text = "Created by " + arrayOfUserNames[id - 1]

        return cell
    }
}

extension LocationPickerViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension LocationPickerViewController: CLLocationManagerDelegate {
    
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
        print("Current location: \(location)")
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
        
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            
            let url = "https://project-bomba.herokuapp.com/api/v1/points?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)&exclude_user_id=\(self.playerID!)"
            //exclude_user_id -> Excu les points crées par ce user
            self.points = parseJSON(getJSON(url))! as! [[String:AnyObject]]
            self.loader.stopAnimating()
            self.tableView.alpha = 1.0
            self.tableView.reloadData()
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        handleLocationPermissions()
    }
    
}

