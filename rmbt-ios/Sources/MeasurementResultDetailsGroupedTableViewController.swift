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

class MeasurementDetailGroupSectionHeaderView: UITableViewHeaderFooterView {

    ///
    @IBOutlet weak var titleLabel: UILabel?

    ///
    @IBOutlet weak var iconLabel: UILabel?

}

///
class MeasurementResultDetailsGroupedTableViewController: UITableViewController {

    ///
    var measurementUuid: String?

    ///
    fileprivate var data: [SpeedMeasurementDetailGroupResultResponse.SpeedMeasurementDetailGroupItem]?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let nib = UINib(nibName: "MeasurementDetailGroupSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "measurement_detail_group_section_header")

        if let uuid = measurementUuid {
            RMBT.measurementHistory.getMeasurementDetailsGrouped(uuid, success: { (response) in
                self.data = response.speedMeasurementResultDetailGroupList
                self.tableView.reloadData()
            }, error: { /*(error)*/ _ in
                // TODO: handle error
            })
        }
    }

    ///
    fileprivate func itemNeedsLargeCell(_ item: SpeedMeasurementDetailGroupResultResponse.SpeedMeasurementDetailGroupItem.SpeedMeasurementDetailEntry) -> Bool {
        let titleCount = item.title?.count ?? 0
        let valueCount = item.value?.count ?? 0

        return titleCount > 25 || valueCount > 25
    }
}

// MARK: UITableViewDataSource

extension MeasurementResultDetailsGroupedTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 0
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?[section].entries?.count ?? 0
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let item = data?[indexPath.section].entries?[indexPath.row] {

            var cell: UITableViewCell

            if itemNeedsLargeCell(item) {
                cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail_subtitle")!
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail")!
            }

            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.value

            return cell

        } else {
            assert(false, "wrong indexPath")
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate

///
extension MeasurementResultDetailsGroupedTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 100
        }

        return 80
    }

    ///
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = data?[section].title, let icon = data?[section].icon {

            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "measurement_detail_group_section_header") as! MeasurementDetailGroupSectionHeaderView

            cell.titleLabel?.text = title.uppercased()
            cell.iconLabel?.text = icon

            // set colors
            //cell.titleLabel?.textColor = TEXT_COLOR
            cell.iconLabel?.textColor = MEASUREMENT_GAUGE_PROGRESS_COLOR

            return cell
        }

        return nil
    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return data?[section].title
//    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = data?[indexPath.section].entries?[indexPath.row] {
            return UITableViewCell.rmbtApproximateOptimalHeightForText(item.title, detailText: item.value)
        }

        return 44
    }
}
