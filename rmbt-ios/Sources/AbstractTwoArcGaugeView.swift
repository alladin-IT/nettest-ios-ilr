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
class AbstractTwoArcGaugeView: UIView, TwoArcGaugeProtocol {

    ///
    var _progress: Double = 0

    ///
    var currentPhase: GaugePhase = .Init {
        didSet {
            update()
        }
    }

    ///
    var arcWidth: CGFloat = 25 {
        didSet {
            update()
        }
    }

    ///
    var arcSpace: CGFloat = 15 {
        didSet {
            update()
        }
    }

    ///
    var angle: CGFloat = 240 {
        didSet {
            update()
        }
    }

    ///
    var progress: Double = 0 {
        didSet {
            _progress = progress
            update()
        }
    }

    ///
    var value: Double = 0 {
        didSet {
            update()
        }
    }

    ///
    var baseColor = MEASUREMENT_GAUGE_BASE_COLOR {
        didSet {
            update()
        }
    }

    ///
    var progressColor = MEASUREMENT_GAUGE_PROGRESS_COLOR {
        didSet {
            update()
        }
    }

    ///
    var valueColor = MEASUREMENT_GAUGE_VALUE_COLOR {
        didSet {
            update()
        }
    }

    ///
    var textColor = MEASUREMENT_GAUGE_TEXT_COLOR {
        didSet {
            update()
        }
    }

    //var font = UIFont... // TODO

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)

        initGauge()
    }

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initGauge()
    }

    ///
    func initGauge() {

    }

    ///
    func update() {

    }

    ///
    override func prepareForInterfaceBuilder() {
        update()
    }

    ///
    func calculateRadius() -> (CGFloat, CGFloat) {
        let outerArcRadius = (bounds.width - 10 - arcWidth) / 2
        let innerArcRadius = outerArcRadius - arcWidth - arcSpace

        return (outerArcRadius, innerArcRadius)
    }
}
