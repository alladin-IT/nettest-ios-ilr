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
class TopLevelViewController: UIViewController {

    ///
    @IBOutlet var sideBarButton: UIBarButtonItem?

    ///
    var revealControllerEnabled = true

//  var gesturesEnabled = true

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if revealControllerEnabled {
            if let rc = revealViewController() {
                // Assign action for the side button
                sideBarButton?.target = rc
                sideBarButton?.action = #selector(SWRevealViewController.revealToggle(_:))

                view.addGestureRecognizer(rc.edgeGestureRecognizer())
                view.addGestureRecognizer(rc.tapGestureRecognizer())

                rc.delegate = self
            }
        } else {
            if let s = sideBarButton, let index = navigationItem.leftBarButtonItems?.index(of: s) {
                navigationItem.leftBarButtonItems?.remove(at: index)
            }
        }
    }

    ///
/*    func setEnableGestures(enable: Bool) {
        gesturesEnabled = enable
        
        logger.debug("++++++++++++++++++++ \(enable)")
        
        for gr in view.gestureRecognizers ?? [] {
            if
                gr == revealViewController().panGestureRecognizer() ||
                gr == revealViewController().edgeGestureRecognizer() ||
                gr == revealViewController().tapGestureRecognizer() {
                gr.isEnabled = enable
            }
        }
        
        revealController(revealViewController(), didMoveTo: revealViewController().frontViewPosition)
        
        if enable {
            logger.debug("+++++++++++++++ if")
            
            //view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
            
            //revealController(revealViewController(), didMoveTo: revealViewController().frontViewPosition)
        } else {
            logger.debug("+++++++++++++++ else")
            
            logger.debug(view.gestureRecognizers)
            
            
            
            
            //view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            //view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            //view.removeGestureRecognizer(revealViewController().tapGestureRecognizer())
            
            logger.debug(view.gestureRecognizers)
        }
        
        logger.debug("+++++++++++++++ end")
    }*/
}

// MARK: SWRevealViewControllerDelegate

///
extension TopLevelViewController: SWRevealViewControllerDelegate {

/*    func revealControllerPanGestureShouldBegin(_ revealController: SWRevealViewController!) -> Bool {
        return gesturesEnabled
    }
*/
    /*func revealControllerTapGestureShouldBegin(_ revealController: SWRevealViewController!) -> Bool {
        return gesturesEnabled
    }*/

    ///
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        guard let rc = revealController else {
            return
        }

        let isPosLeft = position == .left

        if isPosLeft { // TODO: nil exception?
            view.removeGestureRecognizer(rc.panGestureRecognizer())
            view.addGestureRecognizer(rc.edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(rc.edgeGestureRecognizer())
            view.addGestureRecognizer(rc.panGestureRecognizer())
        }
    }
}
