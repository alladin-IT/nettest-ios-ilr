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

///
typealias WebsiteTestExecutor = QOSWebsiteTestExecutor<QOSWebsiteTest>

///
class QOSWebsiteTestExecutor<T: QOSWebsiteTest>: QOSTestExecutorClass<T> {

    private let RESULT_WEBSITE_URL      = "website_objective_url"
    private let RESULT_WEBSITE_TIMEOUT  = "website_objective_timeout"
    private let RESULT_WEBSITE_DURATION = "website_result_duration"
    private let RESULT_WEBSITE_STATUS   = "website_result_status"
    private let RESULT_WEBSITE_INFO     = "website_result_info"
    private let RESULT_WEBSITE_RX_BYTES = "website_result_rx_bytes"
    private let RESULT_WEBSITE_TX_BYTES = "website_result_tx_bytes"

    //

    ///
    fileprivate var requestStartTimeTicks: UInt64 = 0

    //

    ///
    override init(delegateQueue: DispatchQueue, testObject: T, speedtestStartTime: UInt64) {
        super.init(delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }

    ///
    override func startTest() {
        super.startTest()

        testResult.set(RESULT_WEBSITE_URL, string: testObject.url)
        testResult.set(RESULT_WEBSITE_TIMEOUT, number: testObject.timeout)
        testResult.set(RESULT_WEBSITE_TX_BYTES, value: nil) // not supported on iOS?
    }

    ///
    override func executeTest() {
        if let url = testObject.url, let urlObj = URL(string: url) {
            qosLog.debug("EXECUTING WEBSITE TEST")

            //
            
            WebsiteTestUrlProtocol.start()
            
            let websiteTestObj = WebsiteTestObject(uid: testObject.qosTestId)
            let (result, duration, status) = websiteTestObj.run(urlObj: urlObj, timeout: testObject.timeout - 500 * NSEC_PER_MSEC)
            
            WebsiteTestUrlProtocol.stop()
            
            //
            
            qosLog.debug("--- <RESULT> ---")
            qosLog.debug("result: \(result), duration: \(duration), status: \(status.rawValue)")
            qosLog.debug("--- </RESULT> ---")
            
            testResult.set(RESULT_WEBSITE_DURATION, number: duration)
            testResult.set(RESULT_WEBSITE_INFO, string: status.rawValue)
            
            if let r = result {
                testResult.set(RESULT_WEBSITE_STATUS, number: r.status)
                testResult.set(RESULT_WEBSITE_RX_BYTES, number: r.rx)
            }
            
            callFinishCallback()
        }
    }
}
