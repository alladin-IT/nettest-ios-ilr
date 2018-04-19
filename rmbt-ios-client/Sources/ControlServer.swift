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
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

///
public typealias EmptyCallback = () -> ()

///
public typealias ErrorCallback = (_ error: NSError) -> ()

///
public typealias IpResponseSuccessCallback = (_ ipResponse: IpResponse) -> ()

///
class ControlServer {

    private let configuration: ControlServerConfiguration

    ///
    fileprivate let alamofireManager: Alamofire.SessionManager

    ///
    fileprivate let settings = RMBTSettings.sharedSettings

    ///
    fileprivate var uuidQueue = DispatchQueue(label: "at.alladin.nettest.uuid_queue", attributes: [])

    ///
    var version: String?

    ///
    var uuid: String?

    ///
    fileprivate var uuidKey: String? // TODO: unique for each control server?

    ///
    var baseUrl = ""

    ///
    fileprivate var defaultBaseUrl: String?

    // TODO: HTTP/2, NGINX, IOS PROBLEM! http://stackoverflow.com/questions/36907767/nsurlerrordomain-code-1004-for-few-seconds-after-app-start-up

    //

    ///
    var opendataPrefix: String?
    
    ///
    init(configuration: ControlServerConfiguration) {
        self.configuration = configuration

        alamofireManager = ServerHelper.configureAlamofireManager()

        if let controlServerBaseUrlArgument = UserDefaults.standard.string(forKey: "controlServerBaseUrl") {
            defaultBaseUrl = controlServerBaseUrlArgument + configuration.path // TODO: !, better config
            logger.debug("Using control server base url from arguments: \(String(describing: self.defaultBaseUrl))")
        }// else if let b = configuration.baseUrl() {
        //    defaultBaseUrl = b
        //}
    }

    ///
    deinit {
        alamofireManager.session.invalidateAndCancel()
    }

    ///
    func updateWithCurrentSettings(_ callback: (() -> ())?) { // TODO: how does app set the control server url? need param?
        // configure control server url

        baseUrl = defaultBaseUrl != nil ? defaultBaseUrl! : configuration.baseUrl()! // TODO: !, better config
        uuidKey = "uuid_\(String(describing: URL(string: baseUrl)!.host))" // !

        // check for ip version force
        //if settings.nerdModeForceIPv6 {
        //    baseUrl = configuration.ipv6BaseUrl()!
        /*} else*/ if settings.nerdModeForceIPv4 {
            baseUrl = configuration.ipv4BaseUrl()!
        }

        if settings.debugUnlocked {
            // check for custom control server
            if settings.debugControlServerCustomizationEnabled {
                let scheme = settings.debugControlServerUseSSL ? "https" : "http"
                var hostname = settings.debugControlServerHostname

                if settings.debugControlServerPort != 0 && settings.debugControlServerPort != 80 {
                    hostname = "\(String(describing: hostname)):\(settings.debugControlServerPort)"
                }

                var urlComponents = URLComponents()
                urlComponents.scheme = scheme
                urlComponents.host = hostname
                urlComponents.path = "/api/v1" /*RMBT_CONTROL_SERVER_PATH*/

                if let url = urlComponents.url {
                    baseUrl = url.absoluteString // !
                    uuidKey = "uuid_\(String(describing: url.host))"
                }
            }
        }

        logger.info("Control Server base url = \(self.baseUrl)")

        // TODO: determine map server url!

        //

        // load uuid
        if let key = uuidKey {
            uuid = UserDefaults.standard.object(forKey: key) as? String

            logger.debugExec({
                if let uuid = self.uuid {
                    logger.debug("UUID: Found uuid \"\(uuid)\" in user defaults for key '\(key)'")
                } else {
                    logger.debug("UUID: Uuid was not found in user defaults for key '\(key)'")
                }
            })
        }

        // get settings of control server
        getSettings(success: {
            // do nothing
            callback?()
        }) { (error) in
            // TODO: error handling?
            callback?()
        }
    }

// MARK: Settings

