//
//  Router.swift
//  Guestbusters
//
//  Created by Iman Zarrabian on 10/06/15.
//  Copyright (c) 2015 Iman Zarrabian. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "http://project-bomba.herokuapp.com/"
    
    case GetPoints
  
    var method: Alamofire.Method {
        switch self {
        case .GetPoints:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetPoints:
            return "/api/v1/points"
        }
    }

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .GetPoints:
            return ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0

        default:
            return mutableURLRequest
        }
    }
}

