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
import CoreLocation
import RMBTClient
import GoogleMaps
import TUSafariActivity

///
class MeasurementResultTableViewController: UITableViewController {

    ///
    @IBOutlet private var shareNaviationItem: UIBarButtonItem?

    ///
    var measurementUuid: String?

    ///
    var qosResultsAvailable = false

    ///
    var measuredNow = false

    ///
    var fromMap = false

    ///
    var speedMeasurementResult: SpeedMeasurementResultResponse?

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var staticMapImage: UIImage?

    ///
    var qosSuccessPercentageString: String?

    ///
    var coordinates: CLLocationCoordinate2D?

    ///
    //var reverseGeocodeAddressString: String?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        logger.debug(navigationItem.rightBarButtonItems)

        if !measuredNow || !HISTORY_RERUN_BUTTON_ENABLED { // hide 'run again' if we got here from the history
            navigationItem.rightBarButtonItems?.removeFirst()
        }

        logger.debug(navigationItem.rightBarButtonItems)

        if !HISTORY_SHARE_BUTTON_ENABLED {
            navigationItem.rightBarButtonItems?.removeLast()
        }

        logger.debug(navigationItem.rightBarButtonItems)

        if let uuid = measurementUuid {
            loadSpeedMeasurement(uuid)

            if qosResultsAvailable {
                loadQosMeasurement(uuid)
            }
        }
    }

    ///
    @IBAction func runAgain() {
        logger.debug("run again")

        if let measurementViewController = navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as? NKOMMeasurementViewController {
            measurementViewController.runAgain = true

            _ = navigationController?.popViewController(animated: true)
            return
        }

        if RMBTAppCustomerName().lowercased() == "ilr" {
            if let /*measurementViewController*/_ = navigationController?.viewControllers[navigationController!.viewControllers.count - 2] {
                //measurementViewController.runAgain = true

                _ = navigationController?.popViewController(animated: true)
                _ = navigationController?.popViewController(animated: true)
            }

            return
        }
    }

    ///
    @IBAction func shareResult() {
        var items = [String]()
        let/*var*/ activities = [UIActivity]()

        if let text = speedMeasurementResult?.shareText {
            items.append(text)
        }

        /*if let url = speedMeasurementResult?.shareUrl {
            items.append(url)
            activities.append(TUSafariActivity())
        }*/

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
        activityViewController.setValue(RMBTAppTitle(), forKey: "subject") // TODO?: speedMeasurementResult?.shareSubject

        present(activityViewController, animated: true, completion: nil)
    }

    /// load speed measurement
    fileprivate func loadSpeedMeasurement(_ uuid: String) {
        RMBT.measurementHistory.getMeasurement(uuid, success: { response in
            logger.info("Speed measurement with uuid \(uuid) was loaded sucessfully")

            self.speedMeasurementResult = response

            // check if we have coordinates for reverse geo coding
            /*if let lat = self.speedMeasurementResult?.latitude, lon = self.speedMeasurementResult?.longitude {
                self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                GMSGeocoder().reverseGeocodeCoordinate(self.coordinates!, completionHandler: { response, error in
                    self.reverseGeocodeAddressString = response?.firstResult()?.thoroughfare // TODO

                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }*/

            // load static map image, or remove map section is NO_MAP is true
            if NO_MAP {
                /*DispatchQueue.main.async {
                    // TODO
                    //self.tableView.deleteSections(IndexSet(integer: 4), with: .none)
                    //self.tableView.reloadData()
                }*/
            } else {
                if let lat = self.speedMeasurementResult?.latitude, let lon = self.speedMeasurementResult?.longitude {

                    let mapWidth = Int(self.tableView.bounds.width * self.tableView.contentScaleFactor)

                    let rowHeight = self.tableView(self.tableView, heightForRowAt: IndexPath(row: 1, section: 4))
                    let mapHeight = Int(rowHeight * self.tableView.contentScaleFactor)

                    logger.debug("mapWidth: \(mapWidth), mapHeight: \(mapHeight)")

                    self.staticMapImage = StaticMap.getStaticMapImageWithCenteredMarker(
                        lat, lon: lon, width: mapWidth, height: mapHeight, zoom: 15, markerLabel: "Measurement" // TODO: localize?
                    )
                }
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }, error: { /*error*/ _ in
            // TODO: handle error
        })
    }

    /// load qos measurement
    fileprivate func loadQosMeasurement(_ uuid: String) {
        RMBT.measurementHistory.getQosMeasurement(uuid, success: { response in
            logger.info("Qos measurement with uuid \(uuid) was loaded sucessfully")

            self.qosMeasurementResult = response
            self.calculateQosSuccessPercentage()

            //self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .None) // reload only qos section
            self.tableView.reloadData()

        }, error: { /*error*/ _ in
            // TODO: handle error
        })
    }

    /// calculate success/failure percentage
    fileprivate func calculateQosSuccessPercentage() {
        var successCount = 0

        if let testResultDetail = qosMeasurementResult?.testResultDetail, testResultDetail.count > 0 {
            for result in testResultDetail {
                if let failureCount = result.failureCount, failureCount == 0 {
                    successCount += 1
                }
            }

            let percentage = 100 * successCount/testResultDetail.count
            qosSuccessPercentageString = String(format: "%i%% (%i/%i)", percentage, successCount, testResultDetail.count)

            logger.info("QOS INFO: \(String(describing: self.qosSuccessPercentageString))")
        } else {
            logger.error("NO QOS testResultDetail")
        }
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.History(rawValue: segue.identifier!)! {
        case .showResultDetails:
            if let resultDetailsViewController = segue.destination as? MeasurementResultDetailsTableViewController {
                resultDetailsViewController.measurementUuid = measurementUuid // TODO: save details into object (that we don't have to make a request each time)
            }
        case .showResultDetailsGrouped:
            if let resultDetailsGroupedViewController = segue.destination as? MeasurementResultDetailsGroupedTableViewController {
                resultDetailsGroupedViewController.measurementUuid = measurementUuid // TODO: save details into object (that we don't have to make a request each time)
            }
        case .showQosResults:
            if let qosMeasurementIndexTableViewController = segue.destination as? QosMeasurementIndexTableViewController {
                qosMeasurementIndexTableViewController.qosMeasurementResult = qosMeasurementResult
            }
        case .showQosResultsNew:
            if let qosMeasurementIndexTableViewController = segue.destination as? QosMeasurementNewIndexViewController {
                qosMeasurementIndexTableViewController.qosMeasurementResult = qosMeasurementResult
            }
        case .showResultOnMap:
            if let mapViewController = segue.destination as? RMBTMapViewController {
                if let lat = speedMeasurementResult?.latitude, let lon = speedMeasurementResult?.longitude {
                    mapViewController.hidesBottomBarWhenPushed = true
                    mapViewController.initialLocation = CLLocation(latitude: lat, longitude: lon)
                }
            }
        default: break
        }
    }

    ///
    fileprivate func sectionShouldBeHidden(_ section: Int) -> Bool {
        if section == 3 && qosMeasurementResult == nil { // hide qos if there are no results
            return true
        }

        if section == 4 && (speedMeasurementResult?.latitude == nil || speedMeasurementResult?.longitude == nil) { // hide map if there are no coordinates
            return true
        }

        return false
    }
}

