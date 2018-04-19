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
import AVFoundation
import RMBTClient

///
class NKOMMeasurementViewController: NKOMAbstractStartViewController {

    ///
    fileprivate var rmbtClient: RMBTClient?

    ///
    fileprivate var measurementResultUuid: String?

    ///
    var runAgain = false

    ///
    private var player: AVAudioPlayer? // = AVAudioPlayer()

    //

    ///
    @IBOutlet fileprivate var measurementGaugeView: AlladinMeasurementGaugeViewWithLabels? //AlladinMeasurementGaugeView?

    ///
    @IBOutlet fileprivate var pingValueLabel: UILabel?

    ///
    @IBOutlet fileprivate var downloadValueLabel: UILabel?

    ///
    @IBOutlet fileprivate var uploadValueLabel: UILabel?

    ///
    @IBOutlet fileprivate var startAgainButton: UIButton?

    ///
    @IBOutlet fileprivate var viewMeasurementReportButton: UIButton?

    ///
    @IBOutlet private var pingIconLabel: UILabel?
    @IBOutlet private var downloadIconLabel: UILabel?
    @IBOutlet private var uploadIconLabel: UILabel?

    @IBOutlet private var progressPercentLabel: UILabel?
    @IBOutlet private var progressPercentIconLabel: UILabel?

    @IBOutlet private var topBandwidthLabel: UILabel?
    @IBOutlet private var topBandwidthIconLabel: UILabel?

    //

    var phaseCount: Float = 5

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true // Disallow turning off the screen

        //

        if UIDevice.current.userInterfaceIdiom == .pad {
            startAgainButton?.layer.cornerRadius = UIScreen.main.bounds.width / 16
        } else {
            startAgainButton?.layer.cornerRadius = UIScreen.main.bounds.width / 8 //(startButton?.bounds.size.width)! / 2 // "!"?
        }

        pingIconLabel?.textColor = ICON_TINT_COLOR
        downloadIconLabel?.textColor = ICON_TINT_COLOR
        uploadIconLabel?.textColor = ICON_TINT_COLOR

        progressPercentLabel?.textColor = MEASUREMENT_GAUGE_PROGRESS_COLOR
        progressPercentIconLabel?.textColor = MEASUREMENT_GAUGE_PROGRESS_COLOR

        topBandwidthLabel?.textColor = MEASUREMENT_GAUGE_VALUE_COLOR
        topBandwidthIconLabel?.textColor = MEASUREMENT_GAUGE_VALUE_COLOR

        // rounded corners for viewMeasurementReportButton
        if let reportButton = viewMeasurementReportButton {
            reportButton.layer.cornerRadius = reportButton.bounds.height / 2
            reportButton.backgroundColor = MEASUREMENT_REPORT_BUTTON_COLOR
        }

        measurementGaugeView?.qosEnabled = RMBTSettings.sharedSettings.nerdModeQosEnabled

        phaseCount = RMBTSettings.sharedSettings.nerdModeQosEnabled ? 5 : 4
    }

    ///
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false // Allow turning off the screen again
    }

    //
    override func viewDidLoad() {
        super.viewDidLoad()

        startMeasurement()
    }

    ///
    override func viewDidAppear(_ animated: Bool) {
        if runAgain {
            runAgain = false
            startMeasurement()
        }
    }

    ///
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            // make start button a circle // TODO: remove duplicate code
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.startAgainButton?.layer.cornerRadius = UIScreen.main.bounds.width / 16
            } else {
                self.startAgainButton?.layer.cornerRadius = UIScreen.main.bounds.width / 8
            }
        })
    }

    ///
    @IBAction fileprivate func startMeasurement() {
        playStupidJingle("start_sound")

        prepareViewForMeasurement()

        // reset measurement result
        measurementResultUuid = nil

        rmbtClient = RMBT.newClient()
        rmbtClient?.delegate = self
        rmbtClient?.startMeasurement()
    }

    ////////////////////////
    ///
    private func playStupidJingle(_ name: String) {
        if !(customerIsAlladin() && RMBTSettings.sharedSettings.soundsEnabled) {
            return
        }

        if let jingleUrl = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: jingleUrl)

                player?.prepareToPlay()
                player?.play()
            } catch let error {
                print(error.localizedDescription)
                // TODO
            }
        }
    }
    ////////////////////////

    ///
    fileprivate func stopMeasurement() {
        rmbtClient?.stopMeasurement()
    }

    ///
    fileprivate func returnToStartScreen() {
        let startViewController = StoryboardScene.Main.startViewController.instantiate()

        showNavigationItems()

        navigationController?.setViewControllers([startViewController], animated: false)
    }

    ///
    fileprivate func prepareViewForMeasurement() {
        hideNavigationItems()
        hideMeasurementResultButton()

        //measurementGaugeView?.progressType = .speed

        startAgainButton?.setIcon(.ping, for: .normal)
        startAgainButton?.backgroundColor = MEASUREMENT_START_BUTTON_DURING_MEASUREMENT_COLOR
        startAgainButton?.isEnabled = false

        pingValueLabel?.text = " "
        downloadValueLabel?.text = " "
        uploadValueLabel?.text = " "

        progressPercentLabel?.text = " "
        topBandwidthLabel?.text = " "

        topBandwidthIconLabel?.text = ""

        topBandwidthLabel?.isHidden = true
        topBandwidthIconLabel?.isHidden = true
    }

    ///
    @IBAction func viewTapped() {
        if let running = rmbtClient?.running, running {
            presentMeasurementAbortPopup(continueAction: nil) { _ in
                self.stopMeasurement()
                self.returnToStartScreen()
            }
        }
    }

    ///
    @IBAction func measurementResultViewTapped() {
        performSegue(withIdentifier: StoryboardSegue.Main.showMeasurementResult.rawValue, sender: nil)
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.Main(rawValue: segue.identifier!)! {
        case .showMeasurementResult:
            if let measurementResultViewController = segue.destination as? MeasurementResultTableViewController {
                measurementResultViewController.measurementUuid = measurementResultUuid
                measurementResultViewController.measuredNow = true
                measurementResultViewController.qosResultsAvailable = RMBTSettings.sharedSettings.nerdModeQosEnabled
            }
        default:
            break
        }
    }

    fileprivate func resetStartAgainButton() {
        startAgainButton?.backgroundColor = MEASUREMENT_START_BUTTON_COLOR
        startAgainButton?.isEnabled = true

        startAgainButton?.setIcon(.start, for: .normal)
    }

    ///
    fileprivate func showMeasurementResultButton() {
        viewMeasurementReportButton?.isHidden = false

        playStupidJingle("finish_sound")
    }

    ///
    fileprivate func hideMeasurementResultButton() {
        viewMeasurementReportButton?.isHidden = true
    }
}

