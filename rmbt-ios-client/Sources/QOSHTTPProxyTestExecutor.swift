/***************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
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

import Foundation
import Alamofire

///
typealias HTTPProxyTestExecutor = QOSHTTPProxyTestExecutor<QOSHTTPProxyTest>

///
class QOSHTTPProxyTestExecutor<T: QOSHTTPProxyTest>: QOSTestExecutorClass<T> {

    private let RESULT_HTTP_PROXY_STATUS    = "http_result_status"
    private let RESULT_HTTP_PROXY_DURATION  = "http_result_duration"
    private let RESULT_HTTP_PROXY_LENGTH    = "http_result_length"
    private let RESULT_HTTP_PROXY_HEADER    = "http_result_header"
    private let RESULT_HTTP_PROXY_RANGE     = "http_objective_range"
    private let RESULT_HTTP_PROXY_URL       = "http_objective_url"
    private let RESULT_HTTP_PROXY_HASH      = "http_result_hash"

    //

    ///
    private var requestStartTimeTicks: UInt64 = 0

    ///
    private var alamofireManager: Alamofire.SessionManager! // !

    //

    ///
    override init(delegateQueue: DispatchQueue, testObject: T, speedtestStartTime: UInt64) {
        super.init(delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }

    ///
    override func startTest() {
        super.startTest()

        testResult.set(RESULT_HTTP_PROXY_RANGE, string: testObject.range)
        testResult.set(RESULT_HTTP_PROXY_URL, string: testObject.url)
        testResult.set(RESULT_HTTP_PROXY_DURATION, number: -1)
    }

    ///
    override func executeTest() {
        // TODO: check testObject.url
        if let url = testObject.url {

            qosLog.debug("EXECUTING HTTP PROXY TEST")

            /////////
            let configuration = URLSessionConfiguration.ephemeral

            let timeout = nsToSec(testObject.downloadTimeout)
            qosLog.debug("TIMEOUT sec: \(timeout)")

            configuration.timeoutIntervalForRequest = timeout
            configuration.timeoutIntervalForResource = timeout

            configuration.allowsCellularAccess = true
            //configuration.HTTPShouldUsePipelining = true

            var additonalHeaderFields = [String: AnyObject]()

            // Set user agent
            if let userAgent = UserDefaults.standard.string(forKey: "UserAgent") {
                additonalHeaderFields["User-Agent"] = userAgent as AnyObject?
            }

            // add range header if it exists
            if let range = testObject.range {
                additonalHeaderFields["Range"] = range as AnyObject?
            }

            configuration.httpAdditionalHeaders = additonalHeaderFields

            alamofireManager = Alamofire.SessionManager(configuration: configuration)

            // prevent redirect
            let delegate = alamofireManager.delegate

            delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
                return URLRequest(url: URL(string: url)!) // see https://github.com/Alamofire/Alamofire/pull/424/files
            }

            ////

            // set start time
            requestStartTimeTicks = getCurrentTimeTicks()

            ////
            alamofireManager.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil) // TODO: is URLEncoding correct? was .url
                .validate()
                .responseData { (response: DataResponse<Data>) in
                    switch response.result {
                    case .success:

                        self.qosLog.debug("GET SUCCESS")

                        // compute duration
                        let durationInNanoseconds = getTimeDifferenceInNanoSeconds(self.requestStartTimeTicks)
                        self.testResult.set(self.RESULT_HTTP_PROXY_DURATION, number: durationInNanoseconds)

                        // set other result values
                        self.testResult.set(self.RESULT_HTTP_PROXY_STATUS, number: response.response?.statusCode)
                        self.testResult.set(self.RESULT_HTTP_PROXY_LENGTH, number: response.response?.expectedContentLength)

                        // compute md5
                        if let r = response.result.value {
                            self.qosLog.debug("ITS NSDATA!")

                            self.testResult.set(self.RESULT_HTTP_PROXY_HASH, string: r.MD5().hexString())
                        }

                        // loop through headers
                        var headerString: String = ""
                        if let allHeaderFields = response.response?.allHeaderFields {
                            for (headerName, headerValue) in allHeaderFields {
                                headerString += "\(headerName): \(headerValue)\n"
                            }
                        }

                        self.testResult.set(self.RESULT_HTTP_PROXY_HEADER, string: headerString)

                        ///
                        self.testDidSucceed()
                        ///

                    case .failure(let error):
                        self.qosLog.debug("GET FAILURE")
                        self.qosLog.debug("\(error.localizedDescription)")

                        // TODO TODO TODO TODO
                        // use AFError, determine correct error
                        /*if error.code == NSURLErrorTimedOut {
                            // timeout
                            self.testDidTimeout()
                        } else {
                            self.testDidFail()
                        }*/
                    }
                }
        }
    }

    ///
    override func testDidTimeout() {
        testResult.set(RESULT_HTTP_PROXY_HASH, status: .timeout)

        testResult.set(RESULT_HTTP_PROXY_STATUS, string: "")
        testResult.set(RESULT_HTTP_PROXY_LENGTH, number: 0)
        testResult.set(RESULT_HTTP_PROXY_HEADER, string: "")

        super.testDidTimeout()
    }

    ///
    override func testDidFail() {
        testResult.set(RESULT_HTTP_PROXY_HASH, status: .error)

        testResult.set(RESULT_HTTP_PROXY_STATUS, string: "")
        testResult.set(RESULT_HTTP_PROXY_LENGTH, number: 0)
        testResult.set(RESULT_HTTP_PROXY_HEADER, string: "")

        super.testDidFail()
    }
}
