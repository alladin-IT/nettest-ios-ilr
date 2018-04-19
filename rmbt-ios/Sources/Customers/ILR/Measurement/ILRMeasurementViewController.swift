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
import AVFoundation
import RMBTClient

///
class ILRMeasurementViewController: NKOMAbstractStartViewController {

    ///
    fileprivate var rmbtClient: RMBTClient?

    ///
    fileprivate var measurementResultUuid: String?

    //

    ///
    @IBOutlet fileprivate var measurementGaugeView: ILRGauge?

    ///
    @IBOutlet private var progressBar: ILRProgressBar?

    ///
    @IBOutlet fileprivate var pingValueLabel: UILabel?

    ///
    @IBOutlet fileprivate var downloadValueLabel: UILabel?

    ///
    @IBOutlet fileprivate var uploadValueLabel: UILabel?

    ///
    @IBOutlet fileprivate var viewMeasurementReportButton: UIButton?

    ///
    @IBOutlet private var pingIconLabel: UILabel?
    @IBOutlet private var downloadIconLabel: UILabel?
    @IBOutlet private var uploadIconLabel: UILabel?

    @IBOutlet private var phaseIconLabel: UILabel?
    @IBOutlet private var currentValueLabel: UILabel?

    @IBOutlet private var startAgainButton: UIButton?

    //

    @IBOutlet private var gaugeProportialHeightConstraint: NSLayoutConstraint?

    //

    var phaseCount: Float = 5

    ///
    class var isIphoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true // Disallow turning off the screen

        //

        // rounded corners for viewMeasurementReportButton
        if let reportButton = viewMeasurementReportButton {
            reportButton.layer.cornerRadius = reportButton.bounds.height / 2
            reportButton.backgroundColor = MEASUREMENT_REPORT_BUTTON_COLOR
        }

        // rounded corners for progressBar
        progressBar?.qosEnabled = RMBTSettings.sharedSettings.nerdModeQosEnabled

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

        let grayAttributes = [
            NSAttributedStringKey.foregroundColor: ILR_GRAY,
            NSAttributedStringKey.font: UIFont(name: ICON_FONT_NAME, size: 32)!
        ]
        navigationItem.rightBarButtonItem?.setTitleTextAttributesForAllStates(grayAttributes)

        // improve layout for smaller iphones
        if UIDevice.current.screenType == .iPhone4_4S {
            if let f = startAgainButton?.titleLabel?.font {
                startAgainButton?.titleLabel?.font = f.withSize(f.pointSize - 5)
            }

            if let f = phaseIconLabel?.font {
                phaseIconLabel?.font = f.withSize(f.pointSize - 5)
            }

            if let f = currentValueLabel?.font {
                currentValueLabel?.font = f.withSize(f.pointSize - 5)
            }
        }

        hideNavigationItems()

        fixConstraints()

        startMeasurement()
    }

    ///
    private func fixConstraints() {
        progressBar?.calculateSeparators()

        //if ILRMeasurementViewController.isIphoneX {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                gaugeProportialHeightConstraint?.constant = -5
            } else {
                gaugeProportialHeightConstraint?.constant = -20
            }
            view.layoutIfNeeded()
        }
    }

    ///
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.fixConstraints()
        })
    }

    ///
    private func startMeasurement() {
        prepareViewForMeasurement()

        // reset measurement result
        measurementResultUuid = nil

        rmbtClient = RMBT.newClient()
        rmbtClient?.delegate = self
        rmbtClient?.startMeasurement()
    }

    ///
    fileprivate func stopMeasurement() {
        rmbtClient?.stopMeasurement()

        //setEnableGestures(enable: true)
    }

    ///
    fileprivate func returnToStartScreen() {
        //setEnableGestures(enable: true)
        showNavigationItems()

        navigationController?.popToRootViewController(animated: false)
    }

    ///
    @IBAction fileprivate func returnToPositionChooserScreen() {
        showNavigationItems()

        navigationController?.popViewController(animated: true)
    }

    ///
    fileprivate func prepareViewForMeasurement() {
        //setEnableGestures(enable: false)
        hideNavigationItems()
        hideMeasurementResultButton()

        startAgainButton?.isHidden = true
        startAgainButton?.isEnabled = false

        markIcons(color: ILR_GRAY)

        pingValueLabel?.text = " "
        downloadValueLabel?.text = " "
        uploadValueLabel?.text = " "

        phaseIconLabel?.text = " "
        currentValueLabel?.text = " "

        pingValueLabel?.text = "..."
        pingValueLabel?.textColor = ILR_RED

        progressBar?.reset()
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
        //setEnableGestures(enable: true)
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

    ///
    fileprivate func resetStartAgainButton() {
        phaseIconLabel?.text = " "
        currentValueLabel?.text = " "

        startAgainButton?.isHidden = false
        startAgainButton?.isEnabled = true
    }

    ///
    private func markIcons(color: UIColor) {
        pingValueLabel?.textColor = color
        downloadValueLabel?.textColor = color
        uploadValueLabel?.textColor = color

        pingIconLabel?.textColor = color
        downloadIconLabel?.textColor = color
        uploadIconLabel?.textColor = color
    }

    ///
    fileprivate func showMeasurementResultButton() {
        viewMeasurementReportButton?.isHidden = false
    }

    ///
    fileprivate func hideMeasurementResultButton() {
        viewMeasurementReportButton?.isHidden = true
    }
}

///
extension ILRMeasurementViewController: RMBTClientDelegate {

