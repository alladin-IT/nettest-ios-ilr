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
extension String {
    
    ///
    public func isValidIPAddress() -> Bool {
        return isValidIPv4Address() || isValidIPv6Address()
    }
    
    ///
    public func isValidIPv4Address() -> Bool {
        var dst = in_addr()
        return inet_pton(AF_INET, cString(using: .ascii), &dst) == 1
    }
    
    ///
    public func isValidIPv6Address() -> Bool {
        var dst = in6_addr()
        return inet_pton(AF_INET6, cString(using: .ascii), &dst) == 1
    }
    
    ///
    public func convertIPToNSData() -> NSData? {
        let cStr = cString(using: .ascii)
        var data: NSData?
        
        if isValidIPv4Address() {
            var ip = sockaddr_in()

            //ip.sin_len =
            ip.sin_family = sa_family_t(AF_INET)
            ip.sin_addr.s_addr = inet_addr(cStr) // why not use inet_pton?
            
            data = NSData(bytes: &ip, length: /*Int(ip.sin_len)*/MemoryLayout<sockaddr_in>.size)
        } else if isValidIPv6Address() {
            var ip = sockaddr_in6()
            
            //ip.sin6_len =
            ip.sin6_family = sa_family_t(AF_INET6)
            
            inet_pton(AF_INET6, cStr, &ip.sin6_addr.__u6_addr) // TODO: return value if
            
            data = NSData(bytes: &ip, length: /*Int(ip.sin6_len)*/MemoryLayout<sockaddr_in6>.size)
        }
        
        return data
    }
}
