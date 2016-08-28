//
//  FireRequest.swift
//  Pods
//
//  Created by Nam Dam on 08/28/2016.
//  Copyright © 2016 Nam dam. All rights reserved.
//

import Foundation

internal class FireResult {
    var onResult: ((data: NSData?, response: NSURLResponse, error: NSError?) -> Void)?
}

internal class FireRequest: NSObject {

    internal func request(urlString: String, requestId: Int?) -> FireResult {
        let fireResult = FireResult()
        if let url = NSURL(string: urlString) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            QueueDelegate.queue.startNextOperation({
                let dataTask = session.dataTaskWithURL(url) { (data, response, error) in
                    guard response != nil else {
                        return
                    }
                    QueueDelegate.queue.finishTask(requestId)
                    dispatch_async(dispatch_get_main_queue(), {
                        fireResult.onResult!(data: data, response: response!, error: error)
                    })
                }
                QueueDelegate.queue.appendTask(dataTask, taskId: requestId)
                dataTask.resume()
            })
        }
        return fireResult
    }

    internal func cancel(requestId: Int) {
        let dataTask = QueueDelegate.queue.getTask(requestId)
        if dataTask != nil {
            dataTask!.cancel()
        }
    }
}

extension FireRequest: NSURLSessionDelegate {
    internal func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {

        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))

    }
}

public class FireParser: NSXMLParser {
    var result: String?

    public func parse(delegate: NSXMLParserDelegate?) -> Bool {
        self.delegate = delegate
        let success = parse()
        return success
    }
}