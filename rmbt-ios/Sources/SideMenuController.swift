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

///
class SideMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet private var menuTable: UITableView?

    ///
    private var menuItems: [String]

    ///
    private var selectedRow = 0

    ///
    //private var menuItemTitles: [String]

    ///
    private var prevSelectedRow: Int!

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        menuItems = ["home", "history", "map", "statistics", "help", "info", "settings"]
        //menuItemTitles = [L("menu.home"), L("menu.history"), L("menu.map"), L("menu.statistics"), L("menu.help")]

        if !USE_OPENDATA { // hide statistics
            if let i = menuItems.index(of: "statistics") {
                menuItems.remove(at: i)
                //menuItemTitles.remove(at: 3)
            }
        }

        if NO_MAP {
            if let i = menuItems.index(of: "map") {
                menuItems.remove(at: i)
            }
        }

        if customerIsPostlux() {
            if let i = menuItems.index(of: "map") {
                menuItems.remove(at: i)
            }
            if let i = menuItems.index(of: "statistics") {
                menuItems.remove(at: i)
            }
        }

        super.init(coder: aDecoder)
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = NAVIGATION_BACKGROUND_COLOR
        menuTable?.backgroundColor = NAVIGATION_BACKGROUND_COLOR

        menuTable?.separatorStyle = .none

        // select home
        let ip = IndexPath(row: selectedRow, section: 0)
        menuTable?.selectRow(at: ip, animated: false, scrollPosition: .top)
        _ = tableView(menuTable!, willSelectRowAt: ip)
    }

    ///
    func selectRow(identifier: String) { // TODO: enum
        if let index = menuItems.index(of: identifier) {
            selectedRow = index // menuTable is nil if the view wasn't shown before (if nobody tapped on the hamburger icon)

            if let m = menuTable {
                let ip = IndexPath(row: selectedRow, section: 0)
                m.selectRow(at: ip, animated: false, scrollPosition: .none)
                _ = tableView(m, willSelectRowAt: ip)
            }
        }
    }

// MARK: Navigation UITableViewDataSource / UITableViewDelegate

    ///
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: menuItems[indexPath.row])

        if cell != nil {
            cell.backgroundColor = NAVIGATION_BACKGROUND_COLOR
            cell.textLabel?.textColor = NAVIGATION_TEXT_COLOR
            cell.textLabel?.highlightedTextColor = NAVIGATION_TEXT_COLOR

            if NAVIGATION_USE_TINT_COLOR {
                // workaround because cell is not set up correctly (-> improve this in the future)
                for subview in cell.contentView.subviews {
                    if subview.isKind(of: UILabel.self) {
                        if let label = subview as? UILabel {
                            label.textColor = NAVIGATION_TEXT_COLOR

                            /*if (label.text?.characters.count ?? 0) > 1 { // otherwise it's the icon font...
                                label.text = menuItemTitles[indexPath.row]
                            }*/
                        }
                    }
                }
            }

            if let selectedBackgroundColor = NAVIGATION_SELECTED_BACKGROUND_VIEW_COLOR {
                cell.selectedBackgroundView = UIView()
                cell.selectedBackgroundView?.backgroundColor = selectedBackgroundColor
            }
        }

        return cell
    }

    ///
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if prevSelectedRow == nil {
            prevSelectedRow = 0 // first screen is home
        } else {
            prevSelectedRow = menuTable?.indexPathForSelectedRow?.row ?? -1 // is only -1 if info or settings are active
        }

        return indexPath
    }

// MARK: Methods

    ///
    @IBAction func deselectCellInTable() { // TODO: is this in use?
        if let index = menuTable?.indexPathForSelectedRow {
            menuTable?.deselectRow(at: index, animated: true)
        }

        prevSelectedRow = -1 // is only -1 if info or settings are active
    }

// MARK: Segue methods

    ///
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if /*identifier == "pushHomeViewController"       && prevSelectedRow == menuItems.index(of: "home")       ||*/
           identifier == "pushHistoryViewController"    && prevSelectedRow == menuItems.index(of: "history")    ||
           identifier == "pushMapViewController"        && prevSelectedRow == menuItems.index(of: "map")        ||
           identifier == "pushStatisticsViewController" && prevSelectedRow == menuItems.index(of: "statistics") ||
           identifier == "pushHelpViewController"       && prevSelectedRow == menuItems.index(of: "help")       ||
           identifier == "pushInfoViewController"       && prevSelectedRow == menuItems.index(of: "info")       ||
           identifier == "pushSettingsViewController"   && prevSelectedRow == menuItems.index(of: "settings") {

            revealViewController().revealToggle(animated: true)
            return false
        }

        return true
    }
}