    ///
    func getSettings(success successCallback: @escaping EmptyCallback, error failure: @escaping ErrorCallback) {
        let settingsRequest = SettingsRequest()

        settingsRequest.client = ClientSettings()
        settingsRequest.client?.clientType = "MOBILE"
        settingsRequest.client?.termsAndConditionsAccepted = true
        settingsRequest.client?.uuid = uuid

        let successFunc: (_ response: SettingsReponse) -> () = { response in
            logger.debug("settings: \(String(describing: response.client))")

            // set uuid
            self.uuid = response.client?.uuid

            // save uuid
            if let uuidKey = self.uuidKey {
                UserDefaults.standard.set(self.uuid, forKey: uuidKey)
                UserDefaults.standard.synchronize()
            }

            logger.debug("UUID: uuid is now: \(String(describing: self.uuid)) for key '\(String(describing: self.uuidKey))'")

            // set control server version
            self.version = response.settings?.versions?.controlServerVersion

            // set qos test type desc
            response.qosMeasurementTypes?.forEach({ measurementType in
                if let type = measurementType.type {
                    QOSMeasurementType.localizedNameDict[type] = measurementType.name
                }
            })

            // TODO: set history filters
            // TODO: set ip request urls, set openTestBaseUrl
            // TODO: set map server url
            
            // set advancedPosition items
            RMBTSettings.sharedSettings.advancedPositionValues = nil
            if let e = response.advancedPosition?.enabled, e {
                if let options = response.advancedPosition?.options, options.count > 0 {
                    var positionValues = [[String]]()
                    
                    options.forEach({ (option) in
                        if let title = option.title, let value = option.value {
                            positionValues.append([title, value])
                        }
                    })
                    
                    RMBTSettings.sharedSettings.advancedPositionValues = positionValues
                }
            }
            logger.debug("ADV_POS: \(String(describing: RMBTSettings.sharedSettings.advancedPositionValues))")

            self.opendataPrefix = response.settings?.urls?.opendataPrefix

            successCallback()
        }

        request(.post, path: "/settings", requestObject: settingsRequest, success: successFunc, error: { error in
            logger.debug("settings error")

            logger.debug(error)
            
            // TODO
            failure(error)
        })
    }

// MARK: IP

    ///
    func getIpv4(success successCallback: @escaping IpResponseSuccessCallback, error failure: @escaping ErrorCallback) {
        if let ipv4bu = configuration.ipv4BaseUrl() {
            getIpVersion(ipv4bu, success: successCallback, error: failure)
        } else {
            failure(NSError(domain: "control-server", code: -2345, userInfo: nil)) // TODO
        }
    }

    ///
    func getIpv6(success successCallback: @escaping IpResponseSuccessCallback, error failure: @escaping ErrorCallback) {
        if let ipv6bu = configuration.ipv6BaseUrl() {
            getIpVersion(ipv6bu, success: successCallback, error: failure)
        } else {
            failure(NSError(domain: "control-server", code: -2346, userInfo: nil)) // TODO
        }
    }

    ///
    func getIpVersion(_ customBaseUrl: String, success successCallback: @escaping IpResponseSuccessCallback, error failure: @escaping ErrorCallback) {
        request(.post, customBaseUrl: customBaseUrl, path: "/ip", requestObject: BasicRequest(), success: successCallback, error: failure)
    }

// MARK: Speed measurement

    ///
    func requestSpeedMeasurement(_ speedMeasurementRequest: SpeedMeasurementRequest, success: @escaping (_ response: SpeedMeasurementResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { uuid in
            let settings = RMBTSettings.sharedSettings
            
            speedMeasurementRequest.uuid = uuid
            speedMeasurementRequest.anonymous = settings.anonymousModeEnabled

            logger.debugExec {
                if speedMeasurementRequest.anonymous {
                    logger.debug("CLIENT IS ANONYMOUS!")
                }
            }
            
            // only add client config object if there is everything /*something*/ set
            //if settings.clientContractContractName != nil || settings.clientContractDownloadKbps > 0 || settings.clientContractUploadKbps > 0 {
            if settings.clientContractContractName != nil && settings.clientContractDownloadKbps > 0 && settings.clientContractUploadKbps > 0 {
                let cci = SpeedMeasurementRequest.ClientContractInformation()
                
                cci.contractName = settings.clientContractContractName
                
                //if settings.clientContractDownloadKbps > 0 {
                    cci.downloadKbps = settings.clientContractDownloadKbps
                //}
                
                //if settings.clientContractUploadKbps > 0 {
                    cci.uploadKbps = settings.clientContractUploadKbps
                //}
                
                speedMeasurementRequest.clientContractInformation = cci
            }
            
            // set position (indoor, outdoor, etc.)
            logger.debug("SETTING ADVANCED POSITION TO \(String(describing: settings.position))")
            speedMeasurementRequest.position = settings.position

            self.request(.post, path: "/measurements/speed", requestObject: speedMeasurementRequest, success: success, error: failure)
        }, error: failure)
    }

    ///
    func submitSpeedMeasurementResult(_ speedMeasurementResult: SpeedMeasurementResult, success: @escaping (_ response: SpeedMeasurementSubmitResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { uuid in
            if let measurementUuid = speedMeasurementResult.uuid {
                speedMeasurementResult.clientUuid = uuid

                self.request(.put, path: "/measurements/speed/\(measurementUuid)", requestObject: speedMeasurementResult, success: success, error: failure)
            } else {
                failure(NSError(domain: "controlServer", code: 134534, userInfo: nil)) // give error if no uuid was provided by caller
            }
        }, error: failure)
    }

