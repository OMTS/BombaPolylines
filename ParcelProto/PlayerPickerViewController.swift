//
//  PlayerPickerViewController.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 11/09/15.
//  Copyright © 2015 Iman Zarrabian. All rights reserved.
//

import UIKit

class PlayerPickerViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? UITabBarController  where vc.viewControllers![0] is LocationPickerViewController else {
            return
        }
        guard segue.identifier == "locationSelector" else {
            return
        }
        guard let indexPath = sender as? NSIndexPath else {
            return
        }
        let selectedVC = vc.viewControllers![0] as! LocationPickerViewController
        let selectedVC2 = vc.viewControllers![1] as! CheckInViewController

        selectedVC.playerID = indexPath.row + 1
        selectedVC2.playerID = indexPath.row + 1

    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("locationSelector", sender: indexPath)
    }
}
