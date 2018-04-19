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
import RMBTClient

///
let kRoundedCornerRadius: CGFloat = 6.0

///
let kTriangleSize: CGSize = CGSize(width: 30.0, height: 20.0)

///
class RMBTMapCalloutView: UIView, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet var tableView: UITableView!

    ///
    @IBOutlet var titleLabel: UILabel!

    ///
    @IBOutlet var iButton: UIButton?

    ///
    fileprivate var _measurementCells = [ClassifyableKeyValueTableViewCell]()

    ///
    fileprivate var _netCells = [KeyValueTableViewCell]()

    ///
    fileprivate var measurement: SpeedMeasurementResultResponse { // property? this never gets set? a single setter method would be better!?
        get {
            return self.measurement
        }
        set {
            titleLabel?.text = newValue.timeString

            // measurement cells
            if let cmdl = newValue.classifiedMeasurementDataList {
                _measurementCells.append(contentsOf: cmdl.map { item in
                    let cell = ClassifyableKeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
                    //cell.keyLabel?.text = item.title
                    cell.textLabel?.text = item.title
                    //cell.valueLabel?.text = item.value
                    cell.detailTextLabel?.text = item.value
                    cell.classification = item.classification
                    cell.classificationColor = UIColor(hexString: item.classificationColor)

                    return cell
                })
            }

            // net cells
            if let ndl = newValue.networkDetailList {
                _netCells.append(contentsOf: ndl.map { item in
                    let cell = KeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
                    //cell.keyLabel?.text = item.title
                    cell.textLabel?.text = item.title
                    //cell.valueLabel?.text = item.value
                    cell.detailTextLabel?.text = item.value

                    return cell
                })
            }

            //logger.debug("\(_measurementCells)")
            //logger.debug("\(_netCells)")

            tableView.reloadData()

            frameHeight = tableView.contentSize.height
        }
    }

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    ///
    class func calloutViewWithMeasurement(_ measurement: SpeedMeasurementResultResponse) -> RMBTMapCalloutView {
        let view = Bundle.main.loadNibNamed("RMBTMapCalloutView", owner: self, options: nil)![0] as! RMBTMapCalloutView
        view.measurement = measurement

        view.iButton?.isHidden = measurement.measurementUuid == nil //!measurement.highlight // only show i-button for own measurements

        return view
    }

    ///
    @IBAction func getMoreDetails() {
        // NSNotificationCenter.defaultCenter().postNotificationName("RMBTTrafficLightTappedNotification", object: self)
        logger.debug("Got link: \(String(describing: self.measurement.openTestUuid))") // never while beeing as content of a Gooogle Maps marker
    }

    ///
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyMask()
    }

    ///
    func applyMask() {
        let bottom = frameHeight - kTriangleSize.height
        let path = CGMutablePath()

        path.move(to: CGPoint(x: kRoundedCornerRadius, y: 0.0))
        path.addLine(to: CGPoint(x: frameWidth - kRoundedCornerRadius, y: 0.0))
        path.addArc(tangent1End: CGPoint(x: frameWidth, y: 0.0), tangent2End: CGPoint(x: frameWidth, y: kRoundedCornerRadius), radius: kRoundedCornerRadius)
        path.addLine(to: CGPoint(x: frameWidth, y: bottom - kRoundedCornerRadius))
        path.addArc(tangent1End: CGPoint(x: frameWidth, y: bottom), tangent2End: CGPoint(x: frameWidth - kRoundedCornerRadius, y: bottom), radius: kRoundedCornerRadius)
        path.addLine(to: CGPoint(x: frame.midX + kTriangleSize.width / 2.0, y: bottom))
        path.addLine(to: CGPoint(x: frame.midX, y: frameHeight))
        path.addLine(to: CGPoint(x: frame.midX - kTriangleSize.width / 2.0, y: bottom))
        path.addLine(to: CGPoint(x: kRoundedCornerRadius, y: bottom))
        path.addArc(tangent1End: CGPoint(x: 0.0, y: bottom), tangent2End: CGPoint(x: 0.0, y: bottom - kRoundedCornerRadius), radius: kRoundedCornerRadius)
        path.addLine(to: CGPoint(x: 0.0, y: kRoundedCornerRadius))
        path.addArc(tangent1End: CGPoint(x: 0.0, y: 0.0), tangent2End: CGPoint(x: kRoundedCornerRadius, y: 0.0), radius: kRoundedCornerRadius)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = nil
        shapeLayer.lineWidth = 0.0
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayer.position = CGPoint(x: 0.0, y: 0.0)

        let borderLayer = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: shapeLayer)) as! CAShapeLayer
        borderLayer.fillColor = nil
        borderLayer.strokeColor = /*RMBT_DARK_COLOR*/UIColor(rgb: 0x333333).withAlphaComponent(0.75).cgColor
        borderLayer.lineWidth = 3.0

        layer.addSublayer(borderLayer)
        layer.mask = shapeLayer
    }

// MARK: Table delegte

    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = _measurementCells[indexPath.row]

            // TODO: improve this a lot! (-> See MeasurementResultTableViewController)

            let sideStatus = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: /*cell.frame.size.height - 8*/30))
            cell.addSubview(sideStatus)

            if let cc = cell.classificationColor {
                sideStatus.backgroundColor = cc
            } else {
                if let classification = cell.classification {
                    switch classification {
                    case 1: sideStatus.backgroundColor = COLOR_CHECK_RED
                    case 2: sideStatus.backgroundColor = COLOR_CHECK_YELLOW
                    case 3: sideStatus.backgroundColor = COLOR_CHECK_GREEN
                    default: cell.accessoryView = nil
                    }
                }
            }

            return cell
        }

        return _netCells[indexPath.row]
    }

    ///
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? _measurementCells.count : _netCells.count
    }

    ///
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? L10n.Map.Callout.measurement : L10n.Map.Callout.network
    }

    ///
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }

    ///
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)

        /*if let dtl = cell.detailTextLabel { // TODO: improve. Maybe because there are no measurements (Got 0 measurements) no text is set
            if let t = dtl.text {
                let textSize: CGSize = t.sizeWithAttributes(["NSFontAttributeName": dtl.font]) // !!!
                return (textSize.width >= 130.0) ? 50.0 : 30.0
            }
        }*/

        return 30.0
    }

}