    ///
    //private var currentSpeedMeasurementPhase: SpeedMeasurementPhase

    ///
    func measurementDidComplete(_ client: RMBTClient, withResult result: String) {
        logger.debug("DID COMPLETE")

        self.measurementResultUuid = result

        DispatchQueue.main.async {
            self.progressBar?.markPhase(phase: .qos)

            self.markIcons(color: ILR_BLACK)

            //self.setEnableGestures(enable: true)
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
        let speedLogValue = RMBTSpeedLogValue(kbps, gaugeParts: 4, log10Max: log10(1000))

        DispatchQueue.main.async {

            switch phase {
            case .down:
                self.downloadValueLabel?.text = "..."

                self.measurementGaugeView?.value = speedLogValue
            case .up:
                self.uploadValueLabel?.text = "..."

                self.measurementGaugeView?.progress = speedLogValue
            default:
                break
            }

            self.currentValueLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: true)
        }
    }

    ///
    func speedMeasurementDidStartPhase(_ phase: SpeedMeasurementPhase) {
        DispatchQueue.main.async {

            self.currentValueLabel?.text = ""

            switch phase {
            case .Init:
                self.measurementGaugeView?.currentPhase = .Init
            case .latency:
                self.measurementGaugeView?.currentPhase = .ping

                self.phaseIconLabel?.text = IconFont.ping.rawValue
            case .down:
                self.measurementGaugeView?.value = 0

                self.measurementGaugeView?.currentPhase = .down

                self.downloadValueLabel?.textColor = ILR_RED

                self.currentValueLabel?.text = RMBTSpeedMbpsString(0, withMbps: true)

                self.phaseIconLabel?.text = IconFont.down.rawValue
            //case .initUp:
            case .up:
                self.measurementGaugeView?.progress = 0

                self.measurementGaugeView?.currentPhase = .up

                self.uploadValueLabel?.textColor = ILR_RED

                self.currentValueLabel?.text = RMBTSpeedMbpsString(0, withMbps: true)

                self.phaseIconLabel?.text = IconFont.up.rawValue
            default:
                break
            }
        }
    }

    ///
    func speedMeasurementDidFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: UInt64) {
        DispatchQueue.main.async {

            switch phase {
            case .Init:
                self.progressBar?.markPhase(phase: .Init)
            case .latency:
                self.progressBar?.markPhase(phase: .ping)

                self.pingValueLabel?.text = "\(RMBTFormatNumber(NSNumber(value: Double(result) * 1.0e-6))) \(L10n.Test.Ping.unit)"

                self.pingValueLabel?.textColor = ILR_DARK_GRAY
            case .down:
                self.progressBar?.markPhase(phase: .down)

                self.measurementGaugeView?.currentPhase = .down

                self.downloadValueLabel?.text = RMBTSpeedMbpsString(result, withMbps: true)
                self.downloadValueLabel?.textColor = ILR_DARK_GRAY

                let speedLogValue = RMBTSpeedLogValue(result, gaugeParts: 4, log10Max: log10(1000))
                self.measurementGaugeView?.value = speedLogValue
            case .up:
                self.progressBar?.markPhase(phase: .up)

                self.measurementGaugeView?.currentPhase = .up

                self.uploadValueLabel?.text = RMBTSpeedMbpsString(result, withMbps: true)
                self.uploadValueLabel?.textColor = ILR_DARK_GRAY

                let speedLogValue = RMBTSpeedLogValue(result, gaugeParts: 4, log10Max: log10(1000))
                self.measurementGaugeView?.progress = speedLogValue
            default:
                break
            }
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

            //self.measurementGaugeView?.progress = Double(progress)

            var overallProgress = Float(100/self.phaseCount) * Float(phaseIndex)
            overallProgress += (100/self.phaseCount)*progress

            //logger.debug("------------- OVERALL PROGRESS: \(overallProgress)")

            self.progressBar?.progress = Double(overallProgress)/100

            //self.progressPercentLabel?.text = "\(Int(overallProgress))%"
        }
    }

// MARK: 

    ///
    func qosMeasurementDidStart(_ client: RMBTClient) {
        DispatchQueue.main.async {
            //self.measurementGaugeView?.progressType = .qos

            //self.measurementGaugeView?.currentPhase = .qos

            self.currentValueLabel?.text = "0%"
            //self.topBandwidthLabel?.text = "0%"

            self.phaseIconLabel?.text = IconFont.qos.rawValue
            //self.topBandwidthIconLabel?.text = IconFont.qos.rawValue

            //self.topBandwidthLabel?.isHidden = false
            //self.topBandwidthIconLabel?.isHidden = false

            //self.startAgainButton?.setIcon(.qos, for: .normal)
        }
    }

    ///
    func qosMeasurementDidUpdateProgress(_ client: RMBTClient, progress: Float) {
        DispatchQueue.main.async {
            //self.measurementGaugeView?.progress = Double(progress)

            let qosProgress = 100*progress
            self.currentValueLabel?.text = "\(Int(qosProgress))%"
            //self.topBandwidthLabel?.text = "\(Int(qosProgress))%"

            let overallProgress = 100/self.phaseCount * 4 + (100/self.phaseCount)*progress
            self.progressBar?.progress = Double(overallProgress)/100
            //self.progressPercentLabel?.text = "\(Int(overallProgress))%"
        }
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension ILRMeasurementViewController {

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)

        //let isPosLeft = position == .left

        //startAgainButton?.isUserInteractionEnabled = isPosLeft
    }
}
