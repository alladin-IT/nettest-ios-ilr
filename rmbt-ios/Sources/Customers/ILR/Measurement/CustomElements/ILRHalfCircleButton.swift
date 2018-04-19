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
@IBDesignable class ILRHalfCircleButton: UIButton {

    ///
    enum RoundSide: Int {
        case top = 0
        case right
        case bottom
        case left
    }

    /// only for interface builder
    @IBInspectable var ibIcon: String = IconFont.indoor.rawValue {
        didSet {
            icon = IconFont(rawValue: ibIcon)!
        }
    }

    ///
    var icon: IconFont? {
        didSet {
            updateAttributedTitle()
        }
    }

    ///
    @IBInspectable var text: String? {
        didSet {
            updateAttributedTitle()
        }
    }

    /// only for interface builder
    @IBInspectable var ibRoundSide: Int = RoundSide.top.rawValue {
        didSet {
            roundSide = RoundSide(rawValue: ibRoundSide)!
        }
    }

    ///
    var roundSide: RoundSide = .top {
        didSet {
            switch roundSide {
            case .top:
                contentVerticalAlignment = .bottom
            case .bottom:
                contentVerticalAlignment = .top
            default:
                //contentVerticalAlignment = .top
                contentVerticalAlignment = .bottom
            }

            updateAttributedTitle()
        }
    }

    ///
    private var attributedTitle: NSMutableAttributedString?

    ///
    private let paragraphStyle = NSMutableParagraphStyle()

    ///
    private var initialFontSize: CGFloat = 15

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    ///
    private func commonInit() {
        paragraphStyle.alignment = .center

        contentHorizontalAlignment = .center
        contentVerticalAlignment = .top

        layer.masksToBounds = true

        initialFontSize = titleLabel?.font.pointSize ?? 15

        // improve layout for smaller iphones
        if UIDevice.current.screenType == .iPhone4_4S {
            initialFontSize -= 5
        }

        updateAttributedTitle()
    }

    ///
    private func updateAttributedTitle() {
        attributedTitle = NSMutableAttributedString()

        if roundSide == .top {
            appendIcon()
            appendNewline()
            appendText()
        } else {
            appendText()
            appendNewline()
            appendIcon()
        }

        titleLabel?.numberOfLines = 0
        setAttributedTitle(attributedTitle, for: .normal)

        layoutSubviews()
    }

    ///
    private func appendIcon() {
        if let i = icon {
            if let f = UIFont(name: ICON_FONT_NAME, size: /*30*/initialFontSize * 2), let c = titleLabel?.textColor {
                attributedTitle?.append(NSAttributedString(
                    string: i.rawValue,
                    attributes: [
                        NSAttributedStringKey.font: f,
                        NSAttributedStringKey.paragraphStyle: paragraphStyle,
                        NSAttributedStringKey.foregroundColor: c
                    ]
                ))
            }
        }
    }

    ///
    private func appendNewline() {
        attributedTitle?.append(NSAttributedString(string: "\n"))
    }

    ///
    private func appendText() {
        if let t = text {
            if let c = titleLabel?.textColor {
                attributedTitle?.append(NSAttributedString(
                    string: t,
                    attributes: [
                        //NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.largeTitle),
                        NSAttributedStringKey.paragraphStyle: paragraphStyle,
                        NSAttributedStringKey.foregroundColor: c
                    ]
                ))
            }
        }
    }

    ///
    override func layoutSubviews() {
        super.layoutSubviews()

        // TODO: hit test! (or see https://github.com/alvaromb/AMBCircularButton/blob/master/AMBCircularButton/AMBCircularButton.m for mask bounds)

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width / 2, y: roundSide == .top ? bounds.size.height : 0),
            radius: bounds.size.height/2,
            startAngle: roundSide == .top ? CGFloat.pi : 0,
            endAngle: roundSide == .top ? 0 : CGFloat.pi,
            clockwise: true
        )

        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath

        layer.mask = circleShape

        var ei = UIEdgeInsets.zero
        //ei.top = (indoorButton!.bounds.height/2 - indoorButton!.titleLabel!.bounds.height) / 2

        if roundSide == .top {
            ei.bottom = 5
        } else {
            ei.top = 5
        }

        titleEdgeInsets = ei
    }

    ///
    override func prepareForInterfaceBuilder() {
        updateAttributedTitle()
    }
}
