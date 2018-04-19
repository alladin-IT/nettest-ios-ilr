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
protocol StringAttribute {

}

/// taken from http://stackoverflow.com/questions/3586871/bold-non-bold-text-in-a-single-uilabel/17743543#33910728
extension UILabel: StringAttribute {

    ///
    func boldRange(_ range: Range<String.Index>) {
        if let text = self.attributedText {
            let attr = NSMutableAttributedString(attributedString: text)
            let start = text.string.distance(from: text.string.startIndex, to: range.lowerBound)
            let length = text.string.distance(from: range.lowerBound, to: range.upperBound)
            attr.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: self.font.pointSize)], range: NSRange(location: start, length: length))
            self.attributedText = attr
        }
    }

    ///
    func boldSubstring(_ substr: String) {
        let range = self.text?.range(of: substr)
        if let r = range {
            boldRange(r)
        }
    }

}
