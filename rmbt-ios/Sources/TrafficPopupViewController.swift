/***************************************************************************
 * Copyright 2017-2018 alladin-IT GmbH
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
import RMBTClient

///
class TrafficPopupViewController: PopupTableViewController {

    ///
    var trafficCounter: RMBTTrafficCounter?

    ///
    private var lastTrafficDict = [String: NSNumber]()

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        headline = L10n.Intro.Popup.Traffic.background

        update()
    }

    ///
    override func update() {
        if trafficCounter == nil {
            return
        }

        let traffic = trafficCounter!.getTrafficCount() as [String: NSNumber]
        if lastTrafficDict.count == 0 {
            lastTrafficDict = traffic
        }

        // sent_diff = sent_wifi_diff + sent_wwan_diff
        let sent = (traffic["wifi_sent"]!.int64Value - lastTrafficDict["wifi_sent"]!.int64Value) + (traffic["wwan_sent"]!.int64Value - lastTrafficDict["wwan_sent"]!.int64Value)

        // recv_diff = sent_wifi_diff + sent_wwan_diff
        let recv = (traffic["wifi_received"]!.int64Value - lastTrafficDict["wifi_received"]!.int64Value) + (traffic["wwan_received"]!.int64Value - lastTrafficDict["wwan_received"]!.int64Value)

        lastTrafficDict = traffic

        let trafficDownload = String(format: "%.04f %@", Float(recv * 8) / (1024 * 1024), L10n.Test.Speed.unit)
        let trafficUpload = String(format: "%.04f %@", Float(sent * 8) / (1024 * 1024), L10n.Test.Speed.unit)

        data = [
            [L10n.Intro.Popup.Traffic.download, trafficDownload],
            [L10n.Intro.Popup.Traffic.upload, trafficUpload]
        ]

        super.update()
    }
}
