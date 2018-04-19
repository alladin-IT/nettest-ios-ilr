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

// TODO: is copyright from specure still needed? (better add copyright from appscape)

import Foundation
import RMBTClientDNS

///
typealias DNSTestExecutor = QOSDNSTestExecutor<QOSDNSTest>

///
class QOSDNSTestExecutor<T: QOSDNSTest>: QOSTestExecutorClass<T> {

    private let RESULT_DNS_STATUS           = "dns_result_status"
    private let RESULT_DNS_ENTRY            = "dns_result_entries"
    private let RESULT_DNS_TTL              = "dns_result_ttl"
    private let RESULT_DNS_ADDRESS          = "dns_result_address"
    private let RESULT_DNS_PRIORITY         = "dns_result_priority"
    private let RESULT_DNS_DURATION         = "dns_result_duration"
    private let RESULT_DNS_QUERY            = "dns_result_info"
    private let RESULT_DNS_RESOLVER         = "dns_objective_resolver"
    private let RESULT_DNS_HOST             = "dns_objective_host"
    private let RESULT_DNS_RECORD           = "dns_objective_dns_record"
    private let RESULT_DNS_ENTRIES_FOUND    = "dns_result_entries_found"
    private let RESULT_DNS_TIMEOUT          = "dns_objective_timeout"

    //

