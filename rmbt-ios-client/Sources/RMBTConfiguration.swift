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
class RMBTConfiguration {

    ///
    let controlServerConfiguration = ControlServerConfiguration()

    ///
    let mapServerConfiguration = MapServerConfiguration()

    ///
    init() {

    }

}

class ServerConfiguration {

    var host: String = "localhost"
    var port: UInt16 = 8080
    var tls = false
    var path: String = ""

    var ipv4OnlyHost = "localhost"
    var ipv6OnlyHost = "::1"

    fileprivate init() {

    }

    func host(_ host: String) -> Self {
        self.host = host
        return self
    }

    func port(_ port: UInt16) -> Self {
        self.port = port
        return self
    }

    func tls(_ tls: Bool) -> Self {
        self.tls = tls
        return self
    }

    func path(_ path: String) -> Self {
        self.path = path
        return self
    }

    func ipv4OnlyHost(_ ipv4Host: String) -> Self {
        self.ipv4OnlyHost = ipv4Host
        return self
    }

    func ipv6OnlyHost(_ ipv6Host: String) -> Self {
        self.ipv6OnlyHost = ipv6Host
        return self
    }

    func baseUrl() -> String? {
        return baseUrl(host: host)
    }

    func ipv4BaseUrl() -> String? {
        return baseUrl(host: ipv4OnlyHost)
    }

    func ipv6BaseUrl() -> String? {
        return baseUrl(host: ipv6OnlyHost)
    }

    fileprivate func baseUrl(host h: String) -> String? {
        var urlComponents = URLComponents()

        urlComponents.host = h
        urlComponents.port = Int(port)
        urlComponents.scheme = tls ? "https" : "http"
        urlComponents.path = path

        return urlComponents.string
    }
}

class ControlServerConfiguration: ServerConfiguration {

    var apiVersion = 1

    func apiVersion(_ apiVersion: Int) -> Self {
        self.apiVersion = apiVersion
        return self
    }

    override fileprivate func baseUrl(host h: String) -> String? {
        var urlComponents = URLComponents()

        urlComponents.host = h
        urlComponents.port = Int(port)
        urlComponents.scheme = tls ? "https" : "http"

        let apiVersionPath = "/api/v\(apiVersion)"
        urlComponents.path = path + apiVersionPath

        return urlComponents.string
    }
}

class MapServerConfiguration: ServerConfiguration {

}

// TODO
public class RMBTClientConfiguration {
    public var RMBT_TEST_SOCKET_TIMEOUT_S = 30.0

    /// Maximum number of tests to perform in loop mode
    public var RMBT_TEST_LOOPMODE_LIMIT = 100

    ///
    public var RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S = 5

    ///
    public var RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST = 4

    ///
    public var RMBT_TEST_PRETEST_DURATION_S = 2.0

    ///
    public var RMBT_TEST_PING_COUNT = 10

    /// In case of slow upload, we finalize the test even if this many seconds still haven't been received:
    public var RMBT_TEST_UPLOAD_MAX_DISCARD_S = 1.0

    /// Minimum number of seconds to wait after sending last chunk, before starting to discard.
    public var RMBT_TEST_UPLOAD_MIN_WAIT_S    = 0.25

    /// Maximum number of seconds to wait for server reports after last chunk has been sent.
    /// After this interval we will close the socket and finish the test on first report received.
    public var RMBT_TEST_UPLOAD_MAX_WAIT_S    = 3

    /// Measure and submit speed during test in these intervals
    public var RMBT_TEST_SAMPLING_RESOLUTION_MS = 250

    public init() {

    }
}
