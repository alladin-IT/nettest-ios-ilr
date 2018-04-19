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
import RMBTClient

///
class QosMeasurementNewIndexViewController: UICollectionViewController {

    fileprivate let reuseIdentifier = "qos_collection_view_cell"

    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

    fileprivate var itemsPerRow: CGFloat = 2

    fileprivate var heightFactor: CGFloat = 0.85

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var qosMeasurementItems = [QosMeasurementItem]()

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {
            itemsPerRow = 4
        }

        if UIScreen.main.bounds.width <= 320 {
            heightFactor = 1
        }

        parseQosResultForIndexView()
    }

    ///
    fileprivate func parseQosResultForIndexView() { // TODO: should be done by rmbt-ios-client library
        if let resultDetail = qosMeasurementResult?.testResultDetail {

            var successCountDict = [QOSMeasurementType: Int]()
            var countDict = [QOSMeasurementType: Int]()

            for i in resultDetail {

                if let type = i.type, let failureCount = i.failureCount {
                    // success count
                    if failureCount == 0 {
                        if let current = successCountDict[type] {
                            successCountDict[type] = current + 1
                        } else {
                            successCountDict[type] = 1
                        }
                    }

                    // overall count
                    if let current = countDict[type] {
                        countDict[type] = current + 1
                    } else {
                        countDict[type] = 1
                    }
                }
            }

            for (type, count) in countDict {
                if let descriptionText = qosMeasurementResult?.testResultDetailTestDescription?.filter({ desc in // TODO: improve this, "for in" the array only once!
                    return desc.type == type
                }).first?.description {

                    let item = QosMeasurementItem(type: type, count: count, successCount: successCountDict[type] ?? 0, descriptionText: descriptionText)
                    qosMeasurementItems.append(item)
                }
            }
        }

        collectionView?.reloadData()
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_qos_test_new" /* TODO */ {
            if let qosTestTableViewController = segue.destination as? QosMeasurementTestTableViewController {
                if let index = sender as? Int {
                    qosTestTableViewController.qosMeasurementResult = qosMeasurementResult
                    qosTestTableViewController.qosMeasurementItem = qosMeasurementItems[index]
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

///
extension QosMeasurementNewIndexViewController {

    ///
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    ///
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return qosMeasurementItems.count
    }

    ///
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QosCollectionViewCell

        cell.iconLabel?.textColor = MEASUREMENT_GAUGE_PROGRESS_COLOR // TODO: other color? like "highlight/special" color?
        cell.nameLabel?.textColor = TEXT_COLOR
        cell.infoLabel?.textColor = TEXT_COLOR

        let item = qosMeasurementItems[indexPath.row]

        cell.iconLabel?.icon = IconFont.forQosMeasurementType(type: item.type)

        // success icons
        if item.count == item.successCount {
            cell.stateIconLabel?.icon = IconFont.check
            cell.stateIconLabel?.textColor = COLOR_CHECK_GREEN
        } else if item.successCount == 0 {
            cell.stateIconLabel?.icon = IconFont.cross
            cell.stateIconLabel?.textColor = COLOR_CHECK_RED
        } else {
            cell.stateIconLabel?.icon = IconFont.check
            cell.stateIconLabel?.textColor = COLOR_CHECK_YELLOW
        }

        ///

        cell.nameLabel?.text = item.type.description
        cell.infoLabel?.text = "\(item.successCount)/\(item.count)"

        return cell
    }
}

///
extension QosMeasurementNewIndexViewController {

    ///
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show_qos_test_new" /* TODO */, sender: indexPath.row)
    }
}

///
extension QosMeasurementNewIndexViewController: UICollectionViewDelegateFlowLayout {

    ///
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem * heightFactor)
    }

    ///
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    ///
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
