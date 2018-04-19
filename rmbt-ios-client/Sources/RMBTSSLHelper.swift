/***************************************************************************
 * Copyright 2013 appscape gmbh
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
class RMBTSSLHelper {

    ///
    fileprivate init() {

    }

    ///
    class func encryptionStringForSSLContext(_ sslContext: SSLContext) -> String {
        return "\(encryptionProtocolStringForSSLContext(sslContext)) (\(encryptionCipherStringForSSLContext(sslContext)))"
    }

    ///
    class func encryptionProtocolStringForSSLContext(_ sslContext: SSLContext) -> String {
        var sslProtocol: SSLProtocol = .sslProtocolUnknown
        SSLGetNegotiatedProtocolVersion(sslContext, &sslProtocol)

        switch sslProtocol {
            case .sslProtocolUnknown: return "No Protocol"
            case .sslProtocol2:       return "SSLv2"
            case .sslProtocol3:       return "SSLv3"
            case .sslProtocol3Only:   return "SSLv3 Only"
            case .tlsProtocol1:       return "TLSv1"
            case .tlsProtocol11:      return "TLSv1.1"
            case .tlsProtocol12:      return "TLSv1.2"
            default:                  return "other protocol: \(sslProtocol)"
        }
    }

    ///
    class func encryptionCipherStringForSSLContext(_ sslContext: SSLContext) -> String {
        var cipher = SSLCipherSuite()
        SSLGetNegotiatedCipher(sslContext, &cipher)

        switch cipher {
            case SSL_RSA_WITH_RC4_128_MD5:    return "SSL_RSA_WITH_RC4_128_MD5"
            case SSL_NO_SUCH_CIPHERSUITE:     return "No Cipher"
            default:                          return String(format: "%X", cipher)
        }
    }
}
