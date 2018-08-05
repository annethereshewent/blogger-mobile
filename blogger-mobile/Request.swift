//
//  Request.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/27/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class Request {
    
    static func post(_ url: String, _ postParams: [String: Any], _ headers: [String: String] = [:], callback: @escaping ([String: Any]) -> Void) -> Void {
        Request.request(url, "POST", postParams, headers) { (json) in
            callback(json)
        }
    }
    
    static func get(_ url: String, _ headers: [String: String] = [:], callback: @escaping ([String: Any]) -> Void) -> Void {
        request(url, "GET", [:], headers) { (json) in
            callback(json)
        }
    }
    
    private static func request(_ url_str: String, _ methodType: String = "GET", _ postParams: [String: Any] = [:], _ headers: [String: String] = [:], callback: @escaping ([String: Any]) -> Void) -> Void {
        
        print("Making request at \(url_str)")
        
        let url = URL(string: url_str)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = methodType
    
        if (methodType == "POST") {
            var i = 0
            var postParamsStr = ""
            
            for (attr, value) in postParams {
                postParamsStr += "\(attr)=\(value)"
                
                if (i != postParams.count-1) {
                    postParamsStr += "&"
                }
                
                i += 1
            }
            
            request.httpBody = postParamsStr.data(using: .utf8)
        }
        
        for (attr, value) in headers {
            request.addValue(value, forHTTPHeaderField: attr)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
                callback(jsonData)
            }
            else {
                print("Could not parse json data")
                callback(
                    [
                        "success": false,
                        "message": "json_parse_fail"
                    ]
                )
            }
        }
        task.resume()
    }

}
