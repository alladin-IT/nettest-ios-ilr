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
import RMBTClient
import CoreLocation

///
class GeneralSettingsViewController: AbstractSettingsViewController {

    ///
    @IBOutlet private var sideBarButton: UIBarButtonItem?

    ///
    @IBOutlet private var forceIPv4Switch: UISwitch?

    ///
    //@IBOutlet private var forceIPv6Switch: UISwitch?

    ///
    @IBOutlet private var soundsSwitch: UISwitch?

    ///
    @IBOutlet private var qosMeasurementsSwitch: UISwitch?

    ///
    @IBOutlet private var anonymousModeSwitch: UISwitch?

    ///
    //@IBOutlet private var nerdModeSwitch: UISwitch?

    ///
    //@IBOutlet private var nerdModeQosEnabledLabel: UILabel?

    ///
    //@IBOutlet private var publishPersonalDataTableViewCell: UITableViewCell?

    // TODO: dismiss number input fields!

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        sideBarButton?.target = revealViewController()
        sideBarButton?.action = #selector(SWRevealViewController.revealToggle(_:))

        // Set the gesture
        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())

        revealViewController().delegate = self

        //////////////////
        // General
        //////////////////

        // forceIPv4Switch
        bindSwitch(forceIPv4Switch, toSettingsKeyPath: "nerdModeForceIPv4", onToggle: nil)

        // sounds
        bindSwitch(soundsSwitch, toSettingsKeyPath: "soundsEnabled", onToggle: nil)

        // qos measurements
        bindSwitch(qosMeasurementsSwitch, toSettingsKeyPath: "nerdModeQosEnabled", onToggle: nil)

        // anonymous mode
        bindSwitch(anonymousModeSwitch, toSettingsKeyPath: "anonymousModeEnabled", onToggle: nil)

        // nerd mode
        /*bindSwitch(nerdModeSwitch, toSettingsKeyPath: "nerdModeEnabled") { on in
            if on {
                self.updateNerdModeQosLabel()
            }

            //self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            self.tableView.reloadData()
        }*/
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //updateNerdModeQosLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if RMBTTOS.sharedTOS.goToSettingsAfterAccepting {
            RMBTTOS.sharedTOS.goToSettingsAfterAccepting = false
            performSegue(withIdentifier: "settings_to_contract_settings", sender: nil)
        }
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        RMBT.refreshSettings { } // TODO: also gets called if client contract settings are tapped, do we need to stop this?
    }

// MARK: Support

    ///
    /*fileprivate func updateNerdModeQosLabel() {
        logger.debug("\(self.settings.nerdModeQosEnabled)")
        nerdModeQosEnabledLabel?.text = settings.nerdModeQosEnabled ? "QOS enabled" : "QOS disabled" // TODO: localization
    }*/

// MARK: Table view

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if #available(iOS 11.0, *) {
            if indexPath.section == 4 && indexPath.row == 1 { // disable go to language settings in iOS 11
                cell.isUserInteractionEnabled = false
                cell.textLabel?.isEnabled = false
                cell.detailTextLabel?.isEnabled = false
            }
        }

        return cell
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && !customerIsAlladin() { // hide sounds if not alladin...
            return 0
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && !customerIsAlladin() { // hide sounds if not alladin...
            return nil
        }

        return super.tableView(tableView, titleForHeaderInSection: section)
    }

    ///
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && !customerIsAlladin() { // hide sounds if not alladin...
            return nil
        }

        // system settings iOS 11 text
        if #available(iOS 11.0, *) {
            if section == 4 {
                return L10n.Settings.ios11LanguageText
            }
        }

        return super.tableView(tableView, titleForFooterInSection: section)
    }

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 6

        if RMBTAppCustomerName().lowercased() != "ilr" {
            sections -= 1 // hide contract settings for other customers
        }

        return sections
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 4 {
            //super.tableView(tableView, didSelectRowAt: indexPath)
            return
        }

        // system settings (also works on ios9 -> iphone4s)
        if indexPath.row == 0 { // location settings
            //logger.debug("LOCATION")

            // display general location settings if location services aren't enabled
            // otherwise display app specific location settings

            if !CLLocationManager.locationServicesEnabled() {
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    /*if #available(iOS 11.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {*/
                    UIApplication.shared.openURL(url)
                    //}
                }
            } else {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }

        } else if indexPath.row == 1 { // language settings
            //logger.debug("LANGUAGE")

            // works on devices with ios <= 10 but not with ios11
            if let url = URL(string: "App-Prefs:root=General&path=INTERNATIONAL") {
                UIApplication.shared.openURL(url)
            }
        }
    }

    ///
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 4 {
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    ///
    /*override func numberOfSections(in tableView: UITableView) -> Int {
        /*if RMBTAppCustomerName().lowercased() == "hakom" { // hide nerd mode settings
            return 1
        }*/

        return settings.debugUnlocked ? 3 : 2
    }*/

    ///
    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return settings.nerdModeEnabled ? 2 : 1
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }*/
}

// MARK: SWRevealViewControllerDelegate

///
extension GeneralSettingsViewController: SWRevealViewControllerDelegate {

    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        tableView.isScrollEnabled = false
    }

    ///
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        tableView.isScrollEnabled = false
    }

    ///
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        guard let rc = revealController else {
            return
        }

        let isPosLeft = position == .left

        tableView.isScrollEnabled = isPosLeft
        tableView.allowsSelection = isPosLeft

        if isPosLeft {
            view.removeGestureRecognizer(rc.panGestureRecognizer())
            view.addGestureRecognizer(rc.edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(rc.edgeGestureRecognizer())
            view.addGestureRecognizer(rc.panGestureRecognizer())
        }
    }

}
