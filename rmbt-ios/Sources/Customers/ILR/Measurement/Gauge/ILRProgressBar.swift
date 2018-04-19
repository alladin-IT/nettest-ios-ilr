/***************************************************************************
 * Copyright 2018 alladin-IT GmbH
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
class ILRProgressBar: UIView {

    ///
    var progress: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    ///
    var qosEnabled = true {
        didSet {
            if !qosEnabled { // TODO: enable?
                let remItem = items?.removeLast()
                remItem?.removeFromSuperview()
            }

            setNeedsDisplay()
        }
    }

    ///
    @IBOutlet private var items: [ILRProgressBarItem]?

    //

    ///
    override func awakeFromNib() {
        layer.masksToBounds = true

        layer.borderColor = ILR_GRAY.cgColor
        layer.borderWidth = 1
    }

    ///
    func calculateSeparators() {
        items?.forEach({ item in
            if items?.first != item {
                item.addBorderLeft()
            }
        })

        setNeedsDisplay()
    }

    ///
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        //context.setFillColor(ILR_LIGHT_GRAY.cgColor)
        context.setFillColor(ILR_RED.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: self.bounds.width * CGFloat(progress), height: self.bounds.height))
    }

    ///
    public func reset() {
        progress = 0
        // TODO: items

        items?.forEach({ item in
            item.reset()
        })

        setNeedsDisplay()
    }

    ///
    public func markPhase(phase: GaugePhase) {
        if let i = items {
            if i.count > phase.rawValue {
                i[phase.rawValue].mark()
            }
        }

        setNeedsDisplay()
    }

    ///
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.height, bounds.width) / 2
    }
}

///
class ILRProgressBarItem: UIView {

    ///
    @IBOutlet private var label: UILabel?

    ///
    private var borderLayer: CALayer?

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    public func addBorderLeft() {
        borderLayer?.removeFromSuperlayer()

        borderLayer = CALayer()

        let height = frame.size.height * 0.9
        let space = (frame.size.height - height) / 2

        borderLayer?.frame = CGRect(x: 0, y: space, width: 0.5, height: height)

        borderLayer?.backgroundColor = UIColor.white.cgColor

        layer.addSublayer(borderLayer!)
    }

    ///
    public func mark() {
        //backgroundColor = ILR_RED
        label?.textColor = UIColor.white
    }

    ///
    public func reset() {
        //backgroundColor = ILR_LIGHT_GRAY
        label?.textColor = UIColor.black
    }
}