    ///
    func getSpeedMeasurement(_ uuid: String, success: @escaping (_ response: SpeedMeasurementResultResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { _ in
            self.request(.get, path: "/measurements/speed/\(uuid)?lang=\(RMBTPreferredLanguage())", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

    ///
    func getSpeedMeasurementDetails(_ uuid: String, success: @escaping (_ response: SpeedMeasurementDetailResultResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { _ in
            self.request(.get, path: "/measurements/speed/\(uuid)/details?lang=\(RMBTPreferredLanguage())", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

    ///
    func getSpeedMeasurementDetailsGrouped(_ uuid: String, success: @escaping (_ response: SpeedMeasurementDetailGroupResultResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { _ in
            self.request(.get, path: "/measurements/speed/\(uuid)/details?grouped=true&lang=\(RMBTPreferredLanguage())", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

    ///
    func disassociateMeasurement(_ measurementUuid: String, success: @escaping (_ response: SpeedMeasurementDisassociateResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { clientUuid in
            self.request(.delete, path: "/clients/\(clientUuid)/measurements/\(measurementUuid)", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

// MARK: Qos measurements

    ///
    func requestQosMeasurement(_ measurementUuid: String?, success: @escaping (_ response: QosMeasurmentResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { uuid in
            let qosMeasurementRequest = QosMeasurementRequest()

            qosMeasurementRequest.clientUuid = uuid
            qosMeasurementRequest.measurementUuid = measurementUuid

            self.request(.post, path: "/measurements/qos", requestObject: qosMeasurementRequest, success: success, error: failure)
        }, error: failure)
    }

    ///
    func submitQosMeasurementResult(_ qosMeasurementResult: QosMeasurementResultRequest, success: @escaping (_ response: QosMeasurementSubmitResponse) -> (), error failure: @escaping ErrorCallback) {
        
        // don't submit while testing
        //exit(1)
        
        ensureClientUuid(success: { uuid in
            if let measurementUuid = qosMeasurementResult.measurementUuid {
                qosMeasurementResult.clientUuid = uuid

                self.request(.put, path: "/measurements/qos/\(measurementUuid)", requestObject: qosMeasurementResult, success: success, error: failure)
            } else {
                failure(NSError(domain: "controlServer", code: 134535, userInfo: nil)) // TODO: give error if no measurement uuid was provided by caller
            }
        }, error: failure)
    }

    ///
    func getQosMeasurement(_ uuid: String, success: @escaping (_ response: QosMeasurementResultResponse) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { _ in
            self.request(.get, path: "/measurements/qos/\(uuid)", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

// MARK: History

    ///
    func getMeasurementHistory(_ success: @escaping (_ response: [HistoryItem]) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { uuid in
            self.requestArray(.get, path: "/clients/\(uuid)/measurements?lang=\(RMBTPreferredLanguage())", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

    ///
    func getMeasurementHistory(_ timestamp: UInt64, success: @escaping (_ response: [HistoryItem]) -> (), error failure: @escaping ErrorCallback) {
        ensureClientUuid(success: { uuid in
            self.requestArray(.get, path: "/clients/\(uuid)/measurements?timestamp=\(timestamp)&lang=\(RMBTPreferredLanguage())", requestObject: nil, success: success, error: failure)
        }, error: failure)
    }

// MARK: Private

    ///
    fileprivate func ensureClientUuid(success successCallback: @escaping (_ uuid: String) -> (), error errorCallback: @escaping ErrorCallback) {
        uuidQueue.async {
            if let uuid = self.uuid {
                successCallback(uuid)
            } else {
                self.uuidQueue.suspend()

                self.getSettings(success: {
                    self.uuidQueue.resume()

                    if let uuid = self.uuid {
                        successCallback(uuid)
                    } else {
                        errorCallback(NSError(domain: "strange error, should never happen, should have uuid by now", code: -1234345, userInfo: nil))
                    }
                }, error: { error in
                    self.uuidQueue.resume()
                    errorCallback(error)
                })
            }
        }
    }

    ///
    fileprivate func requestArray<T: BasicResponse>(_ method: Alamofire.HTTPMethod, path: String, requestObject: BasicRequest?, success: @escaping (_ response: [T]) -> (), error failure: @escaping ErrorCallback) {
        ServerHelper.requestArray(alamofireManager, baseUrl: baseUrl, method: method, path: path, requestObject: requestObject, success: success, error: failure)
    }

    ///
    fileprivate func request<T: BasicResponse>(_ method: Alamofire.HTTPMethod, path: String, requestObject: BasicRequest?, success: @escaping (_ response: T) -> (), error failure: @escaping ErrorCallback) {
        ServerHelper.request(alamofireManager, baseUrl: baseUrl, method: method, path: path, requestObject: requestObject, success: success, error: failure)
    }

    ///
    fileprivate func request<T: BasicResponse>(_ method: Alamofire.HTTPMethod, customBaseUrl: String, path: String, requestObject: BasicRequest?, success: @escaping (_ response: T) -> (), error failure: @escaping ErrorCallback) {
        ServerHelper.request(alamofireManager, baseUrl: customBaseUrl, method: method, path: path, requestObject: requestObject, success: success, error: failure)
    }
}
