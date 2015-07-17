//
//  LocationPickerViewController.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 17/07/15.
//  Copyright © 2015 Iman Zarrabian. All rights reserved.
//

import UIKit

class LocationPickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
      
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CheckinCell", forIndexPath: indexPath) as! CheckinCell
        
        var checkin: CheckIn?
        if isGuest {
            checkin = guestsCheckinsArray.value[indexPath.row]
        }
        else {
            checkin = myCheckins?[indexPath.row]
        }
        
        if let user = checkin?.user, let event = checkin?.event {
            cell.placeTitleLabel.text = event.place_name
            cell.timeLabel.text = String.readableIntervalFromDateToNow(checkin!.created_at)
        }
        
        if indexPath.row == 2 {
            cell.checkinImageView.image = nil
            cell.topSubtitleConstraint.constant = 0
        }
        else {
            cell.checkinImageView.image = UIImage(assetIdentifier: .TimeLinePicturePlaceHolder)
            cell.topSubtitleConstraint.constant = 10.0
        }
        return cell
    }
}

