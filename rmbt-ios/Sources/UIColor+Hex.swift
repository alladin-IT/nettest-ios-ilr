/***************************************************************************
 * Copyright 2013 appscape gmbh
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
extension UIColor {

    ///
    var rgbaValue: String {
        let rgbaComponents = self.rgbaComponents()
        return String(format: "#%02lX%02lX%02lX%02lX", rgbaComponents[0], rgbaComponents[1], rgbaComponents[2], rgbaComponents[3])
    }

    ///
    var rgbValue: String {
        let rgbaComponents = self.rgbaComponents()
        return String(format: "#%02lX%02lX%02lX", rgbaComponents[0], rgbaComponents[1], rgbaComponents[2])
    }

    ///
    convenience init(rgba: UInt32) {
        let r = (rgba >> 24) & 0xFF
        let g = (rgba >> 16) & 0xFF
        let b = (rgba >> 8) & 0xFF
        let a = (rgba) & 0xFF

        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }

    ///
    convenience init(rgb: UInt32, alpha: CGFloat) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = (rgb) & 0xFF

        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }

    ///
    convenience init(rgb: UInt32) {
        self.init(rgb: rgb, alpha: 1)
    }

    ///
    public convenience init?(hexString: String?) {
        guard let hexStr = hexString else {
            return nil
        }

        let str = hexStr.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) //.uppercased()

        var value: UInt32 = 0
        Scanner(string: str).scanHexInt32(&value)

        let alpha, red, green, blue: UInt32

        switch str.count {
        case 3:
            (alpha, red, green, blue) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8:
            (alpha, red, green, blue) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            return nil
        }

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }

    ///
    fileprivate func rgbaComponents() -> [Int] {
        let colorSpace = self.cgColor.colorSpace!.model
        let p = self.cgColor.components

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if colorSpace == .monochrome {
            r = (p?[0])!
            g = (p?[0])!
            b = (p?[0])!
            a = (p?[1])!

        } else if colorSpace == .rgb {
            r = (p?[0])!
            g = (p?[1])!
            b = (p?[2])!
            a = (p?[3])!
        }

        return [lroundf(Float(r) * 255), lroundf(Float(g) * 255), lroundf(Float(b) * 255), lroundf(Float(a) * 255)]
    }

    ///
    func rgbaCGFloatComponents() -> [CGFloat] {
        let colorSpace = self.cgColor.colorSpace!.model
        let p = self.cgColor.components

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if colorSpace == .monochrome {
            r = (p?[0])!
            g = (p?[0])!
            b = (p?[0])!
            a = (p?[1])!

        } else if colorSpace == .rgb {
            r = (p?[0])!
            g = (p?[1])!
            b = (p?[2])!
            a = (p?[3])!
        }

        return [r, g, b, a]
    }

    class func interpolateRgbColor(_ from: UIColor, to: UIColor, fraction f: CGFloat) -> UIColor {
        var fraction = max(0, f)
        fraction = min(fraction, 1)

        let c1 = from.cgColor.components
        let c2 = to.cgColor.components

        let r = (c1?[0])! + ((c2?[0])! - (c1?[0])!) * fraction
        let g = (c1?[1])! + ((c2?[1])! - (c1?[1])!) * fraction
        let b = (c1?[2])! + ((c2?[2])! - (c1?[2])!) * fraction
        let a = (c1?[3])! + ((c2?[3])! - (c1?[3])!) * fraction

        //print("\(r) \(g) \(b) \(a) ")

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

}
