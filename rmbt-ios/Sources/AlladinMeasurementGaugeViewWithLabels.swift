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
class AlladinMeasurementGaugeViewWithLabels: AbstractTwoArcGaugeView {

    static let qosString = "QoS"

    var phases = [
        L("test.phase.init"),
        L("test.phase.ping"),
        L("test.phase.download"),
        L("test.phase.upload"),
        qosString
    ]

    let speedUnits = [
        "0M\(L("test.speed.bit-unit"))",
        "1M\(L("test.speed.bit-unit"))",
        "10M\(L("test.speed.bit-unit"))",
        "100M\(L("test.speed.bit-unit"))",
        "1G\(L("test.speed.bit-unit"))"
    ]

    var qosEnabled: Bool = true {
        didSet {
            if qosEnabled {
                if !phases.contains(AlladinMeasurementGaugeViewWithLabels.qosString) {
                    phases.append(AlladinMeasurementGaugeViewWithLabels.qosString)
                }
            } else {
                if phases.contains(AlladinMeasurementGaugeViewWithLabels.qosString) {
                    phases.remove(at: phases.count - 1)
                }
            }

            update()
        }
    }

    ///
    override func initGauge() {

    }

    ///
    override func update() {
        setNeedsDisplay()
    }

    ///
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        let angleRad = deg2rad(angle)
        let fixedProgress = CGFloat(min(1, max(0, progress)))

        context.saveGState()

        //

        context.translateBy(x: centerPoint.x, y: centerPoint.y)
        context.rotate(by: deg2rad(150))
        context.translateBy(x: -centerPoint.x, y: -centerPoint.y)

        // draw base
        context.setLineWidth(arcWidth)
        context.setStrokeColor(baseColor.cgColor)

        let (outerArcRadius, innerArcRadius) = calculateRadius()

        // outer arc
        context.addArc(center: centerPoint, radius: outerArcRadius, startAngle: 0, endAngle: angleRad, clockwise: false)
        context.strokePath()

        // inner arc
        context.addArc(center: centerPoint, radius: innerArcRadius, startAngle: 0, endAngle: angleRad, clockwise: false)
        context.strokePath()

        // draw progress
        context.setStrokeColor(progressColor.cgColor)

        let z = CGFloat(currentPhase.rawValue)

        let progressAngle = (z * angle/CGFloat(phases.count)) + (angle/CGFloat(phases.count)) * fixedProgress

        context.addArc(center: centerPoint, radius: outerArcRadius, startAngle: 0, endAngle: deg2rad(progressAngle), clockwise: false)
        context.strokePath()

        // draw value
        context.setStrokeColor(valueColor.cgColor)

        context.addArc(center: centerPoint, radius: innerArcRadius, startAngle: 0, endAngle: deg2rad(angle * CGFloat(value)), clockwise: false)
        context.strokePath()

        //////////

        context.setStrokeColor(textColor.cgColor)
        context.setLineWidth(2)

        for i: CGFloat in stride(from: CGFloat(angle/CGFloat(phases.count)), to: CGFloat(angle), by: CGFloat(angle/CGFloat(phases.count))) {
            let p1 = getPointOnCircle(radius: outerArcRadius + arcWidth/2, center: centerPoint, phi: deg2rad(i))
            let p2 = getPointOnCircle(radius: outerArcRadius - arcWidth/2, center: centerPoint, phi: deg2rad(i))

            context.move(to: p1)
            context.addLine(to: p2)
            context.strokePath()
        }

        for i: CGFloat in stride(from: CGFloat(angle/4), to: CGFloat(angle), by: CGFloat(angle/4)) {
            let p1 = getPointOnCircle(radius: innerArcRadius - arcWidth/4, center: centerPoint, phi: deg2rad(i))
            let p2 = getPointOnCircle(radius: innerArcRadius - arcWidth/2, center: centerPoint, phi: deg2rad(i))

            context.move(to: p1)
            context.addLine(to: p2)
            context.strokePath()
        }

        //////////

        context.translateBy(x: centerPoint.x, y: centerPoint.y)
        context.scaleBy(x: 1, y: -1)

        var c = 0
        for i in stride(from: 0, to: angle, by: angle/CGFloat(phases.count)) {
            let a = deg2rad(-CGFloat(i + (angle/CGFloat(phases.count))/2))

            centreArcPerpendicular(text: phases[c], context: context, radius: outerArcRadius, angle: a, colour: textColor, font: UIFont.systemFont(ofSize: 16), clockwise: true)

            c += 1
        }

        let an = angle + 30
        c = 0
        for i in stride(from: 0, to: an, by: an/CGFloat(speedUnits.count)) {
            let a = deg2rad(+(CGFloat((an-angle)/2))-CGFloat(i + (an/CGFloat(speedUnits.count))/2))

            centreArcPerpendicular(text: speedUnits[c], context: context, radius: innerArcRadius + 2, angle: a, colour: textColor, font: UIFont.systemFont(ofSize: 10), clockwise: true)

            c += 1
        }

        context.restoreGState()
    }
}
