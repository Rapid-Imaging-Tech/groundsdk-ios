// Copyright (C) 2019 Parrot Drones SAS
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of the Parrot Company nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.

import UIKit
import GroundSdk
import CoreLocation
class FileReplayViewController: UIViewController {

    @IBOutlet weak var streamView: StreamView!
    @IBOutlet weak var playPauseBtn: UIBarButtonItem!
    @IBOutlet weak var stopBtn: UIBarButtonItem!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    //@IBOutlet weak var geocodeLabel: UILabel!
    //@IBOutlet weak var geocodeLatLon: UILabel!
    private let groundSdk = GroundSdk()
    private var fileUrl: URL?
    private var fileReplay: Ref<FileReplay>?

    // formatter for the time position
    private lazy var timeFormatter: DateComponentsFormatter = {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        return durationFormatter
    }()

    func set(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    @IBOutlet var tableView:UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeSlider.minimumValue = 0
        if let fileUrl = fileUrl {

            let source = FileReplayFactory.videoTrackOf(file: fileUrl, track: .defaultVideo)
            fileReplay = groundSdk.replay(source: source) { [weak self] stream in
                self?.stopBtn.isEnabled = stream?.state != .stopped
                self?.playPauseBtn.title = stream?.playState != .playing ? "Play" : "Pause"
                self?.streamView.setStream(stream: stream)

                self?.durationLabel.text = self?.timeFormatter.string(from: stream?.duration ?? 0)
                self?.timeSlider.maximumValue = Float(stream?.duration ?? 0)
                self?.refreshStreamPosition()
            }
            
            //dd code
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureFired(_: )))
            gestureRecognizer.numberOfTapsRequired = 1
            gestureRecognizer.numberOfTouchesRequired = 1
             
            view.addGestureRecognizer(gestureRecognizer)
            //myView.addGestureRecognizer(gestureRecognizer)
            //myView.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.layer.zPosition = 1
            
            //var  tableViewFrame = tableView.frame;
                //tableViewFrame.size.height = numberOfRows * tableView.rowHeight
            tableView.frame.size.height = 4 * tableView.rowHeight //doesnt work
            tableView.layer.cornerRadius = 8
            //UITableViewCell.appearance().textLabel?.textColor = UIColor.whiteColor();
            
         }
    }

    //dd function
    
    var counter:Int = 0
    var timer:Timer = Timer()
    var _houseNumber:String = ""
    var _streetName:String = ""
    var _postalCode:String = ""
    var _locality:String = ""
    var _name:String = ""
    var _subLocality:String = ""
    var _administrativeArea = ""
    var _strLatitude = ""
    var _strLongitude = ""
    var _areasOfInterest:[String] = []
    @objc func fireTimer() {
        print("Timer fired!")
        counter += 1
        //in here lets keep checking for a message from LFMessageHandler, once we get one back
        //from gles2video, then invalidate the timer.
        var lat1:Float = 0.0
        var lon1:Float = 0.0
        
        
        //LFMessageHandler().vcCheckLatLonReady(:lat, Lon:lon)
        //LFMessageHandler().vcCheckLatLonReadyLat(T##lat: UnsafeMutablePointer<Float>!##UnsafeMutablePointer<Float>!, Lon: lon)
        let isready = LFMessageHandler().vcCheckLatLonReadyLat(&lat1, lon: &lon1)
        if counter > 5 || isready{
            //if isready, then lat lon is the point we wanna look up
            counter = 0
            timer.invalidate()
            var tapPoint = CLLocation()// = new CLLocation()
            if isready{
                tapPoint = CLLocation.init(latitude: Double(lat1), longitude: Double(lon1))
            }
            else{
             tapPoint = CLLocation.init(latitude: 46.685369142004596, longitude: -92.3607080742755)
            }
                let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(tapPoint){ [weak self](placemarks, error) in
                //guard let self = self else { return }
                if let _ = error {
                    return
                }
                
                guard let placemark = placemarks?.first else{
                    return
                }
                
                DispatchQueue.main.async {
                    self?._houseNumber = placemark.subThoroughfare ?? ""
                    self?._streetName = placemark.thoroughfare ?? ""
                    self?._postalCode = placemark.postalCode ?? ""
                    self?._areasOfInterest = placemark.areasOfInterest ?? []
                    self?._locality = placemark.locality ?? ""
                    self?._name = placemark.name ?? ""
                    self?._subLocality = placemark.subLocality ?? ""
                    self?._administrativeArea = placemark.administrativeArea ?? ""
                    self?._strLatitude = String(lat1)
                    self?._strLongitude = String(lon1)
                    self?.tableView.reloadData()
                    
                }
            }
            
        }
        
    }
    //dd function
    @objc func gestureFired(_ gesture:UITapGestureRecognizer){
        let touchPoint = gesture.location(in: self.view)
        
        print("gesture fired at x:\(touchPoint.x) y:\(touchPoint.y)")
        print(" frame width/height \(self.view.frame.size.width) \(self.view.frame.size.height)")
        print(" bounds width/height \(self.view.bounds.size.width) \(self.view.bounds.size.height)")
        
        var scale = self.view.contentScaleFactor;
        
        let fx = Float(touchPoint.x)
        let fy = Float(touchPoint.y / scale) //- 100.0;
        
        
        //CGFloat scale = [[UIScreen mainScreen] scale];
        //touchLocation.y *= scale;
        //touchLocation.y *= scale;
        
        
         timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        
        LFMessageHandler().vcGetLatLon(forScreenXY: fx, andScreenY: fy)
        LFMessageHandler().setX(fx,  andY: fy)
    }
    
    @objc func refreshStreamPosition() {
        let position = fileReplay?.value?.position ?? 0
        positionLabel.text = timeFormatter.string(from: position)
        timeSlider.value = Float(position)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshStreamPosition),
                                               object: nil)
        if fileReplay?.value?.state == .started {
            perform(#selector(refreshStreamPosition), with: nil, afterDelay: 0.1)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        streamView.setStream(stream: nil)
        fileReplay?.value?.stop()
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
    }
    @IBAction func playPauseStream(_ sender: UIBarButtonItem) {
        if let fileReplayRef = fileReplay, let stream = fileReplayRef.value {
            if stream.playState == .playing {
                _ = stream.pause()
            } else {
                _ = stream.play()
            }
        }
    }

    @IBAction func stopStream(_ sender: UIBarButtonItem) {
        if let stream = fileReplay, stream.value?.state != .stopped {
            stream.value?.stop()
        }
    }

    @IBAction func seekTo(_ sender: UISlider) {
        _ = fileReplay?.value?.seekTo(position: TimeInterval(sender.value))
    }
}

