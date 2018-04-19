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
//import RMBTClientPrivate
import Darwin
import CommonCrypto

///
extension Int {

    func hexString() -> String {
        return String(format: "%02x", self)
    }

}

///
extension Data {

    ///
    func hexString() -> String { // TODO: maybe rename to something like hexEncodedString? http://stackoverflow.com/questions/39075043/how-to-convert-data-to-hex-string-in-swift
        return map { String(format: "%02hhx", $0) }.joined()
    }

    ///
    func MD5() -> Data { // TODO: http://stackoverflow.com/questions/32163848/how-to-convert-string-to-md5-hash-using-ios-swift
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes { digestBytes in
            withUnsafeBytes { bytes in
                CC_MD5(bytes, CC_LONG(self.count), digestBytes)
            }
        }

        return digestData
    }

    ///
    func SHA1() -> Data {
        var digestData = Data(count: Int(CC_SHA1_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes { digestBytes in
            withUnsafeBytes { bytes in
                CC_SHA1(bytes, CC_LONG(self.count), digestBytes)
            }
        }

        return digestData
    }

}
