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
import UIKit

///
class TopLevelTableViewController: UITableViewController {

    ///
    @IBOutlet fileprivate var sideBarButton: UIBarButtonItem?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Assign action for the side button
        sideBarButton?.target = revealViewController()
        sideBarButton?.action = #selector(SWRevealViewController.revealToggle(_:))

        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())

        revealViewController().delegate = self
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension TopLevelTableViewController: SWRevealViewControllerDelegate {

    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        tableView?.isScrollEnabled = false
    }

    ///
    func revealControllerPanGestureEnded(_ revealController: SWRevealViewController!) {
        tableView?.isScrollEnabled = true
    }

    ///
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        guard let rc = revealController else {
            return
        }

        let isPosLeft = position == .left

        tableView?.isScrollEnabled = isPosLeft
        tableView?.allowsSelection = isPosLeft

        if isPosLeft {
            view.removeGestureRecognizer(rc.panGestureRecognizer())
            view.addGestureRecognizer(rc.edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(rc.edgeGestureRecognizer())
            view.addGestureRecognizer(rc.panGestureRecognizer())
        }
    }
}
