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
class DeveloperModeSettingsViewController: AbstractSettingsViewController {

    // Developer settings

    ///
    @IBOutlet fileprivate var noGpsSwitch: UISwitch?

    ///
    @IBOutlet fileprivate var measurementTagTextField: UITextField?

    // Loop mode

    ///
    @IBOutlet fileprivate var developerModeLoopModeSwitch: UISwitch?

    ///
    @IBOutlet fileprivate var developerModeLoopModeMaxTestsTextField: UITextField?

    ///
    @IBOutlet fileprivate var developerModeLoopModeMinDelayTextField: UITextField?

    // Measurement server

    ///
    @IBOutlet fileprivate var developerModeMeasurementServerTlsSwitch: UISwitch?

    // TODO: choose measurement server

    // Custom control server

    ///
    @IBOutlet fileprivate var developerModeControlServerCustomizationEnabledSwitch: UISwitch?

    ///
    @IBOutlet fileprivate var developerModeControlServerHostnameTextField: UITextField?

    ///
    @IBOutlet fileprivate var developerModeControlServerPortTextField: UITextField?

    ///
    @IBOutlet fileprivate var developerModeControlServerUseTlsSwitch: UISwitch?

    // Custom map server

    ///
    @IBOutlet fileprivate var developerModeMapServerCustomizationEnabledSwitch: UISwitch?

    ///
    @IBOutlet fileprivate var developerModeMapServerHostnameTextField: UITextField?

    ///
    @IBOutlet fileprivate var developerModeMapServerPortTextField: UITextField?

    ///
    @IBOutlet fileprivate var developerModeMapServerUseTlsSwitch: UISwitch?

    // TODO: dismiss number input fields!

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        //////////////////
        // Developer settings
        //////////////////

        //bindSwitch(noGpsSwitch, toSettingsKeyPath: "TODO", onToggle: nil)
        //bindTextField(measurementTagTextField, toSettingsKeyPath: "TODO", numeric: false)

        //////////////////
        // Loop mode
        //////////////////

        bindSwitch(developerModeLoopModeSwitch, toSettingsKeyPath: "debugLoopMode") { _ in
            //self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            self.tableView.reloadData()
        }

        bindTextField(developerModeLoopModeMaxTestsTextField, toSettingsKeyPath: "debugLoopModeMaxTests", numeric: true)

        bindTextField(developerModeLoopModeMinDelayTextField, toSettingsKeyPath: "debugLoopModeMinDelay", numeric: true)

        //////////////////
        // Measurement server settings
        //////////////////

        //bindSwitch(developerModeMeasurementServerTlsSwitch, toSettingsKeyPath: "TODO", onToggle: nil)
        // TODO: choose measurement server

        //////////////////
        // Custom control server
        //////////////////

        // debugControlServerCustomizationEnabledSwitch
        bindSwitch(developerModeControlServerCustomizationEnabledSwitch, toSettingsKeyPath: "debugControlServerCustomizationEnabled") { _ in
            //self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
            self.tableView.reloadData()
        }

        bindTextField(developerModeControlServerHostnameTextField, toSettingsKeyPath: "debugControlServerHostname", numeric: false)

        bindTextField(developerModeControlServerPortTextField, toSettingsKeyPath: "debugControlServerPort", numeric: true)

        bindSwitch(developerModeControlServerUseTlsSwitch, toSettingsKeyPath: "debugControlServerUseSSL", onToggle: nil)

        //////////////////
        // Custom map server
        //////////////////

        bindSwitch(developerModeMapServerCustomizationEnabledSwitch, toSettingsKeyPath: "debugMapServerCustomizationEnabled") { _ in
            //self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
            self.tableView.reloadData()
        }

        bindTextField(developerModeMapServerHostnameTextField, toSettingsKeyPath: "debugMapServerHostname", numeric: false)

        bindTextField(developerModeMapServerPortTextField, toSettingsKeyPath: "debugMapServerPort", numeric: true)

        bindSwitch(developerModeMapServerUseTlsSwitch, toSettingsKeyPath: "debugMapServerUseSSL", onToggle: nil)
    }

// MARK: Textfield delegate

    ///
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

// MARK: Table view

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: // loop
            return settings.debugLoopMode ? 3 : 1
        case 3: // custom control server
            return settings.debugControlServerCustomizationEnabled ? 4 : 1
        case 4: // custom control server
            return settings.debugMapServerCustomizationEnabled ? 4 : 1
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
}
