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
import BCGenieEffect
import RMBTClient

/// These values are passed to map server and are multiplied by 2x on retina displays to get pixel sizes
let kTileSizePoints: CGFloat = 256
let kPointDiameterSizePoints: CGFloat = 8

let kCameraLatKey     = "map.camera.lat"
let kCameraLngKey     = "map.camera.lng"
let kCameraZoomKey    = "map.camera.zoom"
let kCameraBearingKey = "map.camera.bearing"
let kCameraAngleKey   = "map.camera.angle"

///
class RMBTMapViewController: TopLevelViewController, GMSMapViewDelegate, RMBTMapSubViewControllerDelegate {

    ///
    @IBOutlet fileprivate var locateMeButton: UIButton!

    ///
    @IBOutlet fileprivate var toastView: UIView!

    ///
    @IBOutlet fileprivate var toastTitleLabel: UILabel!

    ///
    @IBOutlet fileprivate var toastKeysLabel: UILabel!

    ///
    @IBOutlet fileprivate var toastValuesLabel: UILabel!

    ///
    fileprivate var settingsBarButtonItem: UIBarButtonItem!

    ///
    fileprivate var filterBarButtonItem: UIBarButtonItem!

    ///
    fileprivate var toastBarButtonItem: UIBarButtonItem!

    /// If set, blue pin will be shown at this location and map initially zoomed here. Used to display a test on the map.
    var initialLocation: CLLocation!

    //

    ///
    fileprivate var mapOptions: RMBTMapOptions!

    ///
    fileprivate var mapView: GMSMapView!

    ///
    fileprivate var mapMarker: GMSMarker!

    //

    ///
    fileprivate var mapLayerHeatmap: GMSTileLayer!

    ///
    fileprivate var mapLayerPoints: GMSTileLayer!

    //

    ///
    fileprivate var tileParamsDictionary: NSMutableDictionary!

    ///
    fileprivate var tileSize = -1

    ///
    fileprivate var pointDiameterSize = -1

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewDidLoad() {
        revealControllerEnabled = initialLocation == nil
        super.viewDidLoad()

        toastBarButtonItem = UIBarButtonItem(title: "m", style: .plain, target: self, action: #selector(RMBTMapViewController.toggleToast(_:)))
            //UIBarButtonItem(image: UIImage(named: "map_info"), style: .plain, target: self, action: #selector(RMBTMapViewController.toggleToast(_:)))
        toastBarButtonItem.isEnabled = false

        settingsBarButtonItem = UIBarButtonItem(title: "\u{00F2}", style: .plain, target: self, action: #selector(RMBTMapViewController.showMapOptions))
            //UIBarButtonItem(image: UIImage(named: "map_options"), style: .plain, target: self, action: #selector(RMBTMapViewController.showMapOptions))
        settingsBarButtonItem.isEnabled = false

        filterBarButtonItem = UIBarButtonItem(title: "\u{00F9}", style: .plain, target: self, action: #selector(RMBTMapViewController.showMapFilter))
            //UIBarButtonItem(image: UIImage(named: "map_filter"), style: .plain, target: self, action: #selector(RMBTMapViewController.showMapFilter))
        filterBarButtonItem.isEnabled = false

        if initialLocation == nil {
            navigationItem.rightBarButtonItems = [toastBarButtonItem, settingsBarButtonItem, filterBarButtonItem]
        }
    }

    ///
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        togglePopGestureRecognizer(false)

        // Note that initializing map view for the first time takes few seconds until all resources are initialized,
        // so to appear more responsive we we do it here (instead of viewDidLoad).
        if mapView == nil {
            setupMapView()
        }
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        togglePopGestureRecognizer(true)
    }

    ///
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.mapView.frame = self.view.bounds
        })
    }

