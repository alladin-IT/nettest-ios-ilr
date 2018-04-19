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
class PopupTableViewController: UIViewController {

    ///
    @IBOutlet var tableView: UITableView?

    ///
    var headline: String?

    ///
    var data: [[String]]?

    ///
    override func viewDidLoad() {
        tableView?.dataSource = self
        tableView?.delegate = self

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }

    ///
    func update() {
        logger.debug("UPDATE")

        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    ///
    func stop() {

    }

    ///
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

///
extension PopupTableViewController: UITableViewDataSource {

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    ///
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headline
    }

    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "_test", for: indexPath)

        cell.textLabel?.text = data?[indexPath.row][0]
        cell.detailTextLabel?.text = data?[indexPath.row][1]

        return cell
    }
}

///
extension PopupTableViewController: UITableViewDelegate {

}
