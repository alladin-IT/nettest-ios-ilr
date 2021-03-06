/***************************************************************************
 * Copyright 2016 SPECURE GmbH
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
import RealmSwift
import ObjectMapper

///
open class MeasurementHistory {

    ///
    private let controlServer: ControlServer

    ///
    fileprivate let serialQueue = DispatchQueue(label: "at.alladin.tmpquery", attributes: []) // TODO: label

    /// Set dirty to true if the history should be reloaded
    var dirty = true // dirty is true on app start // TODO: set this also after sync

    ///
    init(controlServer: ControlServer) {
        self.controlServer = controlServer

        // TODO: remove realm test code
        // TODO: add migrations? at least look at how they work
        //_ = try? NSFileManager.defaultManager().removeItemAtURL(Realm.Configuration.defaultConfiguration.fileURL!) // delete db before during development

        /*if let realm = try? Realm() {
            let distinctNetworkTypes = Array(Set(realm.objects(StoredHistoryItem.self).valueForKey("networkType") as! [String]))
            let distinctModels = Array(Set(realm.objects(StoredHistoryItem.self).valueForKey("model") as! [String]))

            logger.debug("distinct network types: \(distinctNetworkTypes)")
            logger.debug("distinct models: \(distinctModels)")
            
            logger.debug("COUNT1: \(realm.objects(StoredHistoryItem.self).filter("model IN %@", distinctModels).count)")
            logger.debug("COUNT2: \(realm.objects(StoredHistoryItem.self).filter("model IN %@", [distinctModels.first!]).count)")
            logger.debug("COUNT3: \(realm.objects(StoredHistoryItem.self).filter("model IN %@", [distinctModels.last!]).count)")
        }*/
    }

    open func getHistoryFilterModel() -> [[String: AnyObject]] {
        var distinctNetworkTypes = [String]()
        var distinctModels = [String]()

        if let realm = try? Realm() {
            distinctNetworkTypes = Array(Set(realm.objects(StoredHistoryItem.self).value(forKey: "networkType") as! [String]))
            distinctModels = Array(Set(realm.objects(StoredHistoryItem.self).value(forKey: "model") as! [String]))

            logger.debug("distinct network types: \(distinctNetworkTypes)")
            logger.debug("distinct models: \(distinctModels)")
        }

        return [
            [
                "name": "network_type" as AnyObject,
                "items": distinctNetworkTypes as AnyObject
            ],
            [
                "name": "model" as AnyObject,
                "items": distinctModels as AnyObject
            ]
        ]
    }

    ///
    open func getHistoryList(_ filters: [String: [String]], success: @escaping (_ response: [HistoryItem]) -> (), error failure: @escaping ErrorCallback) {
        if !dirty { // return cached elements if not dirty
            // load items to view
            if let historyItems = self.getHistoryItems(filters) {
                success(historyItems)
            } else {
                failure(NSError(domain: "didnt get history items", code: -12351223, userInfo: nil)) // TODO: call error callback if there were realm problems
            }

            return
        }

        dirty = false

        if let timestamp = getLastHistoryItemTimestamp() {
            logger.debug("timestamp!, requesting since \(timestamp)")

            controlServer.getMeasurementHistory(UInt64(timestamp.timeIntervalSince1970), success: { historyItems in

                let serverUuidList = Set<String>(historyItems.map({ return $0.testUuid! })) // !
                let clientUuidList = Set<String>(self.getHistoryItemUuidList()!) // !

                logger.debug("server: \(serverUuidList)")
                logger.debug("client: \(clientUuidList)")

                let toRemove = clientUuidList.subtracting(serverUuidList)
                let toAdd = serverUuidList.subtracting(clientUuidList)

                logger.debug("to remove: \(toRemove)")
                logger.debug("to add: \(toAdd)")

                // add items
                self.insertOrUpdateHistoryItems(historyItems.filter({ return toAdd.contains($0.testUuid!) })) // !

                // remove items
                self.removeHistoryItems(toRemove)

                // load items to view
                if let historyItems = self.getHistoryItems(filters) {
                    success(historyItems)
                } else {
                    failure(NSError(domain: "didnt get history items", code: -12351223, userInfo: nil)) // TODO: call error callback if there were realm problems
                }

            }, error: { error in // show cached items if this request fails

                // load items to view
                if let historyItems = self.getHistoryItems(filters) {
                    success(historyItems)
                } else {
                    failure(NSError(domain: "didnt get history items", code: -12351223, userInfo: nil)) // TODO: call error callback if there were realm problems
                }
            })
        } else {
            logger.debug("database empty, requesting without timestamp")

            controlServer.getMeasurementHistory({ historyItems in
                self.insertOrUpdateHistoryItems(historyItems)

                if let dbHistoryItems = self.getHistoryItems(filters) {
                    success(dbHistoryItems)
                } else {
                    success(historyItems)
                }

            }, error: failure)
        }
    }

    ///
    open func getMeasurement(_ uuid: String, success: @escaping (_ response: SpeedMeasurementResultResponse) -> (), error failure: @escaping ErrorCallback) {
        if let measurement = getStoredMeasurementData(uuid) {
            success(measurement)
            return
        }

        logger.debug("NEED TO LOAD MEASUREMENT \(uuid) FROM SERVER")

        controlServer.getSpeedMeasurement(uuid, success: { response in

            // store measurement
            self.storeMeasurementData(uuid, measurement: response)

            success(response)
        }, error: failure)
    }

    ///
    open func getMeasurementDetails(_ uuid: String, success: @escaping (_ response: SpeedMeasurementDetailResultResponse) -> (), error failure: @escaping ErrorCallback) {
        if let measurementDetails = getStoredMeasurementDetailsData(uuid) {
            success(measurementDetails)
            return
        }

        logger.debug("NEED TO LOAD MEASUREMENT DETAILS \(uuid) FROM SERVER")

        controlServer.getSpeedMeasurementDetails(uuid, success: { response in

            // store measurement details
            self.storeMeasurementDetailsData(uuid, measurementDetails: response)

            success(response)
        }, error: failure)
    }

    ///
    open func getMeasurementDetailsGrouped(_ uuid: String, success: @escaping (_ response: SpeedMeasurementDetailGroupResultResponse) -> (), error failure: @escaping ErrorCallback) {
        /*if let measurementDetails = getStoredMeasurementDetailsGroupData(uuid) {
            success(measurementDetails)
            return
        }
 
        logger.debug("NEED TO LOAD MEASUREMENT DETAILS GROUPED \(uuid) FROM SERVER")
        
        controlServer.getSpeedMeasurementDetailsGrouped(uuid, success: { response in
            
            // store measurement details grouped
            self.storeMeasurementDetailsGroupedData(uuid, measurementDetails: response)
            
            success(response)
        }, error: failure)*/

        // TODO: add caching for this resource? need database change? how to do that?

        controlServer.getSpeedMeasurementDetailsGrouped(uuid, success: success, error: failure)
    }

    ///
    open func getQosMeasurement(_ uuid: String, success: @escaping (_ response: QosMeasurementResultResponse) -> (), error failure: @escaping ErrorCallback) {
        // Logic is different for qos (because the evaluation can change): load results every time and only return cached result if the request failed

        controlServer.getQosMeasurement(uuid, success: { response in

            logger.debug("NEED TO LOAD MEASUREMENT QOS \(uuid) FROM SERVER (this is done every time since qos evaluation can be changed)")

            // store qos measurement
            self.storeMeasurementQosData(uuid, measurementQos: response)

            success(response)
        }, error: { error in
            if let measurementQos = self.getStoredMeasurementQosData(uuid) {
                success(measurementQos)
                return
            }

            failure(error)
        })
    }

    ///
    open func disassociateMeasurement(_ measurementUuid: String, success: @escaping (_ response: SpeedMeasurementDisassociateResponse) -> (), error failure: @escaping ErrorCallback) {
        controlServer.disassociateMeasurement(measurementUuid, success: { response in
            logger.debug("DISASSOCIATE SUCCESS")

            // remove from db
            self.removeMeasurement(measurementUuid)

            success(response)

        }, error: failure)
    }

