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

///
class ClientContractSettingsViewController: AbstractSettingsViewController {

    ///
    @IBOutlet fileprivate var contractName: UITextField?

    ///
    @IBOutlet fileprivate var downloadKbps: UITextField?

    ///
    @IBOutlet fileprivate var uploadKbps: UITextField?

    // TODO: dismiss number input fields!

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        bindTextField(contractName, toSettingsKeyPath: "clientContractContractName", numeric: false)
        bindTextField(downloadKbps, toSettingsKeyPath: "clientContractDownloadKbps", numeric: true)
        bindTextField(uploadKbps, toSettingsKeyPath: "clientContractUploadKbps", numeric: true)
    }
}

///
extension ClientContractSettingsViewController: UITextFieldDelegate {

    ///
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
