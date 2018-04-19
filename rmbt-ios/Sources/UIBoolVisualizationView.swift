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

import UIKit

///
@available(*, deprecated, message: "no longer used...")
open class UIBoolVisualizationView: UIView {

    ///
    public enum Status/*<StatusType: Bool>*/ {
        case none//(true)
        case neutral//(true)
        case success//(true)
        case warning//(true)
        case failure//(false)

        /*var showsCheckmark: Bool

        init(showsCheckmark: Bool) {
            self.showsCheckMark = showsCheckmark
        }*/
    }

    ///
    open var status: Status = .none

    ///
    open var colorDef: [Status: UIColor] = [ // TODO: colors -> global config
        .none: UIColor.white,
        .neutral: UIColor.gray,
        .success: COLOR_CHECK_GREEN,
        .warning: UIColor.yellow,
        .failure: COLOR_CHECK_RED
    ] {
        didSet {
            setNeedsDisplay()
        }
    }

    ///
    open var lineWidth: CGFloat?

    ///
    open var viewSpacing: CGFloat = 8

    ///
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
    }

    ///
    open override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()

        //if status.showsCheckmark { // draw TRUE
        if status == .none || status == .neutral || status == .success || status == .warning { // TODO: fix enum with bool type...
            // Subframes
            let group = CGRect(x: bounds.minX + 3, y: bounds.minY + 3, width: bounds.width - 6, height: bounds.height - 6)

            // Bezier Drawing
            bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width, y: group.minY + 0.54167 * group.height))
            bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width, y: group.minY + 0.68750 * group.height))
            bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))
        } else { // draw FALSE

            let widthMinusViewSpacing = frame.size.width - viewSpacing
            let heighthMinusViewSpacing = frame.size.height - viewSpacing

            bezierPath.move(to: CGPoint(x: viewSpacing, y: viewSpacing))
            bezierPath.addLine(to: CGPoint(x: widthMinusViewSpacing, y: heighthMinusViewSpacing))

            bezierPath.move(to: CGPoint(x: viewSpacing, y: heighthMinusViewSpacing))
            bezierPath.addLine(to: CGPoint(x: widthMinusViewSpacing, y: viewSpacing))
        }

        bezierPath.lineCapStyle = .square

        colorDef[status]?.setStroke()
        bezierPath.lineWidth = lineWidth ?? bounds.size.width / 10
        bezierPath.stroke()
    }
}