extension FileReplayViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
    
}

extension FileReplayViewController:UITableViewDataSource{
    
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
       return "Landmark Info" //\(section)"
    }

    // Create a standard footer that includes the returned text.
     func tableView(_ tableView: UITableView, titleForFooterInSection
                                section: Int) -> String? {
       return "Copyright \u{00A9} 2021 Rapid Imaging Technologies Inc." // \(section)"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows:CGFloat =  9;
        //var  tableViewFrame = tableView.frame;
            //tableViewFrame.size.height = numberOfRows * tableView.rowHeight
        //tableView.frame.size.height = numberOfRows * tableView.rowHeight //tableViewFrame
        //tableView.rowHeight = 60.0;
        
        return Int(numberOfRows)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //tableView.layer.cornerRadius = 8
        //cell.layer.cornerRadius = 8
        //cell.layer.masksToBounds = true
        cell.textLabel?.textColor = UIColor.white
        //cell.appearance().textLabel?.textColor = UIColor.white
        if indexPath.row == 0{
            cell.textLabel?.text = "Street Name: \(_streetName)"
        }
        if indexPath.row == 1{
            cell.textLabel?.text = "House Number: \(_houseNumber)"
        }
        if indexPath.row == 2{
            cell.textLabel?.text = "Postal Code: \(_postalCode)"
        }
        if indexPath.row == 3{
            cell.textLabel?.text = "Locality: \(_locality)"
        }
        if indexPath.row == 4{
            cell.textLabel?.text = "Name: \(_name)"
        }
        if indexPath.row == 5{
            cell.textLabel?.text = "SubLocality: \(_subLocality)"
        }
        if indexPath.row == 6{
            cell.textLabel?.text = "AdminArea: \(_administrativeArea)"
        }
        if indexPath.row == 7{
            cell.textLabel?.text = "Latitude: \(_strLatitude)"
        }
        if indexPath.row == 8{
            cell.textLabel?.text = "Longitude: \(_strLongitude)"
        }
        //if indexPath.row == 1{
         //   cell.textLabel?.text = _streetName
        //}
        return cell
    }
}
