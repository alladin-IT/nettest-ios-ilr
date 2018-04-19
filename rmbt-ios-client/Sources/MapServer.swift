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
import CoreLocation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

///
open class MapServer {

    ///
    private let configuration: MapServerConfiguration
    private let controlServer: ControlServer

    ///
    private let alamofireManager: Alamofire.SessionManager

    ///
    private let settings = RMBTSettings.sharedSettings

    ///
    private var baseUrl: String?

    ///
    init(configuration: MapServerConfiguration, controlServer: ControlServer) {
        self.configuration = configuration
        self.controlServer = controlServer

        baseUrl = configuration.baseUrl() // TODO

        alamofireManager = ServerHelper.configureAlamofireManager()
    }

    ///
    deinit {
        alamofireManager.session.invalidateAndCancel()
    }

// MARK: MapServer

    ///
    open func getMapOptions(success successCallback: @escaping (_ response: /*MapOptionResponse*/RMBTMapOptions) -> (), error failure: @escaping ErrorCallback) {

        request(.post, path: "/tiles/info", requestObject: BasicRequest(), success: { (response: MapOptionResponse) in
            // TODO: rewrite MapViewController to use new objects
            let mapOptions = RMBTMapOptions(response: response.toJSON() as NSDictionary) // TODO: rewrite to use swift classes
            successCallback(mapOptions)

        }, error: failure)
    }

    ///
    open func getMeasurementsAtCoordinate(_ coordinate: CLLocationCoordinate2D, zoom: Int, params: [String: [String: AnyObject]], success successCallback: @escaping (_ response: [SpeedMeasurementResultResponse]) -> (), error failure: @escaping ErrorCallback) {

        let mapMeasurementRequest = MapMeasurementRequest()
        mapMeasurementRequest.coords = MapMeasurementRequest.CoordObject()
        mapMeasurementRequest.coords?.latitude = coordinate.latitude
        mapMeasurementRequest.coords?.longitude = coordinate.longitude
        mapMeasurementRequest.coords?.zoom = zoom

        mapMeasurementRequest.options = params["options"]
        mapMeasurementRequest.filter = params["filter"]

        if let clientUuid = controlServer.uuid as? AnyObject {
            mapMeasurementRequest.filter?["prioritize"] = clientUuid
            mapMeasurementRequest.filter?["highlight"] = clientUuid
        }
        
        // add highlight filter (my measurements filter) // TODO: this is now client_uuid!
        // submit client_uuid to get measurement_uuid if tapped on an own measurement
        //mapMeasurementRequest.clientUuid = controlServer.uuid
        //mapMeasurementRequest.filter?["highlight"] = ControlServer.sharedControlServer.uuid

        request(.post, path: "/tiles/markers", requestObject: mapMeasurementRequest, success: { (response: MapMeasurementResponse) in
            if let measurements = response.measurements {
                successCallback(measurements)
            } else {
                failure(NSError(domain: "no measurements", code: -12543, userInfo: nil))
            }
        }, error: failure)
    }

    ///
    open func getTileUrlForMapOverlayType(_ overlayType: String, x: UInt, y: UInt, zoom: UInt, params: NSMutableDictionary?) -> URL? {
        if let base = baseUrl {
            // baseUrl and layer
            var urlString = base + "/tiles/\(overlayType)?path=\(zoom)/\(x)/\(y)"

            // add uuid for highlight
            if let uuid = controlServer.uuid {
                urlString += "&highlight_uuid=\(uuid)&highlight=\(uuid)" // TODO: remove "highlight" later, is only here for old servers
            }

            logger.debug("\(String(describing: params))")

            // add params
            if let p = params as? [String: AnyObject], p.count > 0 {
                let paramString = p.map({ (key, value) in
                    let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                    var escapedValue: String = ""
                    if let v = value as? String {
                        if let t = v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) { // TODO: does this need a cast to string?
                            escapedValue = t
                        }
                    } else if let v = value as? NSNumber {
                        escapedValue = v.stringValue
                    } else {
                        // TODO: ?
                    }

                    return "\(escapedKey ?? key)=\(escapedValue)"
                }).joined(separator: "&")

                urlString += "&" + paramString
            }

            logger.debug("Generated tile url: \(urlString)")

            return URL(string: urlString)
        }

        return nil
    }

    ///
    open func getOpenTestUrl(_ openTestUuid: String, success successCallback: (_ response: String?) -> ()) {
        if let opendataPrefix = controlServer.opendataPrefix {
            successCallback("\(opendataPrefix)/\(openTestUuid)/details")
        } else {
            successCallback(nil)
        }
    }

// MARK: Private

//    ///
//    fileprivate func opentestURLForApp(_ openTestBaseURL: String) -> String {
//        // hardcoded because @lb doesn't want to provide a good solution
//
//        //let r = openTestBaseURL.characters.indices
//        
//        let appOpenTestBaseURL = openTestBaseURL.replacingOccurrences(of: "/opentest", with: "/app/opentest", options: String.CompareOptions.literal, range: openTestBaseURL.startIndex..<openTestBaseURL.endIndex) // TODO: is this correct?
//        //let appOpenTestBaseURL = openTestBaseURL.replacingOccurrences(of: "/opentest", with: "/app/opentest", options: NSString.CompareOptions.literal, range: r)
//
//        return appOpenTestBaseURL
//    }

    ///
    fileprivate func requestArray<T: BasicResponse>(_ method: Alamofire.HTTPMethod, path: String, requestObject: BasicRequest?, success: @escaping (_ response: [T]) -> (), error failure: @escaping ErrorCallback) {
        ServerHelper.requestArray(alamofireManager, baseUrl: baseUrl, method: method, path: path, requestObject: requestObject, success: success, error: failure)
    }

    ///
    fileprivate func request<T: BasicResponse>(_ method: Alamofire.HTTPMethod, path: String, requestObject: BasicRequest?, success: @escaping (_ response: T) -> (), error failure: @escaping ErrorCallback) {
        ServerHelper.request(alamofireManager, baseUrl: baseUrl, method: method, path: path, requestObject: requestObject, success: success, error: failure)
    }
}
