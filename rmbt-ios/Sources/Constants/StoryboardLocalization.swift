//
//  Fame.swift
//
//  Created by Alexander Schuch on 25/02/16.
//  Copyright (c) 2016 Alexander Schuch. All rights reserved.
//
import UIKit

/// Enables the fame Interface Builder integration
/// https://github.com/aschuch/fame
extension NSObject {

    ///
    @IBInspectable
    var i18n_enabled: Bool {
        get {
            return false
        }
        set {
            /* do nothing */
        }
    }

    ///
    @IBInspectable
    var i18n_comment: String? {
        get {
            return nil
        }
        set {
            /* do nothing */
        }
    }
}
