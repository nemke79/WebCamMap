//
//  NetworkSpeedTest.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 05/05/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit

// Class for testing speed of the network.
class NetworkSpeedTest: UIViewController {
    
    weak var delegate: NetworkSpeedProviderDelegate?
    var startTime = CFAbsoluteTime()
    var stopTime = CFAbsoluteTime()
    var bytesReceived: CGFloat = 0
    var testURL:String?
    var speedTestCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil
    var timerForSpeedTest:Timer?
    
    func networkSpeedTestStart(UrlForTestSpeed:String!){
        testURL = UrlForTestSpeed
        testForSpeed()
        timerForSpeedTest = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(testForSpeed), userInfo: nil, repeats: true)
    }
    func networkSpeedTestStop(){
        timerForSpeedTest?.invalidate()
    }
    @objc func testForSpeed()
    {
        testDownloadSpeed(withTimout: 2.0, completionHandler: {(_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void in
            print("%0.1f; KbPerSec = \(megabytesPerSecond)")
            if (error as NSError?)?.code == -1009
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .disConnected)
            }
            else if megabytesPerSecond == -1.0
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .poor)
            }
            else
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .good)
            }
        })
    }
}
extension NetworkSpeedTest: URLSessionDataDelegate, URLSessionDelegate {
    
    func testDownloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void) {
        
        // you set any relevant string with any file
        let urlForSpeedTest = URL(string: testURL!)
        
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        speedTestCompletionHandler = completionHandler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        guard let checkedUrl = urlForSpeedTest else { return }
        
        session.dataTask(with: checkedUrl).resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived += CGFloat(data.count)
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let elapsed = (stopTime - startTime) //as? CFAbsoluteTime
        let speed: CGFloat = elapsed != 0 ? bytesReceived / (CGFloat(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0 : -1.0
        // treat timeout as no error (as we're testing speed, not worried about whether we got entire resource or not
        if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
            speedTestCompletionHandler?(speed, nil)
        }
        else {
            speedTestCompletionHandler?(speed, error)
        }
    }
}
