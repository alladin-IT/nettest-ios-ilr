import CoreLocation
import RMBTClient

///
let RMBT = RMBTBuilder().create()

// MARK: Other URLs used in the app

let RMBT_URL_HOST = "https://checkmynet.lu"

/// Note: $lang will be replaced by the device language (de, en, sl, etc.)
//let RMBT_STATS_URL       = "\(RMBT_URL_HOST)/$lang/statistics"
let RMBT_STATS_URL       = "\(RMBT_URL_HOST)/statistics"
//let RMBT_HELP_URL        = "\(RMBT_URL_HOST)/$lang/help"
let RMBT_HELP_URL        = "\(RMBT_URL_HOST)/help?lang=$lang"
//let RMBT_HELP_RESULT_URL = "\(RMBT_URL_HOST)/$lang/help"
let RMBT_HELP_RESULT_URL = "\(RMBT_URL_HOST)/help?lang=$lang"

//let RMBT_PRIVACY_TOS_URL = "\(RMBT_URL_HOST)/$lang/tc"
let RMBT_PRIVACY_TOS_URL = "\(RMBT_URL_HOST)/tc"

//

let RMBT_ABOUT_URL       = "https://checkmynet.lu"
let RMBT_PROJECT_URL     = RMBT_URL_HOST
let RMBT_PROJECT_EMAIL   = "checkmynet@ilr.lu"

let RMBT_REPO_URL        = "https://github.com/alladin-it"
let RMBT_DEVELOPER_URL   = "https://alladin.at"

// MARK: Map options

/// Initial map center coordinates and zoom level
let RMBT_MAP_INITIAL_LAT: CLLocationDegrees = 49.611436
let RMBT_MAP_INITIAL_LNG: CLLocationDegrees = 6.129927

let RMBT_MAP_INITIAL_ZOOM: Float = 12.0 /*6.5*/

/// Zoom level to use when showing a test result location
let RMBT_MAP_POINT_ZOOM: Float = 12.0

/// In "auto" mode, when zoomed in past this level, map switches to points
let RMBT_MAP_AUTO_TRESHOLD_ZOOM: Float = 12.0

// Google Maps API Key

///#warning Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
let RMBT_GMAPS_API_KEY = ""

// MARK: Misc

/// Current TOS version. Bump to force displaying TOS to users again.
let RMBT_TOS_VERSION = 1

///////////////////

let TEST_SHOW_TRAFFIC_WARNING_ON_CELLULAR_NETWORK = false
let TEST_SHOW_TRAFFIC_WARNING_ON_WIFI_NETWORK = false

let TEST_USE_PERSONAL_DATA_FUZZING = false

let TERMS_SETTINGS_LINK = true

// If set to false: Statistics is not visible, tap on map points doesn't show bubble, ...
let USE_OPENDATA = true

// Whether to show mnc-mcc or not
let STARTSCREEN_SHOW_MCC_MNC = true

let START_SCREEN_LOCATION_POPUP_ENABLED = true

let QOS_INDEX_USE_COLLECTION_VIEW = true
let HISTORY_DETAILS_USE_GROUPED_VIEW = true

let NO_MAP = false

let POSITION_BUTTON_ENABLED = false

let HISTORY_RERUN_BUTTON_ENABLED = false
let HISTORY_SHARE_BUTTON_ENABLED = true
