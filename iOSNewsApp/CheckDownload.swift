//
//  CheckDownload.swift
//  iOSNewsApp
//
//  Created by Dan Taylor on 26/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import Foundation

class CheckDownload {
    
    var isModified = false
    var url: String!
    
    init(url: String!) {
        self.url = url
        //self.checkShouldDownloadFileAtLocation(url)
    }
    
    func check(callback: (Bool!) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: self.url)!)
        request.HTTPMethod = "HEAD"
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let session = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
        //let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            
            var isModified = false
            
            if let httpResp: NSHTTPURLResponse = response as? NSHTTPURLResponse {
                let lastModifiedDate = httpResp.allHeaderFields["Last-Modified"] as? String
                //print(lastModifiedDate)
                if lastModifiedDate != nil {
                    let dateFormatter2 = NSDateFormatter()
                    dateFormatter2.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
                    dateFormatter2.locale = NSLocale(localeIdentifier: "en-GB")
                    
                    let newLastModifiedDate = dateFormatter2.dateFromString(lastModifiedDate!)
                    //print(newLastModifiedDate)
                    //print(NSUserDefaults.standardUserDefaults().objectForKey("LastModifiedDate"))
                    if newLastModifiedDate != nil {
                        let currentLastModifiedDate = NSUserDefaults.standardUserDefaults().objectForKey("LastModifiedDate") as? NSDate
                        if currentLastModifiedDate == nil {
                            isModified = true
                        } else {
                            isModified = !newLastModifiedDate!.isEqual(currentLastModifiedDate!)
                        }
                        callback(isModified)
                        NSUserDefaults.standardUserDefaults().setObject(newLastModifiedDate!, forKey: "LastModifiedDate")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
            }
            
        }
        
        task.resume()
    }
    
}