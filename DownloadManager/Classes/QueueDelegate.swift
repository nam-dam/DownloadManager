//
//  QueueDelegate.swift
//  Pods
//
//  Created by Nam Dam on 08/28/2016.
//  Copyright © 2016 Nam dam. All rights reserved.
//

import Foundation

internal class QueueDelegate: NSOperationQueue {
    static var queue = QueueDelegate()
    var taskQueue = [Int: NSURLSessionDataTask]()

    override init() {
        super.init()
        maxConcurrentOperationCount = DownloadTaskManager.manager.maxConcurrentTasks
    }

    func appendTask(dataTask: NSURLSessionDataTask, taskId: Int?) {
        if taskId != nil {
            taskQueue.updateValue(dataTask, forKey: taskId!)
        }
    }

    func getTask(taskId: Int) -> NSURLSessionDataTask? {
        if taskQueue.count > 0 {
            return taskQueue[taskId]
        }
        return nil
    }

    func finishTask(taskId: Int?) {
        guard taskId != nil else {
            return
        }
        if taskQueue.count > 0 {
            taskQueue.removeValueForKey(taskId!)
        }
    }

    func startNextOperation(closure: () -> Void) {
        let operation = NSOperation()
        operation.completionBlock = closure
        addOperation(operation)
    }
}