/***************************************************************************
 * Copyright 2017 appscape gmbh
 * Copyright 2016-2018 alladin-IT GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

// inspired by https://github.com/appscape/open-rmbt-ios/blob/master/Sources/RMBTQoSWebTest.m

import Foundation
import UIKit

///
class WebsiteTestObject: NSObject {
    
    ///
    private var status: QOSTestResult.Status = .unknown
    
    ///
    private var webView: UIWebView?
    
    ///
    private var startedAt: UInt64 = 0
    
    ///
    private var duration: UInt64 = 0
    
    ///
    private var semaphore = DispatchSemaphore(value: 0)
    
    ///
    private var requestCount = 0
    
    ///
    private var uid: UInt?
    
    //
    
    ///
    init(uid: UInt) {
        super.init()
        
        self.uid = uid
    }
    
    ///
    func run(urlObj: URL, timeout: UInt64) -> (WebsiteTestResultEntry?, UInt64, QOSTestResult.Status) {
        DispatchQueue.main.sync {
            self.webView = UIWebView()
            self.webView?.delegate = self
            
            let request = NSMutableURLRequest(url: urlObj)
            self.tagRequest(request: request)
            
            self.webView?.loadRequest(request as URLRequest)
            
            logger.debug("AFTER LOAD REQUEST")
        }

        let semaphoneTimeout = DispatchTime.now() + DispatchTimeInterval.nanoseconds(Int(truncatingIfNeeded: timeout))
        
        status = semaphore.wait(timeout: semaphoneTimeout) == .timedOut ? .timeout : .ok
        
        duration = RMBTCurrentNanos() - startedAt
        
        let protocolResult = WebsiteTestUrlProtocol.queryResultWithTag(tag: "\(uid)")
        
        DispatchQueue.main.sync {
            webView?.stopLoading()
            webView = nil
        }
        
        return (protocolResult, duration, status)
    }
    
    ///
    func tagRequest(request: NSMutableURLRequest) {
        WebsiteTestUrlProtocol.tagRequest(request: request, withValue: "\(uid)")
    }
}

// MARK: UIWebViewDelegate methods

extension WebsiteTestObject: UIWebViewDelegate {
    
    ///
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        assert(status == .unknown)
        
        if let r = request as? NSMutableURLRequest {
            tagRequest(request: r)
        }
        
        if startedAt == 0 {
            startedAt = RMBTCurrentNanos()
        }
        
        return true
    }
    
    ///
    func webViewDidStartLoad(_ webView: UIWebView) {
        requestCount += 1
    }
    
    ///
    func webViewDidFinishLoad(_ webView: UIWebView) {
        maybeDone()
    }
    
    ///
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        status = .error
        maybeDone()
    }
    
    ///
    func maybeDone() {
        if status == .timeout {
            // Already timed out
            return
        }
        
        assert(requestCount > 0)
        
        requestCount -= 1
         
        if requestCount == 0 {
            semaphore.signal()
        }
    }
}
