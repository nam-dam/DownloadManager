//
//  CoreObject.swift
//  Pods
//
//  Created by Nam Dam on 08/28/2016.
//  Copyright © 2016 Nam dam. All rights reserved.
//

import Foundation

public class CoreObject: AnyObject, Equatable {
    public var urlString: String = ""
    public var value: AnyObject
    init(urlString: String, value: AnyObject) {
        self.urlString = urlString
        self.value = value
    }
}

public func ==(lhs: CoreObject, rhs: CoreObject) -> Bool {
    return lhs.urlString == rhs.urlString
}