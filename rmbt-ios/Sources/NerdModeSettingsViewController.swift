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
class NerdModeSettingsViewController: AbstractSettingsViewController {

    ///
    @IBOutlet fileprivate var forceIPv4Switch: UISwitch?

    ///
    //@IBOutlet fileprivate var forceIPv6Switch: UISwitch?

    ///
    @IBOutlet fileprivate var qosMeasurementsSwitch: UISwitch?

    // TODO: dismiss number input fields!

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // forceIPv4Switch
        bindSwitch(forceIPv4Switch, toSettingsKeyPath: "nerdModeForceIPv4", onToggle: nil)
        //bindSwitch(forceIPv4Switch, toSettingsKeyPath: "nerdModeForceIPv4") { value in // when enabled, force ipv6 will be disabled
            /*if value && self.forceIPv6Switch?.isOn ?? false {
                self.settings.nerdModeForceIPv6 = false
                self.forceIPv6Switch?.setOn(false, animated: true)
            }*/
        //}

        // forceIPv6Switch
        /*bindSwitch(forceIPv6Switch, toSettingsKeyPath: "nerdModeForceIPv6") { value in // when enabled, force ipv4 will be disabled
            if value && self.forceIPv4Switch?.isOn ?? false {
                self.settings.nerdModeForceIPv4 = false
                self.forceIPv4Switch?.setOn(false, animated: true)
            }
        }*/

        // qos measurements
        bindSwitch(qosMeasurementsSwitch, toSettingsKeyPath: "nerdModeQosEnabled", onToggle: nil)
    }
}
