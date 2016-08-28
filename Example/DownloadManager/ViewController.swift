//
//  ViewController.swift
//  DownloadManager
//
//  Created by namqdam on 08/28/2016.
//  Copyright (c) 2016 namqdam. All rights reserved.
//

import UIKit
import DownloadManager

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let _urlString = "https://i.ytimg.com/vi/tntOCGkgt98/maxresdefault.jpg"
        DownloadTaskManager.manager.sendRequest(_urlString)!.responseSuccess({ [weak self] (data) in
            if let object = DownloadTaskManager.manager.parseImage(_urlString, data: data) {
                self?.imageView.image = object.value as? UIImage
            }

            })
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.fireNextRequest), userInfo: nil, repeats: true)

    }

    func fireNextRequest() {
        print("next request")
        for _ in 0..<100 {
        let _urlString = "https://i.ytimg.com/vi/tntOCGkgt98/maxresdefault.jpg"
        DownloadTaskManager.manager.sendRequest(_urlString)!.responseSuccess({ [weak self] (data) in
            if let object = DownloadTaskManager.manager.parseImage(_urlString, data: data) {
                self?.imageView.image = object.value as? UIImage
            }
            
            })
        }
    }
}

