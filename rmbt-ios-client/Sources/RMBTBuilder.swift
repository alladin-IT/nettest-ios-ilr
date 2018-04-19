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

///
open class RMBTBuilder {

    ///
    fileprivate let rmbtConfiguration = RMBTConfiguration() // TODO: change to struct?

    ///
    public init() {

    }

    ///
    /*public func setControlServer(host: String = "localhost", port: UInt16 = 8080, tls: Bool = false, path: String = "", apiVersion: Int = 1) -> Self {
        
        return setControlServer(host: host, ipv4OnlyHost: host, ipv6OnlyHost: host, port: port, tls: tls, path: path, apiVersion: apiVersion)
    }*/

    public func setControlServer(host: String = "localhost", ipv4OnlyHost: String = "localhost", ipv6OnlyHost: String = "::1", port: UInt16 = 8080, tls: Bool = false, path: String = "", apiVersion: Int = 1) -> Self {

        // TODO: improve, move default variables
        rmbtConfiguration.controlServerConfiguration.host = host
        rmbtConfiguration.controlServerConfiguration.port = port
        rmbtConfiguration.controlServerConfiguration.tls = tls
        rmbtConfiguration.controlServerConfiguration.path = path
        rmbtConfiguration.controlServerConfiguration.apiVersion = apiVersion

        rmbtConfiguration.controlServerConfiguration.ipv4OnlyHost = ipv4OnlyHost
        rmbtConfiguration.controlServerConfiguration.ipv6OnlyHost = ipv6OnlyHost

        return self
    }

    ///
    public func setMapServer(host: String = "localhost", port: UInt16 = 8081, tls: Bool = false, path: String = "") -> Self {

        // TODO: improve, move default variabled
        rmbtConfiguration.mapServerConfiguration.host = host
        rmbtConfiguration.mapServerConfiguration.port = port
        rmbtConfiguration.mapServerConfiguration.tls = tls
        rmbtConfiguration.mapServerConfiguration.path = path

        return self
    }

    ///
    public func create() -> RMBT {
        return RMBT(rmbtConfiguration: rmbtConfiguration)
    }

}
