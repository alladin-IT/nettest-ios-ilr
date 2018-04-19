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

/// shorthand method for NSLocalizedString with key as comment
func L(_ key: String) -> String {
    return NSLocalizedString(key, comment: key)
}

/// shorthand method for NSLocalizedString
func L(_ key: String, comment: String) -> String {
    return NSLocalizedString(key, comment: comment)
}

/// shorthand method for NSLocalizedString with key and value as comment
func L(_ key: String, value: String) -> String {
    return NSLocalizedString(key, value: value, comment: "\(key): \(value)")
}

/// shorthand method for NSLocalizedString
func L(_ key: String, value: String, comment: String) -> String {
    return NSLocalizedString(key, value: value, comment: comment)
}

/// shorthand method for NSLocalizedString
func L(_ key: String, tableName: String?, bundle: Bundle, value: String, comment: String) -> String {
    return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
}

/*
///
func LF(_ key: String, _ arguments: CVarArg...) -> String {
    return withVaList(arguments) {
        //String.localizedStringWithFormat(L(key), arguments: $0) // doesn't work with withVaList, also doesn't work with %n$@ notations
        (NSString(format: L(key), arguments: $0) as String)
    } as String
}

///
func LF(_ key: String, comment: String, _ arguments: CVarArg...) -> String {
    return withVaList(arguments) {
        (NSString(format: L(key, comment: comment), arguments: $0) as String)
    } as String
}

///
func LF(_ key: String, value: String, _ arguments: CVarArg...) -> String {
    return withVaList(arguments) {
        (NSString(format: L(key, value: value), arguments: $0) as String)
    } as String
}

///
func LF(_ key: String, value: String, comment: String, _ arguments: CVarArg...) -> String {
    return withVaList(arguments) {
        (NSString(format: L(key, value: value, comment: comment), arguments: $0) as String)
    } as String
}
*/
