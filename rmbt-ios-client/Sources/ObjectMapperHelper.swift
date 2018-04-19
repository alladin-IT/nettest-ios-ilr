/***************************************************************************
 * Copyright 2016 SPECURE GmbH
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
import ObjectMapper

///
let UInt64NSNumberTransformOf = TransformOf<UInt64, NSNumber>(
    fromJSON: { $0?.uint64Value },
    toJSON: { $0.map { NSNumber(value: $0) }}
)

///
let UInt16NSNumberTransformOf = TransformOf<UInt16, NSNumber>(
    fromJSON: { $0?.uint16Value },
    toJSON: { $0.map { NSNumber(value: $0) }}
)

///
let UIntNSNumberTransformOf = TransformOf<UInt, NSNumber>(
    fromJSON: { $0?.uintValue },
    toJSON: { $0.map { NSNumber(value: $0) }}
)

///
/*let StringColorTransformOf = TransformOf<UIColor, String>(
    fromJSON: { UIColor(hexString: $0) },
    toJSON: { $0.map { $0.hexString }}
)*/