// MARK: map view methods

    fileprivate func setupMapView() {
        assert(mapView == nil, "Map view already initialized!")

        var cam = GMSCameraPosition.camera(withLatitude: RMBT_MAP_INITIAL_LAT, longitude: RMBT_MAP_INITIAL_LNG, zoom: RMBT_MAP_INITIAL_ZOOM)

        // If test coordinates were provided, center map at the coordinates:
        if let initialLocation = self.initialLocation {
            cam = GMSCameraPosition.camera(withLatitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude, zoom: RMBT_MAP_POINT_ZOOM)
        } else {
            // Otherwise, see if we have user's location available...
            if let location = RMBTLocationTracker.sharedTracker.location {
                // and if yes, then show it on the map
                cam = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: RMBT_MAP_INITIAL_ZOOM)
            }
        }

        mapView = GMSMapView.map(withFrame: view.bounds, camera: cam)

        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "map-style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                logger.warning("Unable to find style.json")
            }
        } catch {
            logger.warning("One or more of the map styles failed to load. \(error)")
        }

        mapView.isMyLocationEnabled = true

        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = false
        mapView.settings.consumesGesturesInView = false

        mapView.delegate = self

        let mainScreenScale = UIScreen.main.scale
        tileSize = Int(kTileSizePoints * mainScreenScale)
        pointDiameterSize = Int(kPointDiameterSizePoints * mainScreenScale)

        // load map options
        RMBT.mapServer.getMapOptions(success: { response in
            logger.debug("got map options: \(response)")

            self.mapOptions = response

            self.settingsBarButtonItem.isEnabled = true
            self.filterBarButtonItem.isEnabled = true
            self.toastBarButtonItem.isEnabled = true

            self.setupMapLayers()
            self.refresh()

        }, error: { error in
            logger.error("Could not load map options")
        })

        // Setup toast (overlay) view
        toastView.isHidden = true
        toastView.layer.cornerRadius = 6.0

        // Tapping the toast should hide it
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(RMBTMapViewController.toggleToast(_:)))
        toastView.addGestureRecognizer(tapRecognizer)

        view.insertSubview(mapView, belowSubview: toastView)

        // If test coordinates were provided, show a blue untappable pin at those coordinates
        if let initialLocation = self.initialLocation {
            let marker = GMSMarker(position: initialLocation.coordinate)
            // Approx. HUE_AZURE color from Android
            marker.icon = GMSMarker.markerImage(with: UIColor(red: 0.510, green: 0.745, blue: 0.984, alpha: 1)) // TODO: CONFIG
            marker.isTappable = false
            marker.map = mapView
        }
    }

    ///
    fileprivate func setupMapLayers() {
        mapLayerHeatmap = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> URL? in
            return RMBT.mapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayHeatmap.identifier, x: x, y: y, zoom: zoom, params: self.tileParamsDictionary)
        }

        mapLayerHeatmap.tileSize = tileSize
        mapLayerHeatmap.map = mapView
        mapLayerHeatmap.zIndex = 101

        //

        mapLayerPoints = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> URL? in
            return RMBT.mapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayPoints.identifier, x: x, y: y, zoom: zoom, params: self.tileParamsDictionary)
        }

        mapLayerPoints.tileSize = tileSize
        mapLayerPoints.map = mapView
        mapLayerPoints.zIndex = 102
    }

    ///
    fileprivate func deselectCurrentMarker() {
        if mapMarker != nil {
            mapMarker.map = nil
            mapView.selectedMarker = nil
            mapMarker = nil
        }
    }

    ///
    fileprivate func refresh() {
        tileParamsDictionary = mapOptions.activeSubtype.paramsDictionary().mutableCopy() as! NSMutableDictionary
        tileParamsDictionary.addEntries(from: [
            "size":             "\(tileSize)",
            "point_diameter":   "\(pointDiameterSize)"
        ])

        logger.debug("\(self.tileParamsDictionary)")

        updateLayerVisibility()

        mapLayerPoints.clearTileCache()
        mapLayerHeatmap.clearTileCache()

        let toastInfo = mapOptions.toastInfo()

        toastTitleLabel.text = toastInfo[RMBTMapOptionsToastInfoTitle]?.first

        toastKeysLabel.text = toastInfo[RMBTMapOptionsToastInfoKeys]!.joined(separator: "\n")
        toastValuesLabel.text = toastInfo[RMBTMapOptionsToastInfoValues]!.joined(separator: "\n")

        displayToast(true, withGenieEffect: false)
    }

    ///
    fileprivate func displayToast(_ state: Bool, withGenieEffect genie: Bool) {
        if toastView.isHidden != state {
            return // already displayed/hidden
        }

        toastView.isHidden = false

        if !genie {
            toastView.alpha = (state) ? 0.0 : 1.0
            toastView.transform = CGAffineTransform.identity

            UIView.animate(withDuration: 0.5, animations: {
                self.toastView.alpha = (state) ? 1.0 : 0.0
            }, completion: { _ in
                self.toastView.isHidden = !state
            })

            if state {
                // autohide after 3 sec
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    self.displayToast(false, withGenieEffect: true)
                }
            }
        } else {
            let buttonRect = CGRect(x: view.frame.width - 36, y: 0, width: 10, height: 10) // top right corner

            if state {
                toastView.genieOutTransition(withDuration: 0.5, start: buttonRect, start: BCRectEdge.bottom, completion: {})
            } else {
                toastView.genieInTransition(withDuration: 0.5, destinationRect: buttonRect, destinationEdge: BCRectEdge.bottom, completion: {
                    self.toastView.isHidden = true
                })
            }
        }
    }

