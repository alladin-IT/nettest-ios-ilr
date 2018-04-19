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
import RMBTClient

///
class RMBTTOSViewController: UIViewController {

    ///
    @IBOutlet private var webView: UIWebView?

    ///
    @IBOutlet private var acceptIntroLabel: UILabel?

    ///
    @IBOutlet private var settingsSwitch: UISwitch?

    ///
    @IBOutlet private var settingsStackView: UIStackView?

    ///
    @IBOutlet private var agreeButtonItem: UIBarButtonItem?

    ///
    @IBOutlet private var declineButtonItem: UIBarButtonItem?

    //

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        acceptIntroLabel?.text = L10n.Tos.message(RMBTAppTitle(), RMBTAppCustomerName())
        acceptIntroLabel?.translatesAutoresizingMaskIntoConstraints = false

        let font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)

        agreeButtonItem?.setTitleTextAttributesForAllStates([NSAttributedStringKey.font: font])
        declineButtonItem?.setTitleTextAttributesForAllStates([NSAttributedStringKey.font: font])

        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)

        agreeButtonItem?.accessibilityIdentifier = "tos_agree" // for ui testing

        if !TERMS_SETTINGS_LINK {
            // hide "take me to the settings"
            settingsStackView?.removeFromSuperview()
        }

        if let htmlFile = Bundle.main.path(forResource: "terms_conditions_long", ofType: "html") {
            let url = URL(fileURLWithPath: htmlFile)
            webView?.loadRequest(URLRequest(url: url))
        }
    }

    ///
    @IBAction func agree(_ sender: AnyObject) {
        RMBTTOS.sharedTOS.acceptCurrentVersion()

        if TEST_USE_PERSONAL_DATA_FUZZING {
            performSegue(withIdentifier: "show_publish_personal_data", sender: self)
        } else {
            if let on = settingsSwitch?.isOn, on, TERMS_SETTINGS_LINK {
                RMBTTOS.sharedTOS.goToSettingsAfterAccepting = true

                dismiss(animated: true) {

                    /*let settingsViewController = StoryboardScene.Settings.initialScene.instantiate()
                    
                    self.parent?.revealViewController().frontViewController = settingsViewController
                    
                    if let r = self.parent?.revealViewController().rearViewController as? SideMenuController {
                        r.selectRow(identifier: "settings")
                    }*/

                    //self.performSegue(withIdentifier: "pushSettingsViewControllerFromTos", sender: nil)
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    ///
    @IBAction func decline(_ sender: AnyObject) {
        RMBTTOS.sharedTOS.declineCurrentVersion()

        // quit app
        exit(EXIT_SUCCESS)
    }

    ///
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set side menu selected item to settings
        if segue.identifier == "pushSettingsViewControllerFromTos" {
            if let r = parent?.revealViewController().rearViewController as? SideMenuController {
                r.selectRow(identifier: "settings")
            }
        }
    }*/
}

///
extension RMBTTOSViewController: UIWebViewDelegate {

    /// Handle external links in a modal browser window
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url, let scheme = url.scheme {
            switch scheme {
            case "file": return true
            case "mailto": return false // TODO: Open compose dialog
            default:
                presentModalBrowserWithURLString(url.absoluteString)
                return false
            }
        }

        return false
    }
}