///
extension NKOMMeasurementViewController: RMBTClientDelegate {

    ///
    //private var currentSpeedMeasurementPhase: SpeedMeasurementPhase

    ///
    func measurementDidComplete(_ client: RMBTClient, withResult result: String) {
        logger.debug("DID COMPLETE")

        self.measurementResultUuid = result

        DispatchQueue.main.async {
            self.showNavigationItems()
            self.showMeasurementResultButton()
            self.resetStartAgainButton()
        }
    }

    ///
    func measurementDidFail(_ client: RMBTClient, withReason reason: RMBTClientCancelReason) {
        logger.debug("MEASUREMENT FAILED: \(reason)")

        var message = L10n.Measurement.UnknownError.message
        let title = L10n.Measurement.UnknownError.title

        switch reason { // TODO: show alert
        case .userRequested:
            logger.debug("Test cancelled on users request")
            returnToStartScreen()
            return
        case .appBackgrounded:
            logger.debug("Test cancelled because app backgrounded")
            message = L10n.Test.abortedMessage
        case .mixedConnectivity:
            logger.debug("Test cancelled because of mixed connectivity")
            startMeasurement()
            return
        case .noConnection:
            logger.debug("Test cancelled because of NO connectivity")
            message = L10n.Test.Connection.lost
        case .errorFetchingSpeedMeasurementParams:
            logger.debug("Test cancelled because test params couldn't be fetched")
            message = L10n.Test.Connection.couldNotConnect
        case .errorSubmittingSpeedMeasurement:
            logger.debug("Test cancelled because test result couldn't be uploaded to the control server")
            message = L10n.Test.Result.notSubmitted
        // TODO: other errors
        default:
            break
        }

        /////////////////////

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let startOverAction = UIAlertAction(title: L10n.Test.tryAgain, style: .default) { _ in
            self.startMeasurement()
        }
        alertController.addAction(startOverAction)

        let dismissAction = UIAlertAction(title: L10n.General.Alertview.dismiss, style: .cancel) { _ in
            self.returnToStartScreen()
        }
        alertController.addAction(dismissAction)

        ///

        present(alertController, animated: true, completion: nil)
    }

    //

