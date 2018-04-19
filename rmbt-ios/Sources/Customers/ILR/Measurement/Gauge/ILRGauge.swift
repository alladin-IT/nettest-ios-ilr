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
@IBDesignable class ILRGauge: AbstractTwoArcGaugeView {

    // progress = ul
    // value = dl

    ///
    let speedUnits = [
        "",
        //"0M\(L("test.speed.bit-unit"))",
        "1M\(L("test.speed.bit-unit"))",
        "10M\(L("test.speed.bit-unit"))",
        "100M\(L("test.speed.bit-unit"))",
        "1G\(L("test.speed.bit-unit"))"
    ]

    ///
    override func initGauge() {
        angle = 270
        arcSpace = 20

        // improve layout for smaller iphones
        if UIDevice.current.screenType == .iPhone4_4S {
            arcSpace = 10
            arcWidth = 15
        }
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
        let (outerArcRadius, /*innerArcRadius*/_) = calculateRadius()

        let dlVal = CGFloat(min(1, max(0, value)))
        let ulVal = CGFloat(min(1, max(0, progress)))

        //logger.debug("OUTER: \(outerArcRadius), INNER: \(innerArcRadius)")

        context.saveGState()

        context.translateBy(x: centerPoint.x, y: centerPoint.y)
        context.rotate(by: deg2rad(90))
        context.translateBy(x: -centerPoint.x, y: -centerPoint.y)

        // draw base
        context.setLineWidth(arcWidth)
        context.setStrokeColor(baseColor.cgColor)

        // inner
        if currentPhase == .ping {
            context.setStrokeColor(ILR_RED.cgColor)
        } else {
            context.setStrokeColor(UIColor.lightGray.cgColor)
        }

        context.setLineWidth(2)
        context.addArc(center: centerPoint, radius: outerArcRadius * 0.41, startAngle: 0, endAngle: angleRad, clockwise: false)
        context.strokePath()

        // upload
        context.setStrokeColor(ILR_LIGHT_GRAY.cgColor)
        context.setLineWidth(arcWidth)
        context.addArc(center: centerPoint, radius: outerArcRadius * 0.66, startAngle: 0, endAngle: angleRad, clockwise: false)
        context.strokePath()

        // download
        context.setStrokeColor(ILR_LIGHT_RED.cgColor)
        context.setLineWidth(arcWidth)
        context.addArc(center: centerPoint, radius: outerArcRadius, startAngle: 0, endAngle: angleRad, clockwise: false)
        context.strokePath()

        //if currentPhase == .up {
            context.setStrokeColor(ILR_GRAY.cgColor)
            context.setLineWidth(arcWidth)
            context.addArc(center: centerPoint, radius: outerArcRadius * 0.66, startAngle: 0, endAngle: deg2rad(angle*ulVal), clockwise: false)
            context.strokePath()
        //} else if currentPhase == .down {
            context.setStrokeColor(ILR_RED.cgColor)
            context.setLineWidth(arcWidth)
            context.addArc(center: centerPoint, radius: outerArcRadius, startAngle: 0, endAngle: deg2rad(angle*dlVal), clockwise: false)
            context.strokePath()
        //}

        // arc separators
        for i: CGFloat in stride(from: angle/CGFloat(4), to: CGFloat(angle), by: angle/CGFloat(4)) {
            let p1 = getPointOnCircle(radius: outerArcRadius + arcWidth/2, center: centerPoint, phi: deg2rad(i))
            let p2 = getPointOnCircle(radius: outerArcRadius * 0.45, center: centerPoint, phi: deg2rad(i))

            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)
            context.move(to: p1)
            context.addLine(to: p2)
            context.strokePath()
        }

        // text
        context.translateBy(x: centerPoint.x, y: centerPoint.y)
        context.scaleBy(x: 1, y: -1)

        let an: CGFloat = 335
        var c = 0
        for i in stride(from: 0, to: an, by: an/5) {
            centreArcPerpendicular(
                text: speedUnits[c],
                context: context,
                radius: outerArcRadius * 0.83,
                angle: deg2rad(+(CGFloat((an-angle)/2))-CGFloat(i + (an/5)/2)),
                colour: UIColor.black,
                font: UIFont.systemFont(ofSize: 10),
                clockwise: true
            )

            c += 1
        }

        context.restoreGState()
    }
}
