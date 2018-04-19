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
import ObjectMapper

///
open class SpeedMeasurementSourcePortMap: Mappable, CustomStringConvertible {
    
    ///
    public enum Direction {
        case down, up
    }
    
    ///
    var downloadSourcePorts = [String: Int]()
    
    ///
    var uploadSourcePorts = [String: Int]()
    
    //
    
    ///
    init() {
        
    }
    
    ///
    required public init?(map: Map) {
        
    }
    
    ///
    open func mapping(map: Map) {
        downloadSourcePorts <- map["source_port_map_dl"]
        uploadSourcePorts   <- map["source_port_map_ul"]
    }

    ///
    open var description: String {
        return "SpeedMeasurementSourcePortMap  (downloadSourcePorts = \(downloadSourcePorts)), uploadSourcePorts = \(uploadSourcePorts)))"
    }
}
