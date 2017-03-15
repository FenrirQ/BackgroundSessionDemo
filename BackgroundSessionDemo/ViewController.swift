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
    
    @IBAction func onClickDownload() {
        downloadTask?.resume()

    }
    
}

// MARK: - <#Mark#>

extension ViewController: URLSessionDownloadDelegate {
    /*
     Khi download Task hoàn thành một download, hàm dưới đây sẽ được gọi.
     Và trong hàm này bạn cần phải copy hoặc move file ở vị trí Location tới một vị trí mới trước khi bị xoá khi hàm kết thúc.
     URLSession:task:didCompleteWithError: will still be called.
     */
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originURL = downloadTask.originalRequest?.url else {
            return
        }
        let destinationURL = AppDelegate.shared.documentsDirectoryURL.appendingPathComponent(originURL.lastPathComponent)
        try? FileManager.default.removeItem(at: destinationURL)
        try? FileManager.default.copyItem(at: location, to: destinationURL)

        DispatchQueue.main.async(execute: {
            self.imageView.image = UIImage(contentsOfFile: destinationURL.path)
            self.isProgressViewHidden = true
        })
    }
    
    
    // Gửi thông báo về quá trình download theo từng giai đoạn
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        /*
         Báo cáo quá trình thực hiện của 1 task
         nếu bạn đã tạo nhiều hơn 1 task, bạn phải giữ tham chiếu tới chúng và Báo cáo riêng từng cái
         */
        if downloadTask == self.downloadTask {
            let progress : Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async(execute: {
                self.progressView.progress = progress
            })
        }
        
    }
}


// MARK: - URLSessionTaskDelegate

extension ViewController: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            print("Task: \(task) completed successfully")
        } else {
            print("Task: \(task) completed with error: \(error!.localizedDescription)")
        }
        let progress = Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
        DispatchQueue.main.async(execute: {
            self.progressView.progress = progress
        })
        self.downloadTask = nil
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

