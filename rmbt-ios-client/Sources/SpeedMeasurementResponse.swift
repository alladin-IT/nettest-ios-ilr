/***************************************************************************
 * Copyright 2016 SPECURE GmbH
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
import ObjectMapper

///
open class SpeedMeasurementResponse: BasicResponse {

    ///
    open var testToken: String?

    ///
    open var testUuid: String?

    ///
    open var clientRemoteIp: String?

    ///
    var duration: Double = 7 // TODO: int instead of double?

    ///
    var pretestDuration: Double = RMBT_TEST_PRETEST_DURATION_S // TODO: int instead of double?

    ///
    var pretestMinChunkCountForMultithreading: Int = RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST

    ///
    var numThreads: Int = 3

    ///
    var numPings: Int = 10

    ///
    var testWait: Double = 0 // TODO: int instead of double?

    ///
    open var measurementServer: TargetMeasurementServer?

    ///
    override open func mapping(map: Map) {
        super.mapping(map: map)

        testToken           <- map["test_token"]
        testUuid            <- map["test_uuid"]

        clientRemoteIp      <- map["client_remote_ip"]
        duration            <- map["duration"]
        pretestDuration     <- map["duration_pretest"]
        numThreads          <- map["num_threads"]
        numPings            <- map["num_pings"]
        testWait            <- map["test_wait"]
        measurementServer   <- map["target_measurement_server"]

    }

    ///
    override open var description: String {
        return "SpeedMeasurmentResponse: testToken: \(String(describing: testToken)), testUuid: \(String(describing: testUuid)), clientRemoteIp: \n\(String(describing: clientRemoteIp))"
    }

    ///
    open class TargetMeasurementServer: Mappable {

        ///
        var address: String?

        ///
        var encrypted = false

        ///
        open var name: String?

        ///
        var port: UInt16?

        ///
        var uuid: String?

        ///
        var ip: String? // TODO: drop this?

        ///
        init() {

        }

        ///
        required public init?(map: Map) {

        }

        ///
        open func mapping(map: Map) {
            address     <- map["address"]
            encrypted   <- map["is_encrypted"]
            name        <- map["name"]
            port        <- (map["port"], UInt16NSNumberTransformOf)
            uuid        <- map["uuid"]
            ip          <- map["ip"]
        }
    }
}
