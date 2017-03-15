//
//  ViewController.swift
//  BackgroundSessionDemo
//
//  Created by Trương Thắng on 3/15/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    let downloadURLString = "https://cdn.spacetelescope.org/archives/images/large/heic1509a.jpg"
    var backgroundSession: URLSession?
    lazy var downloadTask: URLSessionDownloadTask? = {
        guard let downloadURL = URL(string: self.downloadURLString) else {
            return nil
        }
        let request = URLRequest(url: downloadURL)
        let config = URLSessionConfiguration.background(withIdentifier: "com.example.Big0.BackgroundSessionDemo.BackgroundSession")
        self.backgroundSession =  URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return self.backgroundSession?.downloadTask(with: request)
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadTask?.resume()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var isProgressViewHidden: Bool = false {
        willSet {
            guard isProgressViewHidden != newValue else {return}
            let willSetHidden = newValue
            progressView.superview?.isHidden = willSetHidden
            imageView.isHidden = !willSetHidden
            if willSetHidden == false {
                progressView.progress = 0
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: - URLSessionDelegate

extension ViewController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let completeHandler = AppDelegate.shared.backgroundSessionCompletionHandler {
            AppDelegate.shared.backgroundSessionCompletionHandler = nil
            completeHandler()
        }
        print("All Tasks are finished")
    }

}

