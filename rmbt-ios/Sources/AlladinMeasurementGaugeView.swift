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

///
/*@IBDesignable */class AlladinMeasurementGaugeView: AbstractTwoArcGaugeView {

    ///
    private let baseOuterArcLayer = CAShapeLayer()

    ///
    private let baseInnerArcLayer = CAShapeLayer()

    ///
    private let outerArcLayer = CAShapeLayer()

    ///
    private let innerArcLayer = CAShapeLayer()

    ///
    private let baseProgressPath = UIBezierPath()

    ///
    private let baseValuePath = UIBezierPath()

    ///
    private let progressPath = UIBezierPath()

    ///
    private let valuePath = UIBezierPath()

    ///
    private let fillColor = UIColor.clear.cgColor

    ///
    enum ProgressType: Int {
        case speed = 1
        case qos
    }

    ///
    var progressType: ProgressType = .speed {
        didSet {
            _progress = 0
            update()
//            calculateBasePath()
            //calculateBezierPaths()
        }
    }

    ///
    override func initGauge() {
        baseOuterArcLayer.fillColor = fillColor
        baseInnerArcLayer.fillColor = fillColor

        outerArcLayer.fillColor = fillColor
        innerArcLayer.fillColor = fillColor

        //

        layer.addSublayer(baseOuterArcLayer)
        layer.addSublayer(baseInnerArcLayer)

        layer.addSublayer(outerArcLayer)
        layer.addSublayer(innerArcLayer)
    }

    override func update() {
        applyTransform()

        calculateBasePath()
        calculateBezierPaths()
    }

    ///
    override func layoutSubviews() { // use this because this view is not layout correctly in customInit...
        update()
    }

    ///
    private func applyTransform() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let transform = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: deg2rad(90 + (360-angle)/2)).translatedBy(x: -center.x, y: -center.y)

        baseOuterArcLayer.setAffineTransform(transform)
        baseInnerArcLayer.setAffineTransform(transform)

        outerArcLayer.setAffineTransform(transform)
        innerArcLayer.setAffineTransform(transform)
    }

    ///
    private func calculateBasePath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        if progressType == .qos {
            baseOuterArcLayer.strokeColor = progressColor.cgColor
        } else {
            baseOuterArcLayer.strokeColor = baseColor.cgColor
        }

        baseInnerArcLayer.strokeColor = baseColor.cgColor

        baseOuterArcLayer.lineWidth = arcWidth
        baseInnerArcLayer.lineWidth = arcWidth

        let (outerArcRadius, innerArcRadius) = calculateRadius()

        baseProgressPath.removeAllPoints()
        baseValuePath.removeAllPoints()

        baseProgressPath.addArc(withCenter: center, radius: outerArcRadius, startAngle: 0, endAngle: deg2rad(angle), clockwise: true) // 90+60, 90-60
        baseValuePath.addArc(withCenter: center, radius: innerArcRadius, startAngle: 0, endAngle: deg2rad(angle), clockwise: true) // 90+60, 90-60

        baseOuterArcLayer.path = baseProgressPath.cgPath
        baseInnerArcLayer.path = baseValuePath.cgPath
    }

    ///
    private func calculateBezierPaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let outerArcAngle = angle * CGFloat(abs(_progress))
        let innerArcAngle = angle * CGFloat(abs(value))

        let (outerArcRadius, innerArcRadius) = calculateRadius()

        progressPath.removeAllPoints()
        valuePath.removeAllPoints()

        if progressType == .qos {
            outerArcLayer.strokeColor = baseColor.cgColor
        } else {
            outerArcLayer.strokeColor = progressColor.cgColor
        }

        progressPath.addArc(withCenter: center, radius: outerArcRadius, startAngle: 0, endAngle: deg2rad(outerArcAngle), clockwise: true)

        valuePath.addArc(withCenter: center, radius: innerArcRadius, startAngle: 0, endAngle: deg2rad(innerArcAngle), clockwise: true)
        innerArcLayer.strokeColor = valueColor.cgColor

        //

        outerArcLayer.path = progressPath.cgPath
        innerArcLayer.path = valuePath.cgPath

        outerArcLayer.lineWidth = arcWidth
        innerArcLayer.lineWidth = arcWidth
    }
}
