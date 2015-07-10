//
//  UIImageAssetExtension.swift
//  ParcelProto
//
//  Created by Iman Zarrabian on 16/06/15.
//  Copyright (c) 2015 Iman Zarrabian. All rights reserved.
//

import UIKit

extension UIImage {
    enum AssetIdentifier: String {
        case AppIcon = "AppIcon"
        case LaunchImage = "LaunchImage"
        case ParcelImage = "ParcelImage"
        case TargetImage = "TargetImage"
        case YouImage = "YouImage"
        case FireON = "FireON"
        case FireOFF = "FireOFF"
        case JaugeBG = "JaugeBG"
        case JaugeCarret = "JaugeCarret"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}