    ///
    override init(delegateQueue: DispatchQueue, testObject: T, speedtestStartTime: UInt64) {
        super.init(delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }

    ///
    override func startTest() {
        super.startTest()

        testResult.set(RESULT_DNS_RESOLVER, string: testObject.resolver ?? "Standard")
        testResult.set(RESULT_DNS_RECORD,   string: testObject.record)
        testResult.set(RESULT_DNS_HOST,     string: testObject.host)
        testResult.set(RESULT_DNS_TIMEOUT,  number: testObject.timeout)
        
        // set default values here instead of setting them in testDid{Fail,Timeout}
        testResult.set(RESULT_DNS_ENTRY, value: nil)
        testResult.set(RESULT_DNS_ENTRIES_FOUND, number: 0)
    }

    ///
    override func executeTest() {

        if let host = testObject.host {
            qosLog.debug("EXECUTING DNS TEST")

            var entries = [[String: AnyObject]]()
            
            let startTimeTicks = getCurrentTimeTicks()

            let recordType = self.testObject.recordType()
            if recordType == ns_t_invalid {
                testDidFail()
            }
            
            var res = __res_9_state()
            if res_9_ninit(&res) != 0 {
                // TODO: free?
                testDidFail()
            }
            
            res.retry = 1
            res.retrans = max(1, Int32(testObject.timeout / NSEC_PER_SEC))
            
            // set custom resolver
            if let resolver = testObject.resolver {
                var addr = in_addr()
                inet_aton(resolver.cString(using: .ascii), &addr)
                
                res.nsaddr_list.0.sin_addr = addr
                res.nsaddr_list.0.sin_family = sa_family_t(AF_INET) // TODO: support ipv6 name servers
                res.nsaddr_list.0.sin_port = in_port_t(53).bigEndian // TODO: support other dns server port
                res.nscount = 1
            }
            
            var rcodeStr: String?
            
            // TODO: check if stopped?
            
            var answer = [CUnsignedChar](repeating: 0, count: Int(NS_PACKETSZ))
            
            let len: CInt = res_9_nquery(&res, host.cString(using: .ascii), Int32(ns_c_in.rawValue), Int32(recordType.rawValue), &answer, Int32(answer.count))
            
            testResult.set(RESULT_DNS_DURATION, number: getTimeDifferenceInNanoSeconds(startTimeTicks))
            
            if len == -1 {
                if h_errno == HOST_NOT_FOUND {
                    rcodeStr = "NXDOMAIN"
                } else if h_errno == TRY_AGAIN {
                    testDidTimeout()
                    return
                }
            } else {
                var handle = __ns_msg()
                res_9_ns_initparse(&answer, len, &handle)
                
                let rcode = res_9_ns_msg_getflag(handle, Int32(ns_f_rcode.rawValue))
                if let rcodeCStr = res_9_p_rcode(rcode) {
                    rcodeStr = String(cString: rcodeCStr, encoding: .ascii)! // TODO: !
                } else {
                    rcodeStr = "UNKNOWN" // or ERROR?
                }
                
                qosLog.debug("rcodeStr: \(String(describing: rcodeStr))")
                testResult.set(RESULT_DNS_STATUS, string: rcodeStr)
                
                assert(ns_s_an.rawValue == 1, "ns_s_an constant not 1 anymore")
                let answerCount = handle._counts.1
                
                if answerCount > 0 {
                    var rr = __ns_rr()
                    
                    for i in 0..<answerCount {
                        // TODO: check if stopped?
                        
                        if res_9_ns_parserr(&handle, ns_s_an, Int32(i), &rr) == 0 {
                            var entry = [String: AnyObject]()
                            
                            let ttl = rr.ttl // TODO: dns_result_ttl
                            qosLog.debug("ttl: \(ttl)")
                            entry[RESULT_DNS_TTL] = "\(ttl)" as AnyObject?
                            
                            let uint32_rr_type = UInt32(rr.type)
                            
                            if uint32_rr_type == ns_t_a.rawValue {
                                var buf = [Int8](repeating: 0, count: Int(INET_ADDRSTRLEN + 1)) // why +1?
                                
                                if inet_ntop(AF_INET, rr.rdata, &buf, socklen_t(INET_ADDRSTRLEN)) != nil {
                                    let resultStr = String(cString: buf, encoding: .ascii) // TODO
                                    qosLog.debug("resultStr: \(String(describing: resultStr))")
                                    entry[RESULT_DNS_ADDRESS] = resultStr as AnyObject?
                                }
                            } else if uint32_rr_type == ns_t_aaaa.rawValue {
                                var buf = [Int8](repeating: 0, count: Int(INET6_ADDRSTRLEN + 1)) // why +1?
                                
                                if inet_ntop(AF_INET6, rr.rdata, &buf, socklen_t(INET6_ADDRSTRLEN)) != nil {
                                    let resultStr = String(cString: buf, encoding: .ascii) // TODO
                                    qosLog.debug("resultStr: \(String(describing: resultStr))")
                                    entry[RESULT_DNS_ADDRESS] = resultStr as AnyObject?
                                }
                            } else if uint32_rr_type == ns_t_mx.rawValue || uint32_rr_type == ns_t_cname.rawValue {
                                var buf = [Int8](repeating: 0, count: Int(NS_MAXDNAME))
                                
                                if res_9_ns_name_uncompress(handle._msg, handle._eom, rr.rdata, &buf, buf.count) != -1 {
                                    let resultStr = String(cString: buf, encoding: .ascii) // TODO
                                    qosLog.debug("resultStr: \(String(describing: resultStr))")
                                    entry[RESULT_DNS_ADDRESS] = resultStr as AnyObject?
                                    
                                    if uint32_rr_type == ns_t_mx.rawValue {
                                        let priority = res_9_ns_get16(rr.rdata) // TODO
                                        qosLog.debug("resultStr: \(priority)")
                                        entry[RESULT_DNS_PRIORITY] = "\(priority)" as AnyObject?
                                    }
                                }
                            }
                            
                            entries.append(entry)
                        }
                    }
                }
            }
            
            res_9_ndestroy(&res)
            
            testResult.set(RESULT_DNS_ENTRIES_FOUND, number: entries.count)
            if entries.count > 0 {
                testResult.set(RESULT_DNS_ENTRY, value: entries as NSArray) // cast needed to prevent "HStore format unsupported"
            }
            
            testDidSucceed()
        }
    }

    ///
    override func testDidSucceed() {
        testResult.set(RESULT_DNS_QUERY, status: .ok)

        super.testDidSucceed()
    }

    ///
    override func testDidTimeout() {
        testResult.set(RESULT_DNS_QUERY, status: .timeout)

        super.testDidTimeout()
    }

    ///
    override func testDidFail() {
        testResult.set(RESULT_DNS_QUERY, status: .error)

        super.testDidFail()
    }
}
