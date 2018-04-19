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

/*
static UIFont *cellTextFont, *cellDetailTextFont;
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    cellTextFont = [UIFont boldSystemFontOfSize:17.0f];
    cellDetailTextFont = [UIFont systemFontOfSize:17.0f];
});
*/

///
let _uitableviewcell_font = UIFont.boldSystemFont(ofSize: 17)

///
let _uitableviewcell_cellTextFont: UIFont = _uitableviewcell_font

///
let _uitableviewcell_cellDetailTextFont: UIFont = _uitableviewcell_font

///
protocol RMBTHeight {
    //+(CGFloat)rmbtApproximateOptimalHeightForText:(NSString*)text detailText:(NSString*)detailText;
    //-(CGFloat)rmbtApproximateOptimalHeight;
}

///
extension UITableViewCell: RMBTHeight {

    ///
    class func rmbtApproximateOptimalHeightForText(_ text: String?, detailText: String?) -> CGFloat {
        var textSize = CGSize(width: 0, height: 0) // default
        if let t = text {
            textSize = t.size(withAttributes: [NSAttributedStringKey(rawValue: "NSFontAttributeName"): _uitableviewcell_cellTextFont])
        }

        var detailTextSize = CGSize(width: 0, height: 0) // default
        if let t = detailText {
            detailTextSize = t.size(withAttributes: [NSAttributedStringKey(rawValue: "NSFontAttributeName"): _uitableviewcell_cellDetailTextFont])
        }

        let totalWidth: CGFloat = textSize.width + detailTextSize.width

        if totalWidth > 380 {
            return 80
        } else if totalWidth > 200 {
            return 64
        }

        return 44
    }

    ///
    func rmbtApproximateOptimalHeight() -> CGFloat {
        return UITableViewCell.rmbtApproximateOptimalHeightForText(textLabel?.text, detailText: detailTextLabel?.text)
    }

}