    ///
    func speedMeasurementDidMeasureSpeed(_ kbps: UInt64, inPhase phase: SpeedMeasurementPhase) {
        let speedString = RMBTSpeedMbpsString(kbps, withMbps: false)
        let speedLogValue = RMBTSpeedLogValue(kbps, gaugeParts: 4, log10Max: log10(1000))

        DispatchQueue.main.async {

            switch phase {
            case .down:
                self.downloadValueLabel?.text = "\(speedString)"
            case .up:
                self.uploadValueLabel?.text = "\(speedString)"
            default:
                break
            }

            self.topBandwidthLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: true)

            self.measurementGaugeView?.value = speedLogValue
        }
    }

    ///
    func speedMeasurementDidStartPhase(_ phase: SpeedMeasurementPhase) {
        DispatchQueue.main.async {

            self.measurementGaugeView?.value = 0
            self.topBandwidthLabel?.text = ""

            switch phase {
            //case .Init:
            //case .latency:
            case .down:
                self.startAgainButton?.setIcon(.down, for: .normal)

                self.topBandwidthLabel?.text = RMBTSpeedMbpsString(0, withMbps: true)
                self.topBandwidthIconLabel?.text = IconFont.down.rawValue

                self.topBandwidthLabel?.isHidden = false
                self.topBandwidthIconLabel?.isHidden = false
            //case .initUp:
            case .up:
                self.startAgainButton?.setIcon(.up, for: .normal)

                self.topBandwidthLabel?.text = RMBTSpeedMbpsString(0, withMbps: true)
                self.topBandwidthIconLabel?.text = IconFont.up.rawValue

                self.topBandwidthLabel?.isHidden = false
                self.topBandwidthIconLabel?.isHidden = false
            default:
                self.topBandwidthLabel?.isHidden = true
                self.topBandwidthIconLabel?.isHidden = true
            }
        }
    }

    ///
    func speedMeasurementDidFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: UInt64) {
        DispatchQueue.main.async {

            switch phase {
            case .latency:
                self.pingValueLabel?.text = "\(RMBTFormatNumber(NSNumber(value: Double(result) * 1.0e-6)))"

                self.measurementGaugeView?.progress = 0
                self.measurementGaugeView?.currentPhase = .down
                //self.measurementGaugeView?.progress = 1/3
            case .down:
                self.downloadValueLabel?.text = RMBTSpeedMbpsString(result, withMbps: false)

                self.measurementGaugeView?.progress = 0
                self.measurementGaugeView?.currentPhase = .up
                //self.measurementGaugeView?.progress = 2/3
            case .up:
                self.uploadValueLabel?.text = RMBTSpeedMbpsString(result, withMbps: false)

                self.measurementGaugeView?.progress = 0
                //self.measurementGaugeView?.progress = 1

                self.measurementGaugeView?.currentPhase = .qos
            default:
                break
            }

            self.measurementGaugeView?.value = 0
        }
    }

    ///
    func speedMeasurementDidUpdateProgress(_ progress: Float, inPhase phase: SpeedMeasurementPhase) {
        DispatchQueue.main.async {
            //let p = Double(progress * 1/3)

            var phaseIndex = 0

            switch phase {
            case .Init:
                self.measurementGaugeView?.currentPhase = .Init

                //self.measurementGaugeView?.progress = p * 0.5
            case .latency:
                phaseIndex = 1

                self.measurementGaugeView?.currentPhase = .ping

                //self.measurementGaugeView?.progress = 1/6 + p * 0.5
            case .down:
                phaseIndex = 2

                self.measurementGaugeView?.currentPhase = .down

                //self.measurementGaugeView?.progress = 1/3 + p
            case .initUp:
                //self.measurementGaugeView?.progress = 2/3 + p * 0.2

                return
            case .up:
                phaseIndex = 3

                self.measurementGaugeView?.currentPhase = .up

                //let workaroundForExpressionTooComplex = 0.73333333333 // 2/3 + 1/3 * 0.2
                //self.measurementGaugeView?.progress = workaroundForExpressionTooComplex + (p * 0.8)
            default:
                break
            }

            self.measurementGaugeView?.progress = Double(progress)

            var overallProgress = Float(100/self.phaseCount) * Float(phaseIndex)
            overallProgress += (100/self.phaseCount)*progress
            self.progressPercentLabel?.text = "\(Int(overallProgress))%"
        }
    }

// MARK: 

    ///
    func qosMeasurementDidStart(_ client: RMBTClient) {
        DispatchQueue.main.async {
            //self.measurementGaugeView?.progressType = .qos

            self.measurementGaugeView?.currentPhase = .qos

            self.topBandwidthLabel?.text = "0%"
            self.topBandwidthIconLabel?.text = IconFont.qos.rawValue

            self.topBandwidthLabel?.isHidden = false
            self.topBandwidthIconLabel?.isHidden = false

            self.startAgainButton?.setIcon(.qos, for: .normal)
        }
    }

    ///
    func qosMeasurementDidUpdateProgress(_ client: RMBTClient, progress: Float) {
        DispatchQueue.main.async {
            self.measurementGaugeView?.progress = Double(progress)

            let qosProgress = 100*progress
            self.topBandwidthLabel?.text = "\(Int(qosProgress))%"

            let overallProgress = 100/self.phaseCount * 4 + (100/self.phaseCount)*progress
            self.progressPercentLabel?.text = "\(Int(overallProgress))%"
        }
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension NKOMMeasurementViewController {

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)

        let isPosLeft = position == .left

        startAgainButton?.isUserInteractionEnabled = isPosLeft
    }
}