// MARK: MapView delegate methods

    ///
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if !USE_OPENDATA { // Tap on map point must not work if not using opendata
            return
        }

        // If we're not showing points, ignore this tap
        if mapLayerPoints.map == nil {
            return
        }

        let oldParams = mapOptions.activeSubtype.markerParamsDictionary() // TODO: improve with new classes
        var params = [String: [String: AnyObject]]()

        params["options"] = oldParams.value(forKey: "options") as? [String: AnyObject]
        params["filter"] = oldParams.value(forKey: "filter") as? [String: AnyObject]

        RMBT.mapServer.getMeasurementsAtCoordinate(coordinate, zoom: Int(mapView.camera.zoom), params: params, success: { measurements in
            logger.debug("\(measurements)")

            self.deselectCurrentMarker()

            if let m = measurements.first {
                if let lat = m.latitude, let lon = m.longitude {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                    var point = self.mapView.projection.point(for: coordinate)
                    point.y -= 180

                    let camera = GMSCameraUpdate.setTarget(self.mapView.projection.coordinate(for: point))
                    self.mapView.animate(with: camera)

                    self.mapMarker = GMSMarker(position: coordinate)
                    self.mapMarker.icon = self.emptyMarkerImage()
                    self.mapMarker.userData = m
                    self.mapMarker.appearAnimation = GMSMarkerAnimation.pop
                    self.mapMarker.map = self.mapView
                    self.mapView.selectedMarker = self.mapMarker
                }
            }
        }, error: { error in
            logger.error("Error getting measurements at coordinate \(error)")
        })
    }

    ///
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if let markerObj = marker.userData as? SpeedMeasurementResultResponse {
            //return self.storyboard?.instantiateViewController(withIdentifier: "map_popup").view
            return RMBTMapCalloutView.calloutViewWithMeasurement(markerObj)
        }

        return nil
    }

    ///
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let markerData = marker.userData as? SpeedMeasurementResultResponse {
            //logger.debug("\(markerData)")

            // if measurementUuid is there  -> show measurement in app (allow only on global map -> initialLocation == nil) // TODO: use highlight == true
            if let measurementUuid = markerData.measurementUuid, /*markerData.highlight &&*/ initialLocation == nil { // highlight is a filter -> see MapServer...
                performSegue(withIdentifier: "show_own_measurement_from_map", sender: measurementUuid)
            } else if let openTestUuid = (marker.userData as? SpeedMeasurementResultResponse)?.openTestUuid { // else show open test result
                RMBT.mapServer.getOpenTestUrl(openTestUuid, success: { response in
                    logger.debug("url: \(String(describing: response))")

                    if let url = response {
                        self.presentModalBrowserWithURLString(url)
                    } else {
                        logger.debug("map open test uuid url is nil")
                    }
                })
            }
        }
    }

    ///
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateLayerVisibility() // TODO: this is sometimes triggered too fast, leading to EXC_BAD_INSTRUCTION inside of
                                // updateLayerVisibility. mostly occurs on slow internet connections
    }

