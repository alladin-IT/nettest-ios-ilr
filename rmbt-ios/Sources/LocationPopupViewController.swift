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
import CoreLocation
import RMBTClient

///
class LocationPopupViewController: PopupTableViewController {

    ///
    let locationManager = CLLocationManager()

    ///
    var location = CLLocation()

    ///
    var age = 0

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        headline = L10n.Intro.Popup.location

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.distanceFilter = 3.0
        locationManager.startUpdatingLocation()

        resetData()
        update()
    }

    ///
    override func update() {
        age += 1

        data?[2][1] = "\(age) s"

        super.update()
    }

    ///
    override func stop() {
        locationManager.stopUpdatingLocation()
    }

    func resetData() {
        data = [
            [L10n.Intro.Popup.Location.position, "-"],
            [L10n.Intro.Popup.Location.accuracy, "-"],
            [L10n.Intro.Popup.Location.age, "-"],
            [L10n.Intro.Popup.Location.altitude, "-"]
            //[L10n.Intro.Popup.Location.bearing, "-"]
            // speed
        ]
    }
}

///
extension LocationPopupViewController: CLLocationManagerDelegate {

    ///
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[0]

        age = 0

        let formattedArray = location.rmbtFormattedArray()

        data = [
            [L10n.Intro.Popup.Location.position, formattedArray[0]],
            [L10n.Intro.Popup.Location.accuracy, formattedArray[1]],
            [L10n.Intro.Popup.Location.age, "\(age) s"],
            [L10n.Intro.Popup.Location.altitude, formattedArray[3]]
            //[L10n.Intro.Popup.Location.bearing, location.course]
            // speed
        ]
    }

    ///
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resetData()
    }
}
