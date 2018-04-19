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

///
class StaticMap {

    ///
    fileprivate static let staticMapsBaseUrl = "http://maps.googleapis.com/maps/api/staticmap?sensor=false"

    ///
    class func getStaticMapImage(_ lat: Double, lon: Double, width: Int, height: Int, zoom: Int) -> UIImage? {
        if let url = URL(string: "\(staticMapsBaseUrl)&center=\(lat)+\(lon)&zoom=\(zoom)&size=\(width)x\(height)"),
               let data = try? Data(contentsOf: url) {

            return UIImage(data: data)
        }

        return nil
    }

    ///
    class func getStaticMapImageWithCenteredMarker(_ lat: Double, lon: Double, width: Int, height: Int, zoom: Int, markerLabel: String) -> UIImage? {
        if let url = URL(string: "\(staticMapsBaseUrl)&center=\(lat)+\(lon)&zoom=\(zoom)&size=\(width)x\(height)&markers=color:blue%7Clabel:\(markerLabel)%7C\(lat)+\(lon)"),
            let data = try? Data(contentsOf: url) {

            //logger.info("static map from \(url.absoluteString)")

            return UIImage(data: data)
        }

        return nil
    }
}
