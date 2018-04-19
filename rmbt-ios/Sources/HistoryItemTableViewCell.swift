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
class HistoryItemTableViewCell: UITableViewCell {

    ///
    @IBOutlet var networkTypeIconLabel: UILabel?

    ///
    @IBOutlet var networkTypeLabel: UILabel?

    ///
    @IBOutlet var dateLabel: UILabel?

    ///
    @IBOutlet var qosAvailableLabel: UILabel?

    ///
    @IBOutlet var modelLabel: UILabel?

    ///
    @IBOutlet var downloadSpeedLabel: UILabel?

    ///
    @IBOutlet var uploadSpeedLabel: UILabel?

    ///
    @IBOutlet var pingLabel: UILabel?

    ///
    @IBOutlet var pingIconLabel: UILabel?
    @IBOutlet var downloadIconLabel: UILabel?
    @IBOutlet var uploadIconLabel: UILabel?

}
