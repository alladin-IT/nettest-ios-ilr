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
import RMBTClient

class HardwarePopupViewController: PopupTableViewController {

    ///
    var cpuMonitor: RMBTCPUMonitor?

    ///
    var ramMonitor: RMBTRAMMonitor?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        headline = L10n.Intro.Popup.Hardware.usage

        update()
    }

    ///
    private func b2mb(_ bytes: Float) -> Int {
        return Int(bytes / 1024 / 1024)
    }

    ///
    private func getMemoryUsePercent(_ used: NSNumber, _ free: NSNumber, _ total: NSNumber) -> Float {
        return (used.floatValue / total.floatValue) * 100.0 // TODO: is calculation correct? maybe use total physical ram?
    }

    ///
    override func update() {
        var cpuUsage = "-"

        cpuUsage = String(format: "%.01f%%", cpuMonitor?.getCPUUsage()[0].floatValue ?? 0)

        var systemRam = "-"
        var appRam = "-"

        let physicalMemory = NSNumber(value: ProcessInfo.processInfo.physicalMemory)
        let physicalMemoryMB = b2mb(physicalMemory.floatValue)

        if let memArray = ramMonitor?.getRAMUsage() {
            let memPercentUsedF = getMemoryUsePercent(memArray[0], memArray[1], /*memArray[2]*/physicalMemory)

            let memPercentUsed = String(format: "%.0f", memPercentUsedF)
            let memPercentUsedPerApp = String(format: "%.0f", getMemoryUsePercent(memArray[3], memArray[1], /*memArray[2]*/physicalMemory))

            systemRam = "\(memPercentUsed)% (\(b2mb(memArray[0].floatValue))/\(physicalMemoryMB) MB)"
            appRam = "\(memPercentUsedPerApp)% (\(b2mb(memArray[3].floatValue))/\(physicalMemoryMB) MB)"
        }

        data = [
            [L10n.Intro.Popup.Hardware.cpu, cpuUsage],
            [L10n.Intro.Popup.Hardware.systemRam, systemRam],
            [L10n.Intro.Popup.Hardware.appRam, appRam]
        ]

        super.update()
    }
}