// MARK: Get

    ///
    fileprivate func getStoredMeasurementData(_ uuid: String) -> SpeedMeasurementResultResponse? {
        if let storedMeasurement = loadStoredMeasurement(uuid) {
            if let measurementData = storedMeasurement.measurementData, measurementData.count > 0 {
                if let measurement = Mapper<SpeedMeasurementResultResponse>().map(JSONString: measurementData) {
                    logger.debug("RETURNING CACHED MEASUREMENT \(uuid)")
                    return measurement
                }
            }
        }

        return nil
    }

    ///
    fileprivate func getStoredMeasurementDetailsData(_ uuid: String) -> SpeedMeasurementDetailResultResponse? {
        if let storedMeasurement = loadStoredMeasurement(uuid) {
            if let measurementDetailsData = storedMeasurement.measurementDetailsData, measurementDetailsData.count > 0 {
                if let measurementDetails = Mapper<SpeedMeasurementDetailResultResponse>().map(JSONString: measurementDetailsData) {
                    logger.debug("RETURNING CACHED MEASUREMENT DETAILS \(uuid)")
                    return measurementDetails
                }
            }
        }

        return nil
    }

    ///
    fileprivate func getStoredMeasurementQosData(_ uuid: String) -> QosMeasurementResultResponse? {
        if let storedMeasurement = loadStoredMeasurement(uuid) {
            if let measurementQosData = storedMeasurement.measurementQosData, measurementQosData.count > 0 {
                if let measurementQos = Mapper<QosMeasurementResultResponse>().map(JSONString: measurementQosData) {
                    logger.debug("RETURNING CACHED QOS RESULT \(uuid)")
                    return measurementQos
                }
            }
        }

        return nil
    }

