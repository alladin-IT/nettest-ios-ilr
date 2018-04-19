/***************************************************************************
 * Copyright 2013 appscape gmbh
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
public enum TrafficClassification: Int {
    //case UNKNOWN = -1 // = nil
    case NONE = 0 // = 0..1249
    case LOW = 1 // = 1250..12499
    case MID = 2 // = 12500..124999
    case HIGH = 3 // = 125000..UInt64.max

    ///
    public static func classifyBytesPerSecond(_ bytesPerSecond: UInt64?) -> TrafficClassification {
        if let bps = bytesPerSecond {
            switch bps {
                case 0...1249:
                    return .NONE
                case 1250...12499:
                    return .LOW
                case 12500...124999:
                    return .MID
                case 125000...UInt64.max - 1: // -1 => bugfix for crash on swift 1.2 (range index has no valid successor or something...)
                    return .HIGH
                default:
                    break
            }
        }

        return .NONE //.UNKNOWN
    }
}
