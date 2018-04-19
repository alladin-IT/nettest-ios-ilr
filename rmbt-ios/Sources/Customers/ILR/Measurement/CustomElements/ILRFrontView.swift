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
@IBDesignable class ILRFrontView: UIView {

    ///
    private let baseLayer = CAShapeLayer()

    ///
    private let outerLayer = CAShapeLayer()
    private let midLayer = CAShapeLayer()
    private let innerLayer = CAShapeLayer()

    ///
    private let outerPath = UIBezierPath()
    private let midPath = UIBezierPath()
    private let innerPath = UIBezierPath()

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
        outerLayer.fillColor = UIColor.clear.cgColor
        outerLayer.strokeColor = ILR_LIGHT_GRAY.cgColor
        outerLayer.lineWidth = 10

        midLayer.fillColor = UIColor.clear.cgColor
        midLayer.strokeColor = ILR_RED.cgColor
        midLayer.lineWidth = 10

        innerLayer.fillColor = UIColor.clear.cgColor
        innerLayer.strokeColor = ILR_GRAY.cgColor
        innerLayer.lineWidth = 5

        baseLayer.addSublayer(outerLayer)
        baseLayer.addSublayer(midLayer)
        baseLayer.addSublayer(innerLayer)

        layer.addSublayer(baseLayer)

        calculatePath()
    }

    ///
    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let transform = CGAffineTransform(translationX: center.x, y: center.y)

        baseLayer.setAffineTransform(transform)

        calculatePath()
    }

    ///
    private func calculatePath() {
        let centerPoint = CGPoint(x: 0, y: 0)

        outerPath.removeAllPoints()
        midPath.removeAllPoints()
        innerPath.removeAllPoints()

        let outerRadius = (bounds.width - 10) / 2

        outerPath.addArc(withCenter: centerPoint, radius: outerRadius, startAngle: 0, endAngle: deg2rad(360), clockwise: true)
        midPath.addArc(withCenter: centerPoint, radius: outerRadius * 0.845, startAngle: deg2rad(360), endAngle: deg2rad(200), clockwise: false)
        innerPath.addArc(withCenter: centerPoint, radius: outerRadius * 0.715, startAngle: deg2rad(-100), endAngle: deg2rad(50), clockwise: false)

        outerLayer.path = outerPath.cgPath
        midLayer.path = midPath.cgPath
        innerLayer.path = innerPath.cgPath
    }

    ///
    private func buildRotateAnimation(clockwise: Bool) -> CABasicAnimation {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = clockwise ? 0 : 2 * CGFloat.pi
        rotateAnimation.toValue = clockwise ? 2 * CGFloat.pi : 0
        rotateAnimation.duration = 4
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = Float.infinity

        return rotateAnimation
    }

    ///
    func startAnimation() {
        // mid
        midLayer.add(buildRotateAnimation(clockwise: false), forKey: nil)

        // inner
        innerLayer.add(buildRotateAnimation(clockwise: true), forKey: nil)
    }

    ///
    func stopAnimation() {
        //outerLayer.removeAllAnimations()
        midLayer.removeAllAnimations()
        innerLayer.removeAllAnimations()
    }

    ///
    /*override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        // outer
        context.setStrokeColor(ILR_LIGHT_GRAY.cgColor)
        context.setLineWidth(10)
        context.addArc(center: centerPoint, radius: 100, startAngle: 0, endAngle: deg2rad(360), clockwise: false)
        context.strokePath()

        // mid
        context.setStrokeColor(ILR_RED.cgColor)
        context.setLineWidth(10)
        context.addArc(center: centerPoint, radius: 85, startAngle: deg2rad(360*test), endAngle: deg2rad(200), clockwise: false)
        context.strokePath()

        // inner
        context.setStrokeColor(ILR_GRAY.cgColor)
        context.setLineWidth(5)
        context.addArc(center: centerPoint, radius: 70, startAngle: deg2rad(-100), endAngle: deg2rad(50), clockwise: false)
        context.strokePath()
    }*/

    ///
    override func prepareForInterfaceBuilder() {
        layoutSubviews()
        setNeedsDisplay()
    }
}