// MARK: Save

    ///
    fileprivate func storeMeasurementData(_ uuid: String, measurement: SpeedMeasurementResultResponse) { // TODO: store google map static image in db?
        (serialQueue).async {
            self.updateStoredMeasurement(uuid) { storedMeasurement in
                storedMeasurement.measurementData = Mapper<SpeedMeasurementResultResponse>().toJSONString(measurement)
            }
        }
    }

    ///
    fileprivate func storeMeasurementDetailsData(_ uuid: String, measurementDetails: SpeedMeasurementDetailResultResponse) {
        (serialQueue).async {
            self.updateStoredMeasurement(uuid) { storedMeasurement in
                storedMeasurement.measurementDetailsData = Mapper<SpeedMeasurementDetailResultResponse>().toJSONString(measurementDetails)
            }
        }
    }

    ///
    fileprivate func storeMeasurementQosData(_ uuid: String, measurementQos: QosMeasurementResultResponse) {
        (serialQueue).async {
            self.updateStoredMeasurement(uuid) { storedMeasurement in
                storedMeasurement.measurementQosData = Mapper<QosMeasurementResultResponse>().toJSONString(measurementQos)
            }
        }
    }

    ///
    fileprivate func loadStoredMeasurement(_ uuid: String) -> StoredMeasurement? {
        if let realm = try? Realm() {
            return realm.objects(StoredMeasurement.self).filter("uuid == %@", uuid).first
        }

        return nil
    }

    ///
    fileprivate func loadOrCreateStoredMeasurement(_ uuid: String) -> StoredMeasurement {
        if let storedMeasurement = loadStoredMeasurement(uuid) {
            return storedMeasurement
        }

        let storedMeasurement = StoredMeasurement()
        storedMeasurement.uuid = uuid

        return storedMeasurement
    }

    ///
    fileprivate func updateStoredMeasurement(_ uuid: String, updateBlock: (_ storedMeasurement: StoredMeasurement) -> ()) {
        if let realm = try? Realm() {
            do {
                try realm.write {
                    let storedMeasurement = self.loadOrCreateStoredMeasurement(uuid)

                    updateBlock(storedMeasurement)

                    realm.add(storedMeasurement)
                }
            } catch {
                logger.debug("realm error \(error)") // do nothing if fails?
            }
        }
    }

    ///
    fileprivate func removeMeasurement(_ uuid: String) {
        if let realm = try? Realm() {
            do {
                try realm.write {
                    if let storedMeasurement = loadStoredMeasurement(uuid) {
                        realm.delete(storedMeasurement)
                    }

                    // remove also history item:
                    if let storedHistoryItem = loadStoredHistoryItem(uuid) {
                        realm.delete(storedHistoryItem)
                    }
                }
            } catch {
                logger.debug("realm error \(error)") // do nothing if fails?
            }
        }
    }