// MARK: UITableViewDataSource

extension MeasurementResultTableViewController {

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionShouldBeHidden(section) {
            return nil
        }

        switch section {
        case 0:
            var measurementHeader = L10n.History.Result.Headline.measurement
            if let timeString = speedMeasurementResult?.timeString {
                measurementHeader += " - " + timeString
            }
            return measurementHeader
        case 1: return L10n.History.Result.Headline.network
        case 2: return L10n.History.Result.Headline.details
        case 3: return L10n.History.Result.Headline.qos
        case 4:
            var mapHeader = L10n.History.Result.Headline.map
            if let location = speedMeasurementResult?.location {
                mapHeader += " - " + location
            }
            return mapHeader
        default: return "-unknown section-"
        }
    }

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 5

        // TODO
        //if speedMeasurementResult?.latitude == nil || speedMeasurementResult?.longitude == nil {
        //    sections -= 1 // hide map
        //}

        if NO_MAP {
            sections -= 1
        }

        return sections
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionShouldBeHidden(section) {
            return 0
        }

        switch section {
        case 0: return speedMeasurementResult?.classifiedMeasurementDataList?.count ?? 0
        case 1: return speedMeasurementResult?.networkDetailList?.count ?? 0
        case 2: return 2
        case 3: return 2
        case 4: return 1
        default: return 0
        }
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Measurement info

            // no classification for nkom...
            let cell = tableView.dequeueReusableCell(withIdentifier: "classifyable_key_value_cell") as! ClassifyableKeyValueTableViewCell

            if let classifiedData = speedMeasurementResult?.classifiedMeasurementDataList?[indexPath.row] {

                cell.keyLabel?.text = classifiedData.title
                cell.valueLabel?.text = classifiedData.value

                if let classificationColor = UIColor(hexString: classifiedData.classificationColor) {
                    cell.classificationColor = classificationColor
                } else {
                    cell.classification = classifiedData.classification
                }

                cell.accessoryType = .none
            }

            return cell

        case 1: // Network info

            let cell = tableView.dequeueReusableCell(withIdentifier: "key_value_cell") as! KeyValueTableViewCell

            //if let networkDetailList = speedMeasurementResult?.networkDetailList where networkDetailList.count >= indexPath.row {
            //    let networkDetail = networkDetailList[indexPath.row] // TODO: why is this not an optional? -> need to guard with "where" in if-let

            if let networkDetail = speedMeasurementResult?.networkDetailList?[indexPath.row] {

                cell.keyLabel?.text = networkDetail.title
                cell.valueLabel?.text = networkDetail.value

                cell.accessoryType = .none
            }

            return cell

        case 2: // Measurement details

            let cell = tableView.dequeueReusableCell(withIdentifier: "key_value_cell") as! KeyValueTableViewCell

            if indexPath.row == 0 {
                cell.keyLabel?.text = L10n.History.Result.time
                cell.valueLabel?.text = speedMeasurementResult?.timeString

                cell.accessoryType = .none
            } else if indexPath.row == 1 {
                cell.keyLabel?.text = L10n.History.Result.moreDetails
                cell.valueLabel?.text = nil

                cell.accessoryType = .disclosureIndicator
            }

            return cell

        case 3: // QOS results

            let cell = tableView.dequeueReusableCell(withIdentifier: "key_value_cell") as! KeyValueTableViewCell

            if indexPath.row == 0 {
                cell.keyLabel?.text = L10n.History.Result.Qos.results
                cell.valueLabel?.text = qosSuccessPercentageString

                cell.accessoryType = .none
            } else if indexPath.row == 1 {
                cell.keyLabel?.text = L10n.History.Result.Qos.resultsDetail
                cell.valueLabel?.text = nil

                cell.accessoryType = .disclosureIndicator
            }

            return cell

        case 4: // Map
            if speedMeasurementResult?.latitude != nil && speedMeasurementResult?.longitude != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "map_cell") as! MeasurementResultMapTableViewCell

                //cell.coordinateStringLabel?.text = speedMeasurementResult?.location

                /*if let rcas = reverseGeocodeAddressString {
                    cell.coordinateStringLabel?.text = cell.coordinateStringLabel!.text! + "\n" + rcas
                }*/

                cell.staticMapImageView?.image = staticMapImage
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "key_value_cell") as! KeyValueTableViewCell

                cell.keyLabel?.text = ""
                cell.valueLabel?.text = "No coordinates (TODO)" // TODO: localize

                cell.accessoryType = .none

                return cell
            }

        default:
            assert(false, "section \(indexPath.section) is not configured")
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate

