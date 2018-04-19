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
import KINWebBrowser
import RMBTClient

///
protocol ModalBrowser {

    ///
    func presentModalBrowserWithURLString(_ url: String)
}

///
extension UIViewController: ModalBrowser {

    ///
    func presentModalBrowserWithURLString(_ url: String) {
        if let webViewController = /*KINWebBrowserViewController*/CustomKINWebBrowserViewController.navigationControllerWithWebBrowser() {

            webViewController.navigationBar.isTranslucent = false // does this have any effect?

            // TODO?: change back button item to icon "v"

            // TODO: rewrite for loops to just change one specific element!
            let font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
            webViewController.navigationBar.items?.forEach({ (item) in
                item.leftBarButtonItems?.forEach({ (bi) in
                    bi.setTitleTextAttributesForAllStates([NSAttributedStringKey.font: font])
                })

                item.rightBarButtonItems?.forEach({ (bi) in
                    //bi.setTitleTextAttributes([NSAttributedStringKey.font: font], for: [.normal, .selected, .disabled, .highlighted, .focused])
                    bi.setTitleTextAttributesForAllStates([NSAttributedStringKey.font: font])
                })

                item.backBarButtonItem?.setTitleTextAttributesForAllStates([NSAttributedStringKey.font: font])
            })

            if let webBrowser = webViewController.rootWebBrowser() {
                webBrowser.loadURLString(RMBTLocalizeURLString(url))

                webBrowser.showsPageTitleInNavigationBar = false
                webBrowser.showsURLInNavigationBar = false

                //webBrowser.actionButtonHidden = false
                webBrowser.actionButtonHidden = true

                webBrowser.barTintColor = RMBT_DARK_COLOR
                webBrowser.tintColor = RMBT_TINT_COLOR
            }

            present(webViewController, animated: true, completion: nil)
        }
    }

}
