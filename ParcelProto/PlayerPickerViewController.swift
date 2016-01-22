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
        guard let vc = segue.destinationViewController as? SceneViewController else {
            return
        }
        guard segue.identifier == "GameSceneAccess" else {
            return
        }
        guard let indexPath = sender as? NSIndexPath else {
            return
        }
        vc.playerID = indexPath.row + 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("GameSceneAccess", sender: indexPath)
    }
}