///
extension MeasurementResultTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionShouldBeHidden(section) {
            return 0.0
        }

        if section == 0 {
            return 44
        }

        return 35
    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        //case 3: return 44
        case 4:
            if speedMeasurementResult?.latitude != nil && speedMeasurementResult?.longitude != nil {
                return 200
            } else {
                return 44
            }
        default: return 44
        }
    }

    ///
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return
            indexPath.section == 2 && indexPath.row == 1 ||
            indexPath.section == 3 && indexPath.row == 1 ||
            indexPath.section == 4
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            if indexPath.row == 1 { // result details tapped
                if HISTORY_DETAILS_USE_GROUPED_VIEW {
                    perform(segue: StoryboardSegue.History.showResultDetailsGrouped, sender: nil)
                } else {
                    perform(segue: StoryboardSegue.History.showResultDetails, sender: nil)
                }
            }
        case 3: // qos tapped
            if indexPath.row == 1 {
                if QOS_INDEX_USE_COLLECTION_VIEW {
                    perform(segue: StoryboardSegue.History.showQosResultsNew, sender: nil)
                } else {
                    perform(segue: StoryboardSegue.History.showQosResults, sender: nil)
                }
            }
        case 4: // map tapped
            if speedMeasurementResult?.latitude != nil && speedMeasurementResult?.longitude != nil { // prevent map segue if we don't have coordinates
                if fromMap {
                    // we come from global map view -> just go back to map
                    _ = navigationController?.popViewController(animated: true)
                } else {
                    perform(segue: StoryboardSegue.History.showResultOnMap, sender: nil)
                }
            }
        default: break
        }
    }
}
