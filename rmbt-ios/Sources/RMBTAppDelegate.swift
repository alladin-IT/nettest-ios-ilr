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
import GoogleMaps
import RMBTClient
import AVFoundation

///
final class RMBTAppDelegate: UIResponder, UIApplicationDelegate {

    ///
    var window: UIWindow?

    ///
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        LogConfig.initLoggingFramework()

        checkFirstLaunch()

        logger.debug("START APP \(RMBTAppTitle()) (customer: \(RMBTAppCustomerName()))")

        setDefaultUserAgent()

        // Supply Google Maps API Key only once during whole app lifecycle
        if RMBT_GMAPS_API_KEY.count > 0 {
            GMSServices.provideAPIKey(RMBT_GMAPS_API_KEY)
        }

        // set audio category to prevent nettest from stopping background music
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

        applyAppearance()
        onStart(true)

        /////////

        return true
    }

    ///
    func applicationDidEnterBackground(_ application: UIApplication) {
        RMBTLocationTracker.sharedTracker.stop()
    }

    ///
    func applicationWillEnterForeground(_ application: UIApplication) {
        onStart(false)
    }

    ///
    func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard

        if !userDefaults.bool(forKey: "was_launched_once") {
            logger.info("FIRST LAUNCH OF APP")

            userDefaults.set(true, forKey: "was_launched_once")

            firstLaunch(userDefaults)

            userDefaults.synchronize()
        }
    }

    ///
    func firstLaunch(_ userDefaults: UserDefaults) {
        /*if TEST_USE_PERSONAL_DATA_FUZZING {
            RMBTSettings.sharedSettings.publishPublicData = true
            logger.debug("setting publishPublicData to true")
        }*/
    }

    ///
    func onStart(_ isNewlyLaunched: Bool) {
        checkDevMode()

        logger.info("App started")

        let tos = RMBTTOS.sharedTOS

        if tos.isCurrentVersionAccepted() {
            // init control server here if terms are accepted
            afterTosAccepted()
        } else if isNewlyLaunched {
            // Re-check after TOS gets accepted, but don't re-add listener on every foreground

            tos.addObserver(self, forKeyPath: "lastAcceptedVersion", options: .new, context: nil)

            // the latter doesn't work :/
            //_ = tos.observe(\RMBTTOS.lastAcceptedVersion, options: .new) { (/*object, change*/_, _) in
            //    self.afterTosAccepted()
            //}
        }
    }

    ///
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        afterTosAccepted()
    }

    ///
    private func afterTosAccepted() {
        logger.debug("TOS accepted, checking news...")

        /*let alert = UIAlertController(title: "Registration…", message: "Client is being registered. Please wait…", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        var hostVC = self.window?.rootViewController
        
        while let next = hostVC?.presentedViewController {
            hostVC = next
        }
        
        hostVC?.present(alert, animated: true, completion: nil)*/

        RMBT.refreshSettings { // init control server here if terms recently got accepted

        }

        // If user has authorized location services, we should start tracking location now, so that when test starts,
        // we already have a more accurate location
        //_ = RMBTLocationTracker.sharedTracker.startIfAuthorized()
        /*startAfterDeterminingAuthorizationStatus() {}*/
        //_ = RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus() {}

        self.checkNews()
    }

    ///
    func checkNews() {
        /*ControlServer.sharedControlServer.getNews { (newsObj: AnyObject!) in
            let news = newsObj as! [News]

            for n in news {
                UIAlertView.bk_showAlertViewWithTitle(
                    n.title,
                    message: n.text,
                    cancelButtonTitle: NSLocalizedString("general.alertview.dismiss", value: "Dismiss", comment: "News alert view button"),
                    otherButtonTitles: nil,
                    handler: nil)
            }
        }*/
    }

    ///
    fileprivate func checkDevMode() {
        let RMBT_DEV_MODE_ENABLED_KEY = "RMBT_DEV_MODE_ENABLED"
        if let enabled = SharedKeychain.getBool(RMBT_DEV_MODE_ENABLED_KEY) {
            RMBTSettings.sharedSettings.debugUnlocked = enabled
        }

        logger.info("DEBUG UNLOCKED: \(RMBTSettings.sharedSettings.debugUnlocked)")
    }

    ///
    fileprivate func setDefaultUserAgent() {
        if let info = Bundle.main.infoDictionary {

            let bundleName = (info["CFBundleName"] as! String).replacingOccurrences(of: " ", with: "")
            let bundleVersion = info["CFBundleShortVersionString"] as! String

            let iosVersion = UIDevice.current.systemVersion

            let lang = RMBTPreferredLanguage()
            var locale = Locale.canonicalLanguageIdentifier(from: lang)

            if let countryCode = Locale.current.regionCode { //(Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
                locale += "-\(countryCode)"
            }

            // set global user agent
            let alladinUserAgent = "AlladinNetTest/2.0 (iOS; \(locale); \(iosVersion)) \(bundleName)/\(bundleVersion)"
            UserDefaults.standard.register(defaults: ["UserAgent": alladinUserAgent])
            UserDefaults.standard.synchronize() // is this needed?

            logger.info("USER AGENT: \(alladinUserAgent)")
        }
    }

    ///
    func applyAppearance() {
        //UIApplication.shared.statusBarStyle = .lightContent

        // Background color
        UINavigationBar.appearance().barTintColor = RMBT_DARK_COLOR

        // Tint color
        UINavigationBar.appearance().tintColor = RMBT_TINT_COLOR
        UITabBar.appearance().tintColor = RMBT_TINT_COLOR

        // Text color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: TEXT_COLOR]

        // alladin icon font for UIBarButtonItems
        let iconFontAttributes = [
            NSAttributedStringKey.font: UIFont(name: ICON_FONT_NAME, size: /*UIFont.labelFontSize*/32)!,
            NSAttributedStringKey.foregroundColor: RMBT_TINT_COLOR
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes(iconFontAttributes, for: .normal)
        //UIBarButtonItem.appearance().setTitleTextAttributes(iconFontAttributes, for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes(iconFontAttributes, for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes(iconFontAttributes, for: .disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes(iconFontAttributes, for: .focused)
        //UIBarButtonItem.appearance().setTitleTextAttributes(iconFontAttributes, for: .application)

        // TODO: icon font uibarbuttonitems are not aligned correctly
        //UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).
        //UIBarButtonItem.vertical

        //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundVerticalPositionAdjustment:-10 forBarMetrics:UIBarMetricsDefault];
        //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundVerticalPositionAdjustment:-10 forBarMetrics:UIBarMetricsLandscapePhone];
    }

}
