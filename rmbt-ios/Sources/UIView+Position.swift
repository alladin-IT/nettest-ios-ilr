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
import UIKit

///
protocol Position {

}

///
extension UIView: Position {

// MARK: frameOrigin

    ///
    var frameOrigin: CGPoint {
        get { return self.frame.origin }
        set {
            var rect = self.frame
            rect.origin = newValue
            self.frame = rect
        }
    }

// MARK: frameSize

    ///
    var frameSize: CGSize {
        get { return self.frame.size }
        set {
            var rect = self.frame
            rect.size = newValue
            self.frame = rect
        }
    }

// MARK: frameX

    ///
    var frameX: CGFloat {
        get { return self.frame.origin.x }
        set {
            var rect = self.frame
            rect.origin.x = newValue
            self.frame = rect
        }
    }

// MARK: frameY

    ///
    var frameY: CGFloat {
        get { return self.frame.origin.y }
        set {
            var rect = self.frame
            rect.origin.y = newValue
            self.frame = rect
        }
    }

// MARK: frameRight

    ///
    var frameRight: CGFloat {
        get {
            let rect = self.frame
            return rect.origin.x + rect.size.width
        }
        set {
            var rect = self.frame
            rect.origin.x = newValue - rect.size.width
            self.frame = rect
        }
    }

// MARK: frameBottom

    ///
    var frameBottom: CGFloat {
        get {
            let rect = self.frame
            return rect.origin.y + rect.size.height
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue - rect.size.height
            self.frame = rect
        }
    }

// MARK: frameWidth

    ///
    var frameWidth: CGFloat {
        get { return self.frame.size.width }
        set {
            var rect = self.frame
            rect.size.width = newValue
            self.frame = rect
        }
    }

// MARK: frameHeight

    ///
    var frameHeight: CGFloat {
        get { return self.frame.size.height }
        set {
            var rect = self.frame
            rect.size.height = newValue
            self.frame = rect
        }
    }

// MARK: boundsOrigin

    ///
    var boundsOrigin: CGPoint {
        get { return self.bounds.origin }
        set {
            var rect = self.bounds
            rect.origin = newValue
            self.bounds = rect
        }
    }

// MARK: boundsSize

    ///
    var boundsSize: CGSize {
        get { return self.bounds.size }
        set {
            var rect = self.bounds
            rect.size = newValue
            self.bounds = rect
        }
    }

// MARK: boundsX

    ///
    var boundsX: CGFloat {
        get { return self.bounds.origin.x }
        set {
            var rect = self.bounds
            rect.origin.x = newValue
            self.bounds = rect
        }
    }

// MARK: boundsY

    ///
    var boundsY: CGFloat {
        get { return self.bounds.origin.y }
        set {
            var rect = self.bounds
            rect.origin.y = newValue
            self.bounds = rect
        }
    }

// MARK: boundsRight

    ///
    var boundsRight: CGFloat {
        get {
            let rect = self.bounds
            return rect.origin.x + rect.size.width
        }
        set {
            var rect = self.bounds
            rect.origin.x = newValue - rect.size.width
            self.bounds = rect
        }
    }

// MARK: boundsBottom

    ///
    var boundsBottom: CGFloat {
        get {
            let rect = self.bounds
            return rect.origin.y + rect.size.height
        }
        set {
            var rect = self.bounds
            rect.origin.y = newValue - rect.size.height
            self.bounds = rect
        }
    }

// MARK: boundsWidth

    ///
    var boundsWidth: CGFloat {
        get { return self.bounds.size.width }
        set {
            var rect = self.bounds
            rect.size.width = newValue
            self.bounds = rect
        }
    }

// MARK: boundsHeight

    ///
    var boundsHeight: CGFloat {
        get { return self.bounds.size.height }
        set {
            var rect = self.bounds
            rect.size.height = newValue
            self.bounds = rect
        }
    }

// MARK: centerX

    ///
    var centerX: CGFloat {
        get { return self.center.x }
        set {
            var point = self.center
            point.x = newValue
            self.center = point
        }
    }

// MARK: centerY

    ///
    var centerY: CGFloat {
        get { return self.center.y }
        set {
            var point = self.center
            point.y = newValue
            self.center = point
        }
    }
}
