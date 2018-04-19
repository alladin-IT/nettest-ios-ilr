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

import Foundation
import UIKit
import RMBTClient

///
class NKOMAbstractStartViewController: TopLevelViewController {

    ///
    var connectivityTracker: RMBTConnectivityTracker?

    ///
    var lastConnectivity: RMBTConnectivity?

    ///
    @IBOutlet var leftBarItem: UIBarButtonItem?

    ///
    @IBOutlet var rightBarItem: UIBarButtonItem?

    //

    ///
    @IBOutlet var networkNameLabel: UILabel?

    ///
    @IBOutlet var networkTypeLabel: UILabel?

    ///
    @IBOutlet var customerLogoImageView: UIImageView?

    //

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        networkNameLabel?.text = ""
        networkTypeLabel?.text = ""

        // start connectivity tracker
        if connectivityTracker == nil { // TODO: dispatch_once?
            connectivityTracker = RMBTConnectivityTracker(delegate: self, stopOnMixed: false)
            connectivityTracker?.start()
        }
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        connectivityTracker?.stop() // TODO: is this correct? old code doesn't stop it
        connectivityTracker = nil
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // hide shadow image of navigation bar
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        view.backgroundColor = MEASUREMENT_SCREEN_BACKGROUND_COLOR

        if customerIsAlladin() {
            let f = CGRect(x: 0, y: 0, width: customerLogoImageView!.bounds.width, height: customerLogoImageView!.bounds.height)

            let alladinLogoLabel = UILabel(frame: f)
            alladinLogoLabel.icon = .logo
            alladinLogoLabel.textAlignment = .center
            alladinLogoLabel.textColor = RMBT_TINT_COLOR
            alladinLogoLabel.font = UIFont.init(name: ICON_FONT_NAME, size: 60)

            customerLogoImageView?.addSubview(alladinLogoLabel)
        }

        // listen for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    ///
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    ///
    @IBAction func showHelp() {
        presentModalBrowserWithURLString(RMBT_HELP_URL)
    }

    ///
    func hideNavigationItems() {
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.setHidesBackButton(true, animated: false)

        //setEnableGestures(enable: false)
    }

    ///
    func showNavigationItems() {
        navigationItem.setLeftBarButton(leftBarItem, animated: true)
        navigationItem.setRightBarButton(rightBarItem, animated: true)
        navigationItem.setHidesBackButton(false, animated: false)

        //setEnableGestures(enable: true)
    }

    ///
    func presentMeasurementAbortPopup(continueAction: ((UIAlertAction) -> Void)?, abortAction: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: L10n.Measurement.Abort.title, message: L10n.Measurement.Abort.question, preferredStyle: .alert)

        let continueAction = UIAlertAction(title: L10n.Measurement.Abort.continue, style: .default, handler: continueAction)
        alertController.addAction(continueAction)

        let abortAction = UIAlertAction(title: L10n.Measurement.Abort.abortButton, style: .cancel, handler: abortAction)
        alertController.addAction(abortAction)

        ///

        present(alertController, animated: true, completion: nil)
    }

    ///
    func didDetectConnectivity(_ connectivity: RMBTConnectivity) {
        //self.startButton?.enabled = true
    }

    ///
    func didDetectNoConnectivity() {
        //self.startButton?.enabled = false
    }

    ///
    @objc func didEnterBackground() {
        // to be overriden
    }

    ///
    @objc func willEnterForeground() {
        // to be overriden
    }
}

// MARK: RMBTConnectivityTrackerDelegate

///
extension NKOMAbstractStartViewController: RMBTConnectivityTrackerDelegate {

    ///
    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {
        logger.debug("connectivityTracker didDetectNoConnectivity")
        DispatchQueue.main.async {
            self.didDetectNoConnectivity()

            self.networkNameLabel?.text = ""
            self.networkTypeLabel?.text = L10n.Intro.Network.Connection.unavailable
        }
    }

    ///
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity) {
        logger.debug("connectivityTracker didDetectConnectivity \(connectivity)")

        lastConnectivity = connectivity

        DispatchQueue.main.async {
            self.didDetectConnectivity(connectivity)

            #if (arch(i386) || arch(x86_64))
                // running in simulator, return other wifi name
                self.networkNameLabel?.text = "my_wifi" // TODO: make configurable
            #else
                self.networkNameLabel?.text = connectivity.networkName ?? L10n.Intro.Network.Connection.nameUnknown
            #endif

            if let mccMnc = connectivity.telephonyNetworkSimOperator, STARTSCREEN_SHOW_MCC_MNC {
                self.networkTypeLabel?.text = "\(connectivity.networkTypeDescription), \(mccMnc)"
            } else {
                self.networkTypeLabel?.text = connectivity.networkTypeDescription
            }
        }
    }

    ///
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didStopAndDetectIncompatibleConnectivity connectivity: RMBTConnectivity) {
        // do nothing
    }
}
