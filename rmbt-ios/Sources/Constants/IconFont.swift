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
protocol IconFontType: RawRepresentable {

}

///
extension UILabel {

    ///
    var icon: IconFont? {
        get {
            if let t = text {
                return IconFont(rawValue: t)
            }

            return nil
        }
        set {
            text = newValue?.rawValue
        }
    }
}

///
extension UIButton {

    ///
    func setIcon(_ icon: IconFont, for state: UIControlState) {
        setTitle(icon.rawValue, for: state)
    }
}

///
extension UIBarButtonItem {

    ///
    var icon: IconFont? {
        get {
            if let t = title {
                return IconFont(rawValue: t)
            }

            return nil
        }
        set {
            title = newValue?.rawValue
        }
    }
}

///
enum IconFont: String, IconFontType {
    case logo = "a"
    case watch = "b"
    case frequency = "c"
    case system = "d"
    case grid = "e"
    case company = "f"
    case device = "g"
    case start = "h"
    case history = "i"
    case map = "j"
    case search = "k"
    case statistics = "l"
    case help = "m"
    case opendata = "n"
    case about = "o"
    case settings = "p"
    case ping = "q"
    case down = "r"
    case up = "s"
    case cellular = "t"
    case wifi = "u"
    case check = "v"
    case cross = "w"
    case location = "x"
    case movie = "y"
    case package = "z"
    case language = "ß"
    case voip = "à"
    case dns = "á"
    case arrowAverage = "ä"
    case webRendering = "è"
    case httpProxy = "é"
    case qos = "ë"
    case udp = "ì"
    case nonTransparent = "í"
    case network = "ï"
    case adjustment = "ò"
    case tcp = "ó"
    case arrowDown = "ö"
    case filter = "ù"
    case traceroute = "ú"
    case arrowUp = "ü"
    case logoInverse = "A"
    case watchInverse = "B"
    case heart = "C"
    case shopping = "D"
    case audio = "E"
    case menu = "F"
    case gaming = "G"
    case vr = "H"
    case trafficIn = "I"
    case trafficOut = "J"
    case barrow = "K"
    case feather = "L"
    case owl = "M"
    case trophy = "N"
    case hourglass = "O"
    case heatmap = "P"
    case documents = "Q"
    case /*compass*/outdoor = "R"
    case /*armchair*/indoor = "S"
    case notebook = "T"
    
    case menuHome = "!"
    case menuInfo = "#"
    case menuMap = "$"
    case menuSearch = "%"
    case menuStatistic = "&"
    case menuHelp = "*"
    case menuOpendata = "+"
    case menuSettings = "-"
    case menuLanguage = "_"
    case menuHistory = "§"
    
    
    ///
    func repeating(_ count: Int) -> String {
        return String(repeating: self.rawValue, count: count)
    }

    ///
    static func forQosMeasurementType(type: QOSMeasurementType) -> IconFont {
        switch type {
        case .HttpProxy:
            return .httpProxy
        case .NonTransparentProxy:
            return .nonTransparent
        case .WEBSITE:
            return .webRendering
        case .DNS:
            return .dns
        case .TCP:
            return .tcp
        case .UDP:
            return .udp
        case .VOIP:
            return .voip
        case .TRACEROUTE:
            return .traceroute
        //default:
        //    return .qos
        }
    }
}