// MARK: HistoryItem

    ///
    fileprivate func loadStoredHistoryItem(_ uuid: String) -> StoredHistoryItem? {
        if let realm = try? Realm() {
            return realm.objects(StoredHistoryItem.self).filter("uuid == %@", uuid).first
        }

        return nil
    }

    ///
    fileprivate func getLastHistoryItemTimestamp() -> Date? {
        if let realm = try? Realm() {
            return realm.objects(StoredHistoryItem.self).max(ofProperty: "timestamp")
        }

        return nil
    }

    ///
    fileprivate func getHistoryItems(_ filters: [String: [String]]) -> [HistoryItem]? {
        if let realm = try? Realm() {
            var query = realm.objects(StoredHistoryItem.self)

            if !filters.isEmpty {
                for (filterColumn, filterEntries) in filters {
                    query = query.filter("\(filterColumn) IN %@", filterEntries)
                }
            }

            query = query.sorted(byKeyPath: "timestamp", ascending: false)

            return query.flatMap({ storedItem in
                logger.debug("\(String(describing: storedItem.model))")
                logger.debug("\(String(describing: storedItem.networkType))")

                return Mapper<HistoryItem>().map(JSONString: storedItem.jsonData!) // TODO: !
            })
        }

        return nil
    }

    ///
    fileprivate func getHistoryItemUuidList() -> [String]? {
        if let realm = try? Realm() {
            let uuidList = realm.objects(StoredHistoryItem.self).map({ storedItem in
                return storedItem.uuid! // !
            })

            return [String](uuidList)
        }

        return nil
    }

    ///
    fileprivate func insertOrUpdateHistoryItems(_ historyItems: [HistoryItem]) { // TODO: preload measurement, details and qos?
        if let realm = try? Realm() {
            do {
                try realm.write {
                    var storedHistoryItemList = [StoredHistoryItem]()

                    historyItems.forEach({ item in
                        //logger.debug("try to save history item: \(item)")

                        let storedHistoryItem = StoredHistoryItem()
                        storedHistoryItem.uuid = item.testUuid

                        storedHistoryItem.networkType = item.networkType
                        storedHistoryItem.model = item.model

                        if let time = item.time {
                            storedHistoryItem.timestamp = Date(timeIntervalSince1970: Double(time))
                        }

                        storedHistoryItem.jsonData = Mapper<HistoryItem>().toJSONString(item)

                        storedHistoryItemList.append(storedHistoryItem)
                    })

                    logger.debug("storing \(storedHistoryItemList)")

                    realm.add(storedHistoryItemList)
                }
            } catch {
                logger.debug("realm error \(error)") // do nothing if fails?
            }
        }
    }

    ///
    fileprivate func removeHistoryItems(_ historyItemUuidList: Set<String>) {
        if let realm = try? Realm() {
            do {
                try realm.write {
                    realm.delete(realm.objects(StoredHistoryItem.self).filter("uuid IN %@", historyItemUuidList))
                }
            } catch {
                logger.debug("realm error \(error)") // do nothing if fails?
            }
        }
    }

}
