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
class ClassifyableKeyValueTableViewCell: KeyValueTableViewCell {

    ///
    @IBOutlet fileprivate var classifyView: UIView?

    ///
    var classification: Int? {
        didSet {
            switch classification ?? 0 {
            case 1: classifyView?.backgroundColor = COLOR_CHECK_RED
            case 2: classifyView?.backgroundColor = COLOR_CHECK_YELLOW
            case 3: classifyView?.backgroundColor = COLOR_CHECK_GREEN
            default: classifyView?.backgroundColor = UIColor.clear
            }
        }
    }

    var classificationColor: UIColor? {
        didSet {
            classifyView?.backgroundColor = classificationColor
        }
    }
}
