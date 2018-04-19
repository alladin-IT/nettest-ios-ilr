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
import MessageUI
import GoogleMaps
import RMBTClient

///
class InfoViewController: TopLevelTableViewController {

    ///
    private enum InfoViewControllerSection: Int {
        case links = 0
        case clientInfo = 1
        case devInfo = 2
    }

    ///
    @IBOutlet private var websiteDetailLabel: UILabel?
    @IBOutlet private var emailDetailLabel: UILabel?

    ///
    @IBOutlet private var logoImageView: UIImageView?

    ///
    @IBOutlet private var copyrightLabel: UILabel?

    ///
    @IBOutlet private var headerTitleLabel: UILabel?

    ///
    @IBOutlet private var testCounterLabel: UILabel?

    ///
    @IBOutlet private var uuidCell: UITableViewCell?

    ///
    @IBOutlet private var privacyCell: UITableViewCell?

    ///
    @IBOutlet private var uuidLabel: UILabel?

    ///
    @IBOutlet private var buildDetailsLabel: UILabel?

    ///
    @IBOutlet private var controlServerVersionLabel: UILabel?

    //

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.title = L("info.header")

        websiteDetailLabel?.text                = RMBT_PROJECT_URL
        emailDetailLabel?.text                  = RMBT_PROJECT_EMAIL

        if let localizedImage = UIImage(named: "info-logo-\(RMBTPreferredLanguage())") {
            logoImageView?.image = localizedImage
        }

        buildDetailsLabel?.lineBreakMode = .byCharWrapping

        let versionString = RMBTVersionString()

        buildDetailsLabel?.text = "\(versionString) [\(RMBTBuildInfoString()) (\(RMBTBuildDateString()))]"
        buildDetailsLabel?.boldSubstring(versionString)

        uuidLabel?.lineBreakMode = .byCharWrapping
        uuidLabel?.numberOfLines = 0

        headerTitleLabel?.text = RMBTAppTitle()

        testCounterLabel?.text = String(format: "%lu", RMBTSettings.sharedSettings.testCounter)

        controlServerVersionLabel?.text = RMBT.controlServerVersion

        if let uuid = RMBT.uuid {
            uuidLabel?.text = "U\(uuid)"
        }

        // checkmynet.lu: show powered by ilr or no text
        if customerIsIlr() {
            copyrightLabel?.isHidden = true
            //copyrightLabel?.text = "Powered by ILR"
        }
    }

// MARK: tableView

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = InfoViewControllerSection(rawValue: indexPath.section)

        if section == .clientInfo && indexPath.row == 0 { // UUID
            return uuidCell?.rmbtApproximateOptimalHeight() ?? 0
        } else if section == .links && indexPath.row == 2 { // Privacy
            return privacyCell?.rmbtApproximateOptimalHeight() ?? 0
        } else if section == .clientInfo && indexPath.row == 2 { // Version
            return 62
        } else {
            return 44
        }
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = InfoViewControllerSection(rawValue: indexPath.section)

        if section == .links {
            switch indexPath.row {
            case 0: presentModalBrowserWithURLString(RMBT_PROJECT_URL)
            case 1:
                if MFMailComposeViewController.canSendMail() {
                    let mailVC = MFMailComposeViewController()
                    mailVC.setToRecipients([RMBT_PROJECT_EMAIL])
                    mailVC.mailComposeDelegate = self

                    mailVC.navigationBar.isTranslucent = false

                    present(mailVC, animated: true, completion: nil)
                }
            case 2: presentModalBrowserWithURLString(RMBT_PRIVACY_TOS_URL)
            default: assert(false, "Invalid row")
            }
        } else if section == .devInfo {
            switch indexPath.row {
            case 0: self.presentModalBrowserWithURLString(RMBT_DEVELOPER_URL)
            case 1: self.presentModalBrowserWithURLString(RMBT_REPO_URL)
            case 2: break // Do nothing
            default: assert(false, "Invalid row")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_google_maps_notice" {
            if let textVC = segue.destination as? InfoTextViewController {
                textVC.text = GMSServices.openSourceLicenseInfo()
                textVC.title = NSLocalizedString("info.google-maps.legal-notice", value: "Legal Notice", comment: "Google Maps Legal Notice navigation title")
            }
        }
    }

// MARK: Tableview actions (copying UUID)

    /// Show "Copy" action for cell showing client UUID
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let section = InfoViewControllerSection(rawValue: indexPath.section)

        return (section == .clientInfo && indexPath.row == 0 && RMBT.uuid != nil)
    }

    /// As client UUID is the only cell we can perform action for, we allow "copy" here
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    ///
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any!) {
        if action == #selector(copy(_:)) {
            // Copy UUID to pasteboard
            UIPasteboard.general.string = RMBT.uuid
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate

///
extension InfoViewController: MFMailComposeViewControllerDelegate {

    ///
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
