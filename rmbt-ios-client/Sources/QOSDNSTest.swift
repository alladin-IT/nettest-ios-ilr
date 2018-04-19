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
import RMBTClientDNS

///
class QOSDNSTest: QOSTest {

    fileprivate let PARAM_HOST = "host"
    fileprivate let PARAM_RESOLVER = "resolver"
    fileprivate let PARAM_RECORD = "record"

    ///
    fileprivate static let recordMap = [
        "A":     ns_t_a,
        "AAAA":  ns_t_aaaa,
        "MX":    ns_t_mx,
        "CNAME": ns_t_cname
    ]
    
    //

    ///
    var host: String?

    ///
    var resolver: String?

    ///
    var record: String?

    //

    ///
    override var description: String {
        return super.description + ", [host: \(String(describing: host)), resolver: \(String(describing: resolver)), record: \(String(describing: record))]"
    }

    //

    ///
    override init(testParameters: QOSTestParameters) {
        // host
        if let host = testParameters[PARAM_HOST] as? String {
            // TODO: length check on host?
            self.host = host
        }

        // resolver
        if let resolver = testParameters[PARAM_RESOLVER] as? String {
            // TODO: length check on resolver?
            self.resolver = resolver
        }

        // record
        if let record = testParameters[PARAM_RECORD] as? String {
            // TODO: length check on record?
            self.record = record
        }

        super.init(testParameters: testParameters)
    }
    
    ///
    func recordType() -> ns_type {
        return QOSDNSTest.recordMap[record ?? "invalid"] ?? ns_t_invalid
    }

    ///
    override func getType() -> QOSMeasurementType {
        return .DNS
    }

}
