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
import CoreLocation
import RMBTClient

///
class IpPopupViewController: PopupTableViewController {

    ///
    var connectivityInfo: ConnectivityInfo?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        headline = L10n.Intro.Popup.Ip.connections

        update()
    }

    ///
    override func update() {

        if let ipv4Info = connectivityInfo?.ipv4, let ipv6Info = connectivityInfo?.ipv6 {

            data = [
                [L10n.Intro.Popup.Ip.v4Internal, ipv4Info.internalIp ?? L10n.Intro.Popup.Ip.noIpText],
                [L10n.Intro.Popup.Ip.v4External, ipv4Info.externalIp ?? L10n.Intro.Popup.Ip.noIpText],
                [L10n.Intro.Popup.Ip.v6Internal, ipv6Info.internalIp ?? L10n.Intro.Popup.Ip.noIpText],
                [L10n.Intro.Popup.Ip.v6External, ipv6Info.externalIp ?? L10n.Intro.Popup.Ip.noIpText]
            ]
        }

        super.update()
    }

    ///
    override func stop() {

    }
}
