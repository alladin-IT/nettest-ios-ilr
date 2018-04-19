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
import UIKit
import RMBTClient
import ActionKit

///
class AbstractSettingsViewController: UITableViewController {

    ///
    let settings = RMBTSettings.sharedSettings

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

// MARK: Two-way binding helpers

    ///
    func bindSwitch(_ aSwitch: UISwitch?, toSettingsKeyPath keyPath: String, onToggle: ((_ value: Bool) -> Void)?) {
        aSwitch?.isOn = (settings.value(forKey: keyPath) as! NSNumber).boolValue
        aSwitch?.addControlEvent(.valueChanged) { (control: UIControl) in
            guard let currentSwitch = control as? UISwitch else {
                return
            }

            self.settings.setValue(NSNumber(value: currentSwitch.isOn), forKey: keyPath)

            onToggle?(currentSwitch.isOn)
        }
//        
//        aSwitch?.addControlEvent(.valueChanged) { (currentSwitch: UISwitch) in
//            self.settings.setValue(NSNumber(value: currentSwitch.isOn), forKey: keyPath)
//
//            onToggle?(currentSwitch.isOn)
//        }
    }

    ///
    func bindTextField(_ textField: UITextField?, toSettingsKeyPath keyPath: String, numeric: Bool) {
        var stringValue: String?

        if let val = settings.value(forKey: keyPath) {
            if numeric {
                stringValue = (val as? NSNumber)?.stringValue
            } else {
                stringValue = val as? String
            }
        }

        textField?.text = stringValue

        textField?.addControlEvent(.editingDidEnd) { (control: UIControl) in
            guard let currentTextField = control as? UITextField else {
                return
            }

            var newValue: AnyObject? = currentTextField.text as AnyObject?

            if numeric {
                if let text = currentTextField.text, let num = Int(text) {
                    newValue = NSNumber(value: num)
                }
            }

            self.settings.setValue(newValue, forKey: keyPath)
        }
    }
}
