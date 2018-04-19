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
class RMBTMapOptionsViewController: RMBTMapSubViewController {

    ///
    @IBOutlet fileprivate var mapViewTypeSegmentedControl: UISegmentedControl!

    ///
    fileprivate var activeSubtypeAtStart: RMBTMapOptionsSubtype!

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(mapOptions != nil) // TODO: is this line doubled?

        // Save reference to active subtype so we can detect if anything changed when going back
        activeSubtypeAtStart = mapOptions.activeSubtype

        mapViewTypeSegmentedControl.selectedSegmentIndex = mapOptions.mapViewType.rawValue
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.mapSubViewController(self, willDisappearWithChange: activeSubtypeAtStart !== mapOptions.activeSubtype)
    }

// MARK: UITableViewDelegate methods

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = mapOptions.types[section]
        return type.subtypes.count
    }

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let type = mapOptions.types[section]
        return type.title
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "map_subtype_cell"

        let type = mapOptions.types[indexPath.section]
        let subtype = type.subtypes[indexPath.row]

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        cell.textLabel?.text = subtype.title
        cell.detailTextLabel?.text = subtype.summary

        if subtype === mapOptions.activeSubtype {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = mapOptions.types[indexPath.section]
        let subtype = type.subtypes[indexPath.row]

        if subtype === mapOptions.activeSubtype {
            // No change, do nothing
        } else {
            let previousSection: Int = mapOptions.types.index(of: mapOptions.activeSubtype.type)!
            let previousRow: Int = mapOptions.activeSubtype.type.subtypes.index(of: mapOptions.activeSubtype)!

            mapOptions.activeSubtype = subtype

            tableView.reloadRows(
                at: [indexPath, IndexPath(row: previousRow, section: previousSection)],
                with: .automatic
            )
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.mapOptions.types.count
    }

// MARK: other methods

    ///
    @IBAction func mapViewTypeSegmentedControlIndexDidChange(_ sender: AnyObject) {
        mapOptions.mapViewType = RMBTMapOptionsMapViewType(rawValue: mapViewTypeSegmentedControl.selectedSegmentIndex)!
    }
}
