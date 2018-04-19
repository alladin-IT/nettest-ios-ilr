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
import Security

///
open class SharedKeychain {

    ///
    fileprivate init() {

    }

// MARK: get functions

    ///
    open class func getBool(_ key: String) -> Bool? {
        if let stringValue = get(key) {
            return stringValue == "true"
        }

        return nil
    }

    ///
    open class func get(_ key: String) -> String? {
        if let currentData = getData(key) {
            return NSString(data: currentData, encoding: String.Encoding.utf8.rawValue) as String?
        }

        return nil
    }

    ///
    open class func getData(_ key: String) -> Data? {
        let query: [AnyHashable: Any] = [
            kSecClass as AnyHashable:          kSecClassGenericPassword,
            kSecAttrAccount as AnyHashable:    key,
            kSecReturnData as AnyHashable:     kCFBooleanTrue,
            kSecMatchLimit as AnyHashable:     kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        }

        return nil
    }

// MARK: set functions

    ///
    open class func set(_ key: String, value: Bool) -> Bool {
        return set(key, value: "\(value)")
    }

    ///
    open class func set(_ key: String, value: Int) -> Bool {
        return set(key, value: "\(value)")
    }

    ///
    open class func set(_ key: String, value: String) -> Bool {
        if let currentData = value.data(using: String.Encoding.utf8) {
            return set(key, value: currentData)
        }
        return false
    }

    ///
    open class func set(_ key: String, value: Data) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        return status == noErr
    }

// MARK: delete functions

    ///
    open class func delete(_ key: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String : Any]

        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == noErr
    }

// MARK: clear functions

    ///
    open class func clear() -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == noErr
    }

}
