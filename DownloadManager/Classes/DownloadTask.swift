//
//  DownloadTask.swift
//  Pods
//
//  Created by Nam Dam on 08/28/2016.
//  Copyright © 2016 Nam dam. All rights reserved.
//

import UIKit

internal class DownloadTask: NSObject {

    func requestUrl(urlString: String, requestId: Int?) -> DownloadRequest<AnyObject>? {
        let serviceRequest = DownloadRequest<AnyObject>()
        FireRequest().request(urlString, requestId: requestId).onResult = { (data, response, error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    serviceRequest.onSuccess?(data!)
                } else {
                    serviceRequest.onFailure?(status: "Unknown error", code: -9999)
                }
            } else {
                serviceRequest.onFailure?(status: "Unknown error", code: -9999)
            }
        }
        return serviceRequest
    }

    func cancelRequest(requestId: Int) {
        FireRequest().cancel(requestId)
    }

    func cacheInMemory(coreObject: CoreObject) {
        if DownloadTaskManager.manager.cacheObjects {
            DownloadTaskManager.manager.cacheObject(coreObject)
        }
    }

    func parseImage(urlString: String, data: NSData) -> CoreObject? {
        if let image = UIImage(data: data) {
            let value: AnyObject = image
            let coreObject = CoreObject(urlString: urlString, value: value)
            cacheInMemory(coreObject)
            return coreObject
        }
        return nil
    }

    func parseJson(urlString: String, data: NSData) -> CoreObject? {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            if let result = json as? [String : AnyObject]  {
                let value: AnyObject = result
                let coreObject = CoreObject(urlString: urlString, value: value)
                cacheInMemory(coreObject)
                return coreObject
            }
            return nil
        } catch let parseError {
            print("parse error \(parseError)")
            return nil
        }

    }

    func parseXml(urlString: String, data: NSData, delegate: NSXMLParserDelegate?) -> CoreObject? {
        let parser = FireParser(data: data)
        let success = parser.parse(delegate)
        if success {
            let value: AnyObject = parser.result!
            let coreObject = CoreObject(urlString: urlString, value: value)
            cacheInMemory(coreObject)
            return coreObject
        } else {
            return nil
        }
    }
}