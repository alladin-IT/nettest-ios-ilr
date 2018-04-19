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
open class SpeedMeasurementDetailGroupResultResponse: BasicResponse {

    ///
    open var speedMeasurementResultDetailGroupList: [SpeedMeasurementDetailGroupItem]?

    ///
    override open func mapping(map: Map) {
        super.mapping(map: map)

        speedMeasurementResultDetailGroupList <- map["testresultDetailGroups"]
    }

    ///
    open class SpeedMeasurementDetailGroupItem: Mappable {

        ///
        open var title: String?

        ///
        open var icon: String?

        ///
        open var entries: [SpeedMeasurementDetailEntry]?

        ///
        public init() {

        }

        ///
        required public init?(map: Map) {

        }

        ///
        open func mapping(map: Map) {
            title <- map["title"]
            icon <- map["icon"]
            entries <- map["entries"]
        }

        ///
        open class SpeedMeasurementDetailEntry: Mappable {

            ///
            open var title: String?

            ///
            open var value: String?

            ///
            public init() {

            }

            ///
            required public init?(map: Map) {

            }

            ///
            open func mapping(map: Map) {
                title <- map["title"]
                value <- map["value"]
            }
        }
    }
}
