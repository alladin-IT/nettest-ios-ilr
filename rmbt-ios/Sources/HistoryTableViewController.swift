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
class HistoryTableViewController: TopLevelTableViewController {

    ///
    fileprivate var data: [HistoryItem]?

    ///
    fileprivate var dateFormatter: DateFormatter?

    ///
    fileprivate var filters: [String: [String]] = [:] //["model": ["Blubschlub"]]

    // TODO: reload, load more chunks, filters, etc

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.rightBarButtonItem?.title = "\u{00F9}"
        navigationItem.rightBarButtonItem?.icon = .filter
        navigationItem.setRightBarButton(nil, animated: false) // TODO: remove history filter icon until history filters work!

        //tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)

        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = .medium
        dateFormatter?.timeStyle = .medium

        loadHistory()
    }

    ///
    fileprivate func loadHistory() {
        // TODO: filters, pagination
        RMBT.measurementHistory.getHistoryList(filters, success: { (response) in
            self.data = response

            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }

        }, error: { /*(error)*/ _ in
            // TODO: show error message
        })
    }

    ///
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        loadHistory() // TODO: force -> override dirty flag
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.History(rawValue: segue.identifier!)! {
        case .showHistoryItem:
            if let measurementResultTableViewController = segue.destination as? MeasurementResultTableViewController {
                if let index = sender as? Int, let historyItem = data?[index] {
                    measurementResultTableViewController.measurementUuid = historyItem.testUuid //sender as? String
                    measurementResultTableViewController.qosResultsAvailable = historyItem.qosResultAvailable
                }
            }
        case .showHistoryFilters:
            if let historyFilterTableViewController = sender as? HistoryFilterTableViewController {
                historyFilterTableViewController.filters = filters
            }
        default: break
        }
    }

    ///
    @IBAction func unwindFromHistoryFilterViewController(_ segue: UIStoryboardSegue?) {
        logger.debug("UNWIND!")

        if let historyFilterTableViewController = segue?.source as? HistoryFilterTableViewController {
            filters = historyFilterTableViewController.filters
        }
    }
}

// MARK: UITableViewDataSource

extension HistoryTableViewController {

    ///
    //override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //    return ""
    //}

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 1 // it's not allowed to have 0 sections...
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0 > 0 ? 1 : 0
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history_item_cell") as! HistoryItemTableViewCell

        if let item = data?[indexPath.section] {
            if let networkType = item.networkType {
                switch networkType {
                case "WLAN", "WIFI":
                    cell.networkTypeIconLabel?.icon = .wifi
                case "LAN", "CLI":
                    cell.networkTypeIconLabel?.icon = .network
                default:
                    cell.networkTypeIconLabel?.icon = .cellular
                }
            } else {
                cell.networkTypeIconLabel?.text = "" // reset, since table view cell could be reused
            }

            cell.networkTypeLabel?.text = item.networkType

            cell.modelLabel?.text = item.model

            if let time = item.time {
                cell.dateLabel?.text = dateFormatter?.string(from: Date(timeIntervalSince1970: Double(time) / 1000)) //item.timeString
            } else {
                cell.dateLabel?.text = item.timeString
            }

            cell.qosAvailableLabel?.isHidden = !item.qosResultAvailable

            if let ping = item.ping {
                cell.pingLabel?.text = ping + " " + L10n.Test.Ping.unit
            }

            if let speedDownload = item.speedDownload {
                cell.downloadSpeedLabel?.text = speedDownload + " " + L10n.Test.Speed.unit
            }

            if let speedUpload = item.speedUpload {
                cell.uploadSpeedLabel?.text = speedUpload + " " + L10n.Test.Speed.unit
            }

            cell.networkTypeIconLabel?.textColor = ICON_TINT_COLOR
            cell.pingIconLabel?.textColor = ICON_TINT_COLOR
            cell.downloadIconLabel?.textColor = ICON_TINT_COLOR
            cell.uploadIconLabel?.textColor = ICON_TINT_COLOR
        }

        return cell
    }
}

// MARK: UITableViewDelegate

///
extension HistoryTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let /*historyItem*/ _ = data?[indexPath.section] {
            perform(segue: StoryboardSegue.History.showHistoryItem, sender: indexPath.section/*historyItem.testUuid*/)
        }
    }

    ///
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in // TODO: localize
            if let measurementUuid = self.data?[indexPath.section].testUuid {

                RMBT.measurementHistory.disassociateMeasurement(measurementUuid, success: { _ in
                    // TODO: show success message

                    // remove from table view and refresh
                    _ = self.data?.remove(at: indexPath.section)
                    self.tableView.reloadData()
                    //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    ////self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                }, error: { /*error*/ _ in
                    // TODO: show error
                    logger.debug("DISASSOCIATE ERROR")
                })
            }
        }

        return [deleteAction]
    }
}
