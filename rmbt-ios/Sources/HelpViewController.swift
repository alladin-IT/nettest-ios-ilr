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

import UIKit
import RMBTClient

///
class HelpViewController: TopLevelViewController {

    ///
    @IBOutlet fileprivate var helpView: UIWebView?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: RMBTLocalizeURLString(RMBT_HELP_URL))
        //logger.debug("LOADING HELP URL \(url?.absoluteString)")
        let urlRequest = URLRequest(url: url!) // TODO: !

        // TODO: use KINWebBrowser to get back/forward buttons like statistics

        helpView?.loadRequest(urlRequest)
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension HelpViewController {

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)
        helpView?.scrollView.isScrollEnabled = position == FrontViewPosition.left
    }
}
