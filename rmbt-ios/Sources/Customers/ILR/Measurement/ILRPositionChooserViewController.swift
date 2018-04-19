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
import RMBTClient

///
class ILRPositionChooserViewController: NKOMAbstractStartViewController {

    ///
    @IBOutlet private var skipOrWaitButton: UIButton?

    ///
    @IBOutlet private var indoorButton: ILRHalfCircleButton?

    ///
    @IBOutlet private var outdoorButton: ILRHalfCircleButton?

    ///
    @IBOutlet private var frontView: ILRFrontView?

    //

    ///
    private var countdownTimer: Timer?

    ///
    private var seconds = 10

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        indoorButton?.roundSide = .top
        outdoorButton?.roundSide = .bottom

        if let advPosValues = RMBTSettings.sharedSettings.advancedPositionValues, advPosValues.count >= 2 {
            indoorButton?.tag = 0
            indoorButton?.icon = IconFont.indoor
            indoorButton?.text = advPosValues[0][0]
            //indoorButton?.setTitle(advPosValues[0][0], for: .normal)

            outdoorButton?.tag = 1
            outdoorButton?.icon = IconFont.outdoor
            outdoorButton?.text = advPosValues[1][0]
            //outdoorButton?.setTitle(advPosValues[1][0], for: .normal)

            logger.debug("ADV:")
            logger.debug(advPosValues)
        }

        //indoorButton?.update()
        //outdoorButton?.update()

        //setEnableGestures(enable: false)

        skipOrWaitButton?.tintColor = ILR_RED
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        seconds = 10

        hideNavigationItems()

        frontView?.startAnimation()

        updateSkipOrWaitButton()

        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        countdownTimer?.invalidate()
        countdownTimer = nil

        //frontView?.stopAnimation()

        showNavigationItems()
    }

    ///
    private func updateSkipOrWaitButton() {
        UIView.performWithoutAnimation {
            let title = String.localizedStringWithFormat(NSLocalizedString("test.skiporwait", comment: ""), seconds)

            skipOrWaitButton?.setTitle(title, for: .normal) // TODO: localize
            skipOrWaitButton?.layoutIfNeeded()
        }
    }

    ///
    private func stopTimer() {
        countdownTimer?.invalidate()
    }

    ///
    private func startMeasurement() {
        RMBTSettings.sharedSettings.position = nil

        performSegue(withIdentifier: "show_measurement_view_controller", sender: nil)
    }

    ///
    override func willEnterForeground() {
        frontView?.startAnimation()
    }

    ///
    @IBAction
    private func startMeasurement(sender: UIButton) {
        stopTimer()

        if let advPosValues = RMBTSettings.sharedSettings.advancedPositionValues, advPosValues.count >= 2 {
            if sender.tag == 0 {
                RMBTSettings.sharedSettings.position = advPosValues[0][1]
                logger.debug("ILR: INDOOR")
            } else if sender.tag == 1 {
                RMBTSettings.sharedSettings.position = advPosValues[1][1]
                logger.debug("ILR: OUTDOOR")
            }
        } else {
            RMBTSettings.sharedSettings.position = nil
        }

        performSegue(withIdentifier: "show_measurement_view_controller", sender: nil)
    }

    ///
    @objc func refresh() {
        seconds -= 1
        updateSkipOrWaitButton()

        if seconds < 1 {
            stopTimer()
            startMeasurement()
            //return
        }
    }

    ///
    @IBAction func viewTapped() {
        presentMeasurementAbortPopup(continueAction: nil) { _ in
            // TODO: abort

            self.stopTimer()
            //self.setEnableGestures(enable: true)
            self.navigationController?.popViewController(animated: false)
        }
    }
}
