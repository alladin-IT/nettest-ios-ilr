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

//let GAUGE_PARTS = 4.25
//let LOG10_MAX = log10(250.0)

/////
//public func RMBTSpeedLogValue(_ kbps: UInt64) -> Double {
//    let bps = kbps * 1_000
//    var log: Double
//
//    if bps < 10_000 {
//        log = 0
//    } else {
//        log = ((GAUGE_PARTS - LOG10_MAX) + log10(Double(bps) / Double(1e6))) / GAUGE_PARTS
//    }
//
//    //if (log > 1.0) {
//    //    log = 1.0
//    //}
//
//    return log
//}

/// for nkom
public func RMBTSpeedLogValue(_ kbps: UInt64, gaugeParts: Double, log10Max: Double) -> Double {
    let bps = kbps * 1_000

    if bps < 10_000 {
        return 0
    }

    return ((gaugeParts - log10Max) + log10(Double(bps) / 1e6)) / gaugeParts
}

///
public func RMBTSpeedMbpsString(_ kbps: UInt64, withMbps: Bool = true) -> String {
    let speedValue = RMBTFormatNumber(NSNumber(value: Double(kbps) / 1000.0 as Double))

    if withMbps {
        let localizedMps = NSLocalizedString("test.speed.unit", value: "Mbps", comment: "Speed suffix")

        return String(format: "%@ %@", speedValue, localizedMps)
    } else {
        return "\(speedValue)"
    }
}
