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

///
struct QosMeasurementTestItem {

    ///
    var title: String

    ///
    var summary: String

    ///
    var testDescription: String

    ///
    var objectiveId: Int

    ///
    var oldUid: Int

    ///
    var success: Bool
}

///
class QosMeasurementTestTableViewController: UITableViewController {

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var qosMeasurementItem: QosMeasurementItem?

    ///
    var testItems = [QosMeasurementTestItem]()

    ///
    let testStr = NSLocalizedString("history.qos.detail.test", value: "Test", comment: "Name of a test")

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = qosMeasurementItem?.type.description
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if let testResultDetail = qosMeasurementResult?.testResultDetail {
            var cnt = 0

            testItems.append( // TODO: should be done by rmbt-ios-client library
                contentsOf: testResultDetail.filter({ measurementQosResult in
                    return measurementQosResult.type == qosMeasurementItem?.type
                }).map({ measurementQosResult in
                    cnt += 1

                    if let  summary = measurementQosResult.summary,
                            let testDescription = measurementQosResult.testDesc,
                            let objectiveId = measurementQosResult.objectiveId,
                            let oldUid = measurementQosResult.oldUid {

                        return QosMeasurementTestItem(
                            title: "\(testStr) #\(cnt)",
                            summary: summary,
                            testDescription: testDescription,
                            objectiveId: objectiveId,
                            oldUid: oldUid,
                            success: measurementQosResult.failureCount == 0)
                    }

                    assert(false, "this should never happen")
                    return QosMeasurementTestItem(
                        title: "-",
                        summary: "-",
                        testDescription: "-",
                        objectiveId: -1,
                        oldUid: -1,
                        success: false)
                })
            )
        }

        tableView.reloadData()
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_qos_test_detail" {
            if let qosMeasurementTestDetailTableViewController = segue.destination as? QosMeasurementTestDetailTableViewController {
                if let index = sender as? Int {
                    qosMeasurementTestDetailTableViewController.qosMeasurementResult = qosMeasurementResult
                    qosMeasurementTestDetailTableViewController.qosMeasurementTestItem = testItems[index]
                }
            }
        }
    }
}

// MARK: UITableViewDataSource

extension QosMeasurementTestTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("history.qos.headline.details", value: "DETAILS", comment: "Details")
        case 1:
            return NSLocalizedString("history.qos.headline.tests", value: "TESTS", comment: "Tests")
        default:
            assert(false, "wrong section")
            return "-"
        }
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return testItems.count
        }
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // description section

            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_test_description_cell")!

            if let item = qosMeasurementItem {
                cell.textLabel?.text = item.descriptionText
            }

            return cell

        } else { // test list section

            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_test_cell")!

            let item = testItems[indexPath.row]

            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.summary

            let statusView = UIBoolVisualizationView(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
            statusView.status = item.success ? .success : .failure

            cell.accessoryView = statusView

            return cell
        }
    }
}

// MARK: UITableViewDelegate

///
extension QosMeasurementTestTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 60
        }
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: "show_qos_test_detail", sender: indexPath.row)
        }
    }
}
