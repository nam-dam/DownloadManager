//
//  DownloadRequest.swift
//  Pods
//
//  Created by Nam Dam on 8/26/16.
//  Copyright © 2016 Nam dam. All rights reserved.
//

import Foundation

public class DownloadRequest<T> {

    var onSuccess: ((T) -> Void)!
    var onFailure: ((status: String, code: Int!) -> Void)?

    var cacheResult: T!

    init() {
        onSuccess = nil
        onFailure = nil
    }

    public func responseSuccess(closure: ((T) -> Void)? = nil) -> Self {
        if cacheResult != nil {
            closure!(cacheResult)
            return self
        }
        onSuccess = closure
        return self
    }

    public func responseFailure(closure: ((status: String, code: Int!) -> Void)? = nil) -> Self {
        onFailure = closure
        return self
    }

    func cancel() -> Void {
        //        request!.cancel()
    }

    //    var request: DownloadTask?
}