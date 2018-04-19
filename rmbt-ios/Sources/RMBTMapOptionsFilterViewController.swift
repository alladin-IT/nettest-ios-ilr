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
class RMBTMapOptionsFilterViewController: RMBTMapSubViewController {

    ///
    fileprivate var activeFiltersAtStart: [RMBTMapOptionsFilterValue]!

    ///
    fileprivate var activeOverlayAtStart: RMBTMapOptionsOverlay!

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Store reference to active filters at start so we can determine if anything changed
        activeFiltersAtStart = activeFilters()
        activeOverlayAtStart = mapOptions.activeOverlay
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let changed = (activeOverlayAtStart != mapOptions.activeOverlay) || (activeFilters() != activeFiltersAtStart) // TODO: sometimes EXC_BAD_INSTRUCTION when closing...

        delegate?.mapSubViewController(self, willDisappearWithChange: changed)
    }

// MARK: Table view data source

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mapOptions.activeSubtype.type.filters.count + 1 /* overlays */
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mapOptions.overlays.count
        } else {
            return filterForSection(section).possibleValues.count
        }
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "map_filter_cell"

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        if indexPath.section == 0 {
            // Overlays
            let overlay: RMBTMapOptionsOverlay = mapOptions.overlays[indexPath.row] as RMBTMapOptionsOverlay // !

            cell.textLabel?.text = overlay.localizedDescription
            cell.detailTextLabel?.text = nil

            cell.accessoryType = (mapOptions.activeOverlay == overlay) ? .checkmark : .none
        } else {
            // Filters
            let filter = filterForSection(indexPath.section)
            let value = filter.possibleValues[indexPath.row] as RMBTMapOptionsFilterValue

            cell.textLabel?.text = value.title

            if value.summary == value.title {
                cell.detailTextLabel?.text = nil
            } else {
                cell.detailTextLabel?.text = value.summary
            }

            cell.accessoryType = (filter.activeValue == value) ? .checkmark : .none
        }

        return cell
    }

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("map.options.filter.overlay", value: "Overlay", comment: "Table section header title")
        } else {
            return filterForSection(section).title.capitalized
        }
    }

// MARK: Table view delegate

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let overlay = mapOptions.overlays[indexPath.row] as RMBTMapOptionsOverlay
            if overlay == mapOptions.activeOverlay {
                // do nothing
            } else {
                let previousRow: Int = (mapOptions.overlays as NSArray).index(of: mapOptions.activeOverlay)
                //find(self.mapOptions.overlays, self.mapOptions.activeOverlay)

                mapOptions.activeOverlay = overlay

                tableView.reloadRows(at: [indexPath, IndexPath(row: previousRow, section: indexPath.section)], with: .automatic)
            }
        } else {
            let filter = filterForSection(indexPath.section)
            let value = filterValueForIndexPath(indexPath)

            if value == filter.activeValue {
                // Do nothing
            } else {
                let previousRow: Int = (filter.possibleValues as NSArray).index(of: filter.activeValue)
                //find(filter.possibleValues, filter.activeValue)

                filter.activeValue = value

                tableView.reloadRows(at: [indexPath, IndexPath(row: previousRow, section: indexPath.section)], with: .automatic)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

// MARK: Filter accessor

    ///
    func filterForSection(_ section: Int) -> RMBTMapOptionsFilter {
        return mapOptions.activeSubtype.type.filters[section - 1] as RMBTMapOptionsFilter
    }

    ///
    func filterValueForIndexPath(_ indexPath: IndexPath) -> RMBTMapOptionsFilterValue {
        let filter = filterForSection(indexPath.section)
        return filter.possibleValues[indexPath.row] as RMBTMapOptionsFilterValue
    }

// MARK: Others

    ///
    func activeFilters() -> [RMBTMapOptionsFilterValue] {
        return mapOptions.activeSubtype.type.filters.map { (f) -> RMBTMapOptionsFilterValue in
            return f.activeValue
        }
    }
}
