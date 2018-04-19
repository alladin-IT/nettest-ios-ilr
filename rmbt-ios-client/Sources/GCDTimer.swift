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

///
class GCDTimer {

    typealias TimerCallback = () -> ()

    ///
    var timerCallback: TimerCallback?

    ///
    var interval: Double?

    ///
    fileprivate var timer: DispatchSourceTimer?

    ///
    fileprivate let timerQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)

    ///
    init() {

    }

    ///
    deinit {
        stop()
    }

    ///
    func start() {
        if let interval = self.interval {
            stop() // stop any previous timer

            // start new timer
            timer = DispatchSource.makeTimerSource(queue: timerQueue)
            //let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.strict, queue: timerQueue)

            let nsecPerSec = Double(NSEC_PER_SEC)
            let dt = DispatchTime.now() + Double(Int64(interval * nsecPerSec)) / Double(NSEC_PER_SEC)

            timer?.schedule(deadline: dt, leeway: DispatchTimeInterval.seconds(0)) // TODO: is this correct?
            //timer.setTimer(start: dt, interval: DispatchTime.distantFuture, leeway: 0)

            timer?.setEventHandler {
                logger.debug("timer fired")
                self.stop()

                self.timerCallback?()
            }

            timer?.resume()
        }
    }

    ///
    func stop() {
        timer?.cancel()
        timer = nil
    }
}
