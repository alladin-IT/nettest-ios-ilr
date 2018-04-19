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
import UIKit
import RMBTClient
import PopupDialog
import ActionKit

///
class ILRStartViewController: NKOMAbstractStartViewController {

    ///
    @IBOutlet fileprivate var startButton: ILRCircleButton?

    ///
    @IBOutlet fileprivate var historyButton: UIButton?

    ///
    @IBOutlet private var frontView: ILRFrontView?

    ///
    var startLocationTracker = true

    //

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let grayAttributes = [
            NSAttributedStringKey.foregroundColor: ILR_GRAY,
            NSAttributedStringKey.font: UIFont(name: ICON_FONT_NAME, size: 32)!
        ]
        navigationItem.rightBarButtonItem?.setTitleTextAttributesForAllStates(grayAttributes)

        frontView?.startAnimation()

        if RMBTTOS.sharedTOS.isCurrentVersionAccepted() && startLocationTracker {
            _ = RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus(nil)
        }

        if let hb = historyButton {
            hb.layer.cornerRadius = hb.bounds.height / 2
            hb.backgroundColor = MEASUREMENT_REPORT_BUTTON_COLOR
        }
    }

    ///
    override func viewDidAppear(_ animated: Bool) {
        // fadein animation for button
        UIView.animate(withDuration: 1, animations: {
            self.startButton?.alpha = 1
        })

        let tos = RMBTTOS.sharedTOS
        if tos.isCurrentVersionAccepted() {
            if tos.goToSettingsAfterAccepting {
                performSegue(withIdentifier: "pushSettingsViewControllerFromTos", sender: nil)
            } else {
                _ = RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus(nil)
            }
        }
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        frontView?.stopAnimation()
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        startButton?.alpha = 0
        startButton?.backgroundColor = MEASUREMENT_START_BUTTON_COLOR

        ///////////////
        // Show TOS
        let tos = RMBTTOS.sharedTOS

        // If user hasn't agreed to new TOS version, show TOS modally
        if !tos.isCurrentVersionAccepted() {
            startLocationTracker = false

            logger.debug("Current TOS version \(tos.currentVersion) > last accepted version \(tos.lastAcceptedVersion), showing dialog")
            perform(segue: StoryboardSegue.Main.showTermsAndConditions, sender: self)
            //performSegue(withIdentifier: StoryboardSegue.Main.showTermsAndConditions.rawValue, sender: self)
            return
        }
    }

    ///
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            // make start button a circle // TODO: remove duplicate code

            self.startButton?.layoutSubviews()
        })
    }

    ///
    @IBAction private func showHistory() {
        performSegue(withIdentifier: "pushHistoryViewController", sender: nil)
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set side menu selected item to history
        if segue.identifier == "pushHistoryViewController" {
            if let r = revealViewController().rearViewController as? SideMenuController {
                r.selectRow(identifier: "history")
            }
        } else if segue.identifier == "pushSettingsViewControllerFromTos" {
            if let r = revealViewController().rearViewController as? SideMenuController {
                r.selectRow(identifier: "settings")
            }
        }
    }

    ///
    override func didDetectConnectivity(_ connectivity: RMBTConnectivity) {
        startButton?.isEnabled = true
        startButton?.backgroundColor = MEASUREMENT_START_BUTTON_COLOR
    }

    ///
    override func didDetectNoConnectivity() {
        startButton?.isEnabled = false
        startButton?.backgroundColor = ILR_DARK_GRAY
    }

    ///
    override func willEnterForeground() {
        frontView?.startAnimation()
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension ILRStartViewController {

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)

        let isPosLeft = position == .left

        startButton?.isUserInteractionEnabled = isPosLeft
    }
}
