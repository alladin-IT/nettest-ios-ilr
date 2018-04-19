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

import UIKit
import KINWebBrowser
import RMBTClient

///
class StatisticsViewController: TopLevelViewController {

    ///
    private let webBrowser = CustomKINWebBrowserViewController()/*KINWebBrowserViewController*/

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = UIColor.white

        //webBrowser.delegate = self

        webBrowser.showsPageTitleInNavigationBar = false
        webBrowser.showsURLInNavigationBar = false
        //webBrowser.actionButtonHidden = false
        webBrowser.actionButtonHidden = true
        webBrowser.barTintColor = RMBT_DARK_COLOR
        webBrowser.tintColor = RMBT_TINT_COLOR

        //logger.info("requesting statistics at \(RMBTLocalizeURLString(RMBT_STATS_URL))")
        webBrowser.loadURLString(RMBTLocalizeURLString(RMBT_STATS_URL))

        addChildViewController(webBrowser)

        view.addSubview(webBrowser.view)

        navigationController?.setToolbarHidden(true, animated: false)
        //setToolbarItems(webBrowser.toolbarItems!, animated: false) // TODO: do we need the toolbar items?
    }

    ///
    fileprivate func enableWebBrowser(_ enabled: Bool) {
        webBrowser.uiWebView?.scrollView.isScrollEnabled = enabled
        webBrowser.wkWebView?.scrollView.isScrollEnabled = enabled

        webBrowser.view.isUserInteractionEnabled = enabled
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension StatisticsViewController {

    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        enableWebBrowser(false)
    }

    ///
    func revealControllerPanGestureEnded(_ revealController: SWRevealViewController!) {
        enableWebBrowser(true)
    }

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)

        enableWebBrowser(position == .left)
    }
}
