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

///
class HistoryFilterTableViewController: UITableViewController {

    ///
    var filterData: [[String: AnyObject]]?

    ///
    var filters: [String: [String]] = [:]

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        filterData = RMBT.measurementHistory.getHistoryFilterModel()

        tableView?.reloadData()
    }
}

// MARK: UITableViewDataSource

extension HistoryFilterTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filterData?.count ?? 0
    }

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filterData?[section]["name"] as? String
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filterData?[section]["items"] as? [String])?.count ?? 0
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "---") //tableView.dequeueReusableCellWithIdentifier("")!

        let filterName = filterData?[indexPath.section]["name"] as? String
        let filterContent = (filterData?[indexPath.section]["items"] as? [String])?[indexPath.row]

        logger.debug("\(String(describing: self.filterData))")
        logger.debug("\(self.filters)")
        logger.debug("\(String(describing: filterName)), \(String(describing: filterContent))")

        cell.textLabel?.text = filterContent

        if let filterName1 = filterName, let filterContent1 = filterContent, let filterSet = filters[filterName1]?.contains(filterContent1) {
            logger.debug("FILTER SET \(filterSet)")

            cell.accessoryType = filterSet ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}

// MARK: UITableViewDelegate

///
extension HistoryFilterTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    ///
    /*override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

    }*/

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
