//
//  DownloadTaskManager.swift
//  Pods
//
//  Created by Nam Dam on 8/26/16.
//  Copyright © 2016 Nam dam. All rights reserved.
//

import UIKit

public class ObjectBundle: Equatable {
    var value: (Int, CoreObject)?
    var dataLength: Int

    init(usedTime: Int, coreObject: CoreObject) {
        value = (usedTime, coreObject)
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(coreObject.value)
        dataLength = data.length
    }

    class func upCount(inout object: ObjectBundle) {

    }
}

public func ==(lhs: ObjectBundle, rhs: ObjectBundle) -> Bool {
    return lhs.value?.1.urlString == rhs.value?.1.urlString
}

public class DownloadTaskManager: NSObject {
    public static let manager = DownloadTaskManager()

    public var cacheObjects = true
    public var maxConcurrentTasks = 5
    public var maxCacheSize = 51200 * 1024 // in KB

    private var cachedObjects = [ObjectBundle]()
    private var requests = [String]()
    private var cachedSize = 0

    internal func cacheObject(object: CoreObject) {
        if !cachedObjects.contains({ $0.value!.1 == object }) {

            let objectBundle = ObjectBundle(usedTime: 0, coreObject: object)

            if cachedSize + objectBundle.dataLength > maxCacheSize {
                if releaseObjectsForSize(objectBundle.dataLength) {
                    cachedObjects.append(objectBundle)
                }
            } else {
                cachedSize = cachedSize + objectBundle.dataLength
                cachedObjects.append(objectBundle)
            }
        }
    }

    internal func releaseObjectsForSize(allocDataSize: Int) -> Bool {
        var min = 999999
        var succeed = false
        for cachedObject in cachedObjects {
            if cachedObject.value!.0 < min {
                min = cachedObject.value!.0
            }
        }

        let filterObjects = cachedObjects.filter({ $0.value!.0 == min })

        for object in filterObjects {
            cachedSize = cachedSize - object.dataLength
            cachedObjects.removeObject(object)
            if maxCacheSize - cachedSize > allocDataSize {
                succeed = true
                break
            }
        }
        return succeed
    }

    // MARK: Private methods
    private func getRequestObject(urlString: String) -> CoreObject? {
        let objects = cachedObjects.filter { $0.value?.1.urlString == urlString }
        if objects.count > 0 {
            let coreObject = objects.first?.value?.1
            return coreObject
        }
        return nil
    }

    // MARK: Public methods

    // Download
    public func sendRequest(urlString: String, requestId: Int? = nil) -> DownloadRequest<AnyObject>? {
        guard urlString != "" else {
            return nil
        }

        let task = DownloadTask()
        if let cachedObject = getRequestObject(urlString) {
            let request = DownloadRequest<AnyObject>()
            request.cacheResult = cachedObject
            print("object was cached")
            return request
        } else {
            return task.requestUrl(urlString, requestId: requestId)
        }
    }

    // Cancel
    public func cancelRequest(requestId: Int) {
        let task = DownloadTask()
        task.cancelRequest(requestId)
    }

    // Parse
    public func parseImage(urlString: String, data: AnyObject) -> CoreObject? {
        let task = DownloadTask()
        if data.isKindOfClass(CoreObject.self) {
            return data as? CoreObject
        }
        return task.parseImage(urlString, data: data as! NSData)
    }

    public func parseJson(urlString: String, data: AnyObject) -> CoreObject? {
        let task = DownloadTask()
        if data.isKindOfClass(CoreObject.self) {
            return data as? CoreObject
        }
        return task.parseJson(urlString, data: data as! NSData)
    }

    public func parseXml(urlString: String, data: AnyObject, delegate: NSXMLParserDelegate?) -> CoreObject? {
        let task = DownloadTask()
        if data.isKindOfClass(CoreObject.self) {
            return data as? CoreObject
        }
        return task.parseXml(urlString, data: data as! NSData, delegate: delegate)
    }
}

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }

    mutating func removeObjectsInArray(objectArray: [Element]) {
        for object in objectArray {
            self.removeObject(object)
        }
    }
}