// MARK: Layer visibility

    ///
    fileprivate func setLayer(_ layer: GMSTileLayer, hidden: Bool) {
        let state = (layer.map == nil)
        if state == hidden {
            return
        }

        layer.map = (hidden) ? nil : mapView
    }

    ///
    fileprivate func updateLayerVisibility() {
        if let overlay = mapOptions?.activeOverlay { // prevents EXC_BAD_INSTRUCTION happening sometimes because mapOptions are nil

            var heatmapVisible = false
            var pointsVisible = false

            if overlay === RMBTMapOptionsOverlayPoints {
                pointsVisible = true
            } else if overlay === RMBTMapOptionsOverlayHeatmap {
                heatmapVisible = true
            } else if overlay === RMBTMapOptionsOverlayAuto {
                if mapOptions.activeSubtype.type.identifier == "browser" {
                    // Shapes
                    //shapesVisible = true
                    //regionsVisible = true // TODO: is this correct?
                } else {
                    heatmapVisible = true
                }

                pointsVisible = (mapView.camera.zoom >= RMBT_MAP_AUTO_TRESHOLD_ZOOM)

            } else {
                //NSParameterAssert(NO); // does not work when commented in, probably because of new google maps framework
                logger.debug("\(overlay)") // TODO: possible bug because overlay is now null
            }

            setLayer(mapLayerHeatmap, hidden: !heatmapVisible)
            setLayer(mapLayerPoints, hidden: !pointsVisible)
        }
    }

// MARK: Segues

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_map_options" || segue.identifier == "show_map_filter" {
            let optionsVC = segue.destination as! RMBTMapSubViewController
            optionsVC.delegate = self
            optionsVC.mapOptions = mapOptions
        } else if segue.identifier == "show_own_measurement_from_map" {
            if let measurementResultTableViewController = segue.destination as? MeasurementResultTableViewController {
                measurementResultTableViewController.measurementUuid = sender as? String
                measurementResultTableViewController.fromMap = true
            }
        }
    }

    ///
    func mapSubViewController(_ viewController: RMBTMapSubViewController, willDisappearWithChange change: Bool) {
        if change {
            logger.debug("Map options changed, refreshing...")
            mapOptions.saveSelection()
            refresh()
        }

        switch mapOptions.mapViewType {
        case .hybrid:       mapView.mapType = GMSMapViewType.hybrid
        case .satellite:    mapView.mapType = GMSMapViewType.satellite
        default:            mapView.mapType = GMSMapViewType.normal
        }
    }

    ///
    fileprivate func togglePopGestureRecognizer(_ state: Bool) {
        // Temporary fix for http://code.google.com/p/gmaps-api-issues/issues/detail?id=5772 on iOS7
        navigationController?.interactivePopGestureRecognizer?.isEnabled = state
    }

// MARK: Button actions

    ///
    @objc func showMapOptions() {
        performSegue(withIdentifier: "show_map_options", sender: self)
    }

    ///
    @objc func showMapFilter() {
        performSegue(withIdentifier: "show_map_filter", sender: self)
    }

    ///
    @IBAction func toggleToast(_ sender: AnyObject) {
        displayToast(toastView.isHidden, withGenieEffect: true)
    }

    ///
    @IBAction func locateMe(_ sender: AnyObject) {
        if RMBTLocationTracker.sharedTracker.location == nil {
            return
        }

        if let coord = mapView.myLocation?.coordinate {
            let camera = GMSCameraUpdate.setTarget(coord)
            mapView.animate(with: camera)
        }
    }

// MARK: Helpers

    ///
    fileprivate func emptyMarkerImage() -> UIImage { // TODO: dispatch_once
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

// MARK: state preservation / restoration

    ///
    override func encodeRestorableState(with coder: NSCoder) {
        logger.debug("\(#function)")

        super.encodeRestorableState(with: coder)
    }

    ///
    override func decodeRestorableState(with coder: NSCoder) {
        logger.debug("\(#function)")

        super.decodeRestorableState(with: coder)
    }

    ///
    override func applicationFinishedRestoringState() {
        logger.debug("\(#function)")

        revealViewController().delegate = self
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension RMBTMapViewController {

    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        mapView.settings.setAllGesturesEnabled(false)
    }

    ///
    func revealControllerPanGestureEnded(_ revealController: SWRevealViewController!) {
        mapView.settings.setAllGesturesEnabled(true)
    }

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)

        mapView.settings.setAllGesturesEnabled(position == .left)
    }
}
