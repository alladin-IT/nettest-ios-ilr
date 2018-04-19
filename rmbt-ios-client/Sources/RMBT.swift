/***************************************************************************
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

///
open class RMBT {

    ///
    let rmbtConfiguration: RMBTConfiguration

    //////////////////

    ///
    let controlServer: ControlServer

    ///
    public let mapServer: MapServer

    ///
    public let measurementHistory: MeasurementHistory

    ///
    init(rmbtConfiguration: RMBTConfiguration) {
        self.rmbtConfiguration = rmbtConfiguration

        controlServer = ControlServer(configuration: rmbtConfiguration.controlServerConfiguration)
        mapServer = MapServer(configuration: rmbtConfiguration.mapServerConfiguration, controlServer: controlServer)
        // TODO: map server url can change, control server settings contain urls for map server
        // TODO: or just always use the values from the control server settings?

        measurementHistory = MeasurementHistory(controlServer: controlServer)
    }

    //////////////////

    public var uuid: String? {
        return controlServer.uuid
    }

    public var controlServerVersion: String? {
        return controlServer.version
    }

    public func refreshSettings(_ callback: (() -> ())?/*success successCallback: () -> (), error: (_ error: NSError) -> ()*/) {
        measurementHistory.dirty = true
        controlServer.updateWithCurrentSettings(callback)
    }

    ////////////////////

    /// Creates a new RMBTClient with custom configuration
    public func newClient(rmbtClientConfiguration: RMBTClientConfiguration) -> RMBTClient {
        return RMBTClient(configuration: rmbtClientConfiguration, rmbt: self, controlServer: controlServer)
    }

    /// Creates a new RMBTClient with default configuration
    public func newClient() -> RMBTClient {
        return newClient(rmbtClientConfiguration: RMBTClientConfiguration())
    }

    //////

    ///
    public func newConnectivityService() -> ConnectivityService {
        return ConnectivityService(controlServer: controlServer)
    }
}
