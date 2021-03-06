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
class QOSTest: CustomStringConvertible { /* TODO: declarations in extensions cannot be overriden yet */ // should be abstract

    let PARAM_TEST_UID = "qos_test_uid"
    let PARAM_CONCURRENCY_GROUP = "concurrency_group"
    let PARAM_SERVER_ADDRESS = "server_addr"
    let PARAM_SERVER_PORT = "server_port"
    let PARAM_TIMEOUT = "timeout"

    // values from server

    /// The id of this QOS test (provided by control server)
    var qosTestId: UInt = 0 // TODO: make this field optional?

    /// The concurrency group of this QOS test (provided by control server)
    var concurrencyGroup: UInt = 0 // TODO: make this field optional?

    /// The server address of this QOS test (provided by control server)
    var serverAddress: String?

    /// The server port of this QOS test (provided by control server)
    var serverPort: UInt16?

    /// The general timeout in nano seconds of this QOS test (provided by control server)
    var timeout: UInt64 = QOS_DEFAULT_TIMEOUT_NS

    //

    var testStartTimestampNS: UInt64?
    var testEndTimestampNS: UInt64?

    var hasStarted: Bool = false
    var hasFinished: Bool = false
    
    //

    ///
    var description: String {
        // \(getType().rawValue)
        return "QOSTest() [id: \(qosTestId), concurrencyGroup: \(concurrencyGroup), serverAddress: \(String(describing: serverAddress)), serverPort: \(String(describing: serverPort)), timeout: \(timeout)]"
    }

    //

    ///
    init(testParameters: QOSTestParameters) {

        // qosTestId
        if  let qosTestIdString = testParameters[PARAM_TEST_UID] as? String,
            let qosTestId = UInt(qosTestIdString) {
            self.qosTestId = qosTestId
        }

        // concurrencyGroup
        if  let concurrencyGroupString = testParameters[PARAM_CONCURRENCY_GROUP] as? String,
            let concurrencyGroup = UInt(concurrencyGroupString) {
                self.concurrencyGroup = concurrencyGroup
        }

        // serverAddress
        if let serverAddress = testParameters[PARAM_SERVER_ADDRESS] as? String, serverAddress.count > 0 {
            self.serverAddress = serverAddress
        }

        // serverPort
        if  let serverPortString = testParameters[PARAM_SERVER_PORT] as? String,
            let serverPort = UInt16(serverPortString) {
                self.serverPort = serverPort
        }

        // timeout
        if let timeoutString = testParameters[PARAM_TIMEOUT] as? NSString {
            let timeout = timeoutString.longLongValue
            if timeout > 0 {
                self.timeout = UInt64(timeout)
            }
        }
    }

    //

    /// returns the type of this test object
    func getType() -> QOSMeasurementType {
        preconditionFailure("This method must be overridden")
    }

    ///
    func needsControlConnection() -> Bool {
        return serverAddress != nil && serverPort != nil
    }
}

// MARK: Printable methods

///
/*extension QOSTest: CustomStringConvertible {

    ///
    var description: String {
        return "QOSTest(\(getType().rawValue)) [id: \(qosTestId), concurrencyGroup: \(concurrencyGroup), serverAddress: \(serverAddress), serverPort: \(serverPort), timeout: \(timeout)]"
    }
}
*/
