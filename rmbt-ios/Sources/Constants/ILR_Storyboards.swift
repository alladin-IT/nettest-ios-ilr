// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum History: StoryboardType {
    static let storyboardName = "History"

    static let uiTableViewControllerDGO3RSYf = SceneType<RMBT.MeasurementResultTableViewController>(storyboard: History.self, identifier: "UITableViewController-dGO-3R-SYf")

    static let uiTableViewControllerOulBURI9 = SceneType<RMBT.HistoryTableViewController>(storyboard: History.self, identifier: "UITableViewController-oul-BU-rI9")
  }
  enum ILRMain: StoryboardType {
    static let storyboardName = "ILR_Main"

    static let initialScene = InitialSceneType<SWRevealViewController>(storyboard: ILRMain.self)

    static let swRevealViewController = SceneType<SWRevealViewController>(storyboard: ILRMain.self, identifier: "SWRevealViewController")

    static let measurementViewController = SceneType<RMBT.ILRMeasurementViewController>(storyboard: ILRMain.self, identifier: "measurement_view_controller")

    static let startViewController = SceneType<RMBT.ILRStartViewController>(storyboard: ILRMain.self, identifier: "start_view_controller")
  }
  enum Info: StoryboardType {
    static let storyboardName = "Info"

    static let initialScene = InitialSceneType<RMBT.InfoViewController>(storyboard: Info.self)
  }
  enum LaunchScreenILR: StoryboardType {
    static let storyboardName = "LaunchScreenILR"

    static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreenILR.self)
  }
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let initialScene = InitialSceneType<SWRevealViewController>(storyboard: Main.self)

    static let swRevealViewController = SceneType<SWRevealViewController>(storyboard: Main.self, identifier: "SWRevealViewController")

    static let hardwarePopup = SceneType<RMBT.HardwarePopupViewController>(storyboard: Main.self, identifier: "hardware_popup")

    static let ipPopup = SceneType<RMBT.IpPopupViewController>(storyboard: Main.self, identifier: "ip_popup")

    static let locationPopup = SceneType<RMBT.LocationPopupViewController>(storyboard: Main.self, identifier: "location_popup")

    static let measurementViewController = SceneType<RMBT.NKOMMeasurementViewController>(storyboard: Main.self, identifier: "measurement_view_controller")

    static let startViewController = SceneType<RMBT.NKOMStartViewController>(storyboard: Main.self, identifier: "start_view_controller")

    static let trafficPopup = SceneType<RMBT.TrafficPopupViewController>(storyboard: Main.self, identifier: "traffic_popup")
  }
  enum Map: StoryboardType {
    static let storyboardName = "Map"

    static let initialScene = InitialSceneType<RMBT.RMBTMapViewController>(storyboard: Map.self)
  }
  enum QosResult: StoryboardType {
    static let storyboardName = "QosResult"

    static let initialScene = InitialSceneType<RMBT.QosMeasurementNewIndexViewController>(storyboard: QosResult.self)

    static let qosIndexNew = SceneType<RMBT.QosMeasurementNewIndexViewController>(storyboard: QosResult.self, identifier: "qos_index_new")

    static let qosIndexOld = SceneType<RMBT.QosMeasurementIndexTableViewController>(storyboard: QosResult.self, identifier: "qos_index_old")
  }
  enum Settings: StoryboardType {
    static let storyboardName = "Settings"

    static let initialScene = InitialSceneType<RMBT.GeneralSettingsViewController>(storyboard: Settings.self)

    static let hideWarning1 = SceneType<UITableViewController>(storyboard: Settings.self, identifier: "hide_warning1")

    static let hideWarning2 = SceneType<RMBT.DeveloperModeSettingsViewController>(storyboard: Settings.self, identifier: "hide_warning2")

    static let hideWarning3 = SceneType<RMBT.NerdModeSettingsViewController>(storyboard: Settings.self, identifier: "hide_warning3")
  }
  enum Terms: StoryboardType {
    static let storyboardName = "Terms"

    static let initialScene = InitialSceneType<RMBT.RMBTTOSViewController>(storyboard: Terms.self)
  }
}

enum StoryboardSegue {
  enum History: String, SegueType {
    case showHistoryFilters = "show_history_filters"
    case showHistoryItem = "show_history_item"
    case showQosResults = "show_qos_results"
    case showQosResultsNew = "show_qos_results_new"
    case showResultDetails = "show_result_details"
    case showResultDetailsGrouped = "show_result_details_grouped"
    case showResultOnMap = "show_result_on_map"
    case unwindFromHistory
  }
  enum ILRMain: String, SegueType {
    case pushHelpViewController
    case pushHistoryViewController
    case pushHomeViewController
    case pushInfoViewController
    case pushMapViewController
    case pushSettingsViewController
    case pushSettingsViewControllerFromTos
    case pushStatisticsViewController
    case showMeasurementResult = "show_measurement_result"
    case showMeasurementViewController = "show_measurement_view_controller"
    case showPositionChooserViewController = "show_position_chooser_view_controller"
    case showTermsAndConditions = "show_terms_and_conditions"
    case swFront = "sw_front"
    case swRear = "sw_rear"
  }
  enum Info: String, SegueType {
    case showGoogleMapsNotice = "show_google_maps_notice"
  }
  enum Main: String, SegueType {
    case pushHelpViewController
    case pushHistoryViewController
    case pushHomeViewController
    case pushInfoViewController
    case pushMapViewController
    case pushSettingsViewController
    case pushStatisticsViewController
    case showMeasurementResult = "show_measurement_result"
    case showMeasurementViewController = "show_measurement_view_controller"
    case showTermsAndConditions = "show_terms_and_conditions"
    case swFront = "sw_front"
    case swRear = "sw_rear"
  }
  enum Map: String, SegueType {
    case showMapFilter = "show_map_filter"
    case showMapOptions = "show_map_options"
    case showOwnMeasurementFromMap = "show_own_measurement_from_map"
  }
  enum QosResult: String, SegueType {
    case showQosTest = "show_qos_test"
    case showQosTestDetail = "show_qos_test_detail"
    case showQosTestNew = "show_qos_test_new"
  }
  enum Settings: String, SegueType {
    case settingsToContractSettings = "settings_to_contract_settings"
  }
  enum Terms: String, SegueType {
    case showPublishPersonalData = "show_publish_personal_data"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
