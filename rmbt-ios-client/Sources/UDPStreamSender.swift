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
import CocoaAsyncSocket

///
struct UDPStreamSenderSettings {
    var host: String
    var port: UInt16 = 0
    var delegateQueue: DispatchQueue
    var sendResponse: Bool = false
    var maxPackets: UInt16 = 5
    var timeout: UInt64 = 10_000_000_000
    var delay: UInt64 = 10_000
    var writeOnly: Bool = false
    var portIn: UInt16?
}

///
class UDPStreamSender: NSObject {

    ///
    fileprivate let streamSenderQueue = DispatchQueue(label: "at.alladin.rmbt.udp.streamSenderQueue"/*, attributes: DispatchQueue.Attributes.concurrent*/)

    ///
    fileprivate var udpSocket: GCDAsyncUdpSocket?

    ///
    fileprivate let countDownLatch = CountDownLatch()

    ///
    fileprivate var running = AtomicBoolean()

    //

    ///
    var delegate: UDPStreamSenderDelegate?

    ///
    fileprivate let settings: UDPStreamSenderSettings

    //

    ///
    fileprivate var packetsReceived: UInt16 = 0

    ///
    fileprivate var packetsSent: UInt16 = 0

    ///
    fileprivate let delayMS: UInt64

    ///
    fileprivate let timeoutMS: UInt64

    ///
    fileprivate let timeoutSec: Double

    ///
    fileprivate var lastSentTimestampMS: UInt64 = 0

    ///
    fileprivate var usleepOverhead: UInt64 = 0

    //

    ///
    required init(settings: UDPStreamSenderSettings) {
        self.settings = settings

        delayMS = settings.delay / NSEC_PER_MSEC
        timeoutMS = settings.timeout / NSEC_PER_MSEC

        timeoutSec = nsToSec(settings.timeout)
    }

    ///
    func stop() {
        _ = running.testAndSet(false)
    }

    ///
    fileprivate func connect() {
        logger.debug("connecting udp socket (sender)")
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: streamSenderQueue)

        //

        do {
            if let portIn = settings.portIn {
                logger.debug("BINDING TO PORT \(portIn) (sender)")
                try udpSocket?.bind(toPort: portIn)
            }

            try udpSocket?.connect(toHost: settings.host, onPort: settings.port)

            _ = countDownLatch.await(200 * NSEC_PER_MSEC)

            //

            if !settings.writeOnly {
                try udpSocket?.beginReceiving()
            }
        } catch {
            logger.debug("bindToPort error?: \(error)")
            logger.debug("connectToHost error?: \(error)") // TODO: check error (i.e. fail if error)
            logger.debug("receive error?: \(error)") // TODO: check error (i.e. fail if error)
        }
    }

    ///
    fileprivate func close() {
        logger.debug("closing udp socket")
        //udpSocket?.closeAfterSending()
        udpSocket?.close()
        udpSocket = nil
    }

    ///
    func send() -> Bool {
        connect()

        let startTimeMS = currentTimeMillis()
        let stopTimeMS: UInt64 = (timeoutMS > 0) ? timeoutMS + startTimeMS : 0

        //

        var dataToSend = Data()
        var shouldSend = false

        //

        var hasTimeout = false

        _ = running.testAndSet(true)

        while running.boolValue {

            ////////////////////////////////////
            // check if should stop

            if stopTimeMS > 0 && stopTimeMS < currentTimeMillis() {
                logger.debug("stopping because of stopTimeMS")

                hasTimeout = true
                break
            }

            ////////////////////////////////////
            // check delay

            //logger.verbose("currentTimeMS: \(currentTimeMillis()), lastSentTimestampMS: \(self.lastSentTimestampMS)")

            var currentDelay = currentTimeMillis() - lastSentTimestampMS + usleepOverhead
            //logger.verbose("current delay: \(currentDelay)")

            currentDelay = (currentDelay > delayMS) ? 0 : delayMS - currentDelay
            //logger.verbose("current delay2: \(currentDelay)")

            if currentDelay > 0 {
                let sleepMicroSeconds = UInt32(currentDelay * 1000)

                let sleepDelay = currentTimeMillis()

                usleep(sleepMicroSeconds) // TODO: usleep has an average overhead of about 0-5ms!

                let usleepCurrentOverhead = currentTimeMillis() - sleepDelay

                if usleepCurrentOverhead > 20 {
                    usleepOverhead = usleepCurrentOverhead - currentDelay
                } else {
                    usleepOverhead = 0
                }

                //logger.verbose("usleep for \(currentDelay)ms took \(usleepCurrentOverhead)ms (overhead \(self.usleepOverhead))")
            }

            ////////////////////////////////////
            // send packet

            if packetsSent < settings.maxPackets {
                dataToSend.count = 0

                shouldSend = self.delegate?.udpStreamSender(self, willSendPacketWithNumber: self.packetsSent, data: &dataToSend) ?? false

                if shouldSend {
                    lastSentTimestampMS = currentTimeMillis()

                    udpSocket?.send(dataToSend as Data, withTimeout: timeoutSec, tag: Int(packetsSent)) // TAG == packet number

                    packetsSent += 1

                    //lastSentTimestampMS = currentTimeMillis()
                }
            }

            ////////////////////////////////////
            // check for stop

            if settings.writeOnly {
                if packetsSent >= settings.maxPackets {
                    logger.debug("stopping because packetsSent >= settings.maxPackets")
                    break
                }
            } else {
                if packetsSent >= settings.maxPackets && packetsReceived >= settings.maxPackets {
                    logger.debug("stopping because packetsSent >= settings.maxPackets && packetsReceived >= settings.maxPackets")
                    break
                }
            }
        }

        stop()
        close()

        logger.debug("UDP AFTER SEND RETURNS \(!hasTimeout)")

        return !hasTimeout
    }

    ///
    fileprivate func receivePacket(_ dataReceived: Data, fromAddress address: Data) { // TODO: use dataReceived
        if packetsReceived < settings.maxPackets {
            packetsReceived += 1

            // call callback
            settings.delegateQueue.async {
                _ = self.delegate?.udpStreamSender(self, didReceivePacket: dataReceived)
                return
            }
        }
    }

}

// MARK: GCDAsyncUdpSocketDelegate methods

///
extension UDPStreamSender: GCDAsyncUdpSocketDelegate {

    ///
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        logger.debug("didConnectToAddress: address: \(address)")
        logger.debug("didConnectToAddress: local port: \(sock.localPort())")

        settings.delegateQueue.async {
            self.delegate?.udpStreamSender(self, didBindToPort: sock.localPort())
            return
        }

        countDownLatch.countDown()
    }

    ///
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        logger.debug("didNotConnect: \(String(describing: error))")
    }

    ///
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        // logger.debug("didSendDataWithTag: \(tag)")
    }

    ///
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        logger.debug("didNotSendDataWithTag: \(String(describing: error))")
    }

    ///
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        // logger.debug("didReceiveData: \(data)")

        // dispatch_async(streamSenderQueue) {
            if self.running.boolValue {
                self.receivePacket(data, fromAddress: address)
            }
        // }
    }

    ///
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) { // crashes if NSError is used without questionmark
        logger.debug("udpSocketDidClose: \(String(describing: error))")
    }

}
