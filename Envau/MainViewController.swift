import UIKit
import MapKit
import RealmSwift
import CoreLocation
import Foundation
import AVFoundation


class MainViewController: UIViewController, CLLocationManagerDelegate {

    lazy var realm = try! Realm()
    
    lazy var beaconDataRLM: Results<RLM_BeaconData> = {
        self.realm.objects(RLM_BeaconData.self) }()
    
    lazy var sessionData: Results<RLM_Session_14> = {
        self.realm.objects(RLM_Session_14.self) }()
    
    lazy var layers: Results<RLM_Layer_12> = {
        self.realm.objects(RLM_Layer_12.self) }()
    
    lazy var keyItems: Results<RLM_Note> = {
        self.realm.objects(RLM_Note.self) }()
    
    var pausePlaybackBtnImage: UIImage = UIImage(named: "Pause_Main")!
    var resumePlaybackBtnImage: UIImage = UIImage(named: "PlayBtn_00")!
    
    var toggleUiBtnImageUp: UIImage = UIImage(named: "hbg_close_b_up")!
    var toggleUiBtnImageDown: UIImage = UIImage(named: "hbg_close_b_down")!
    
    var modeBtnA_a: UIImage = UIImage(named: "playmode_a_btn")!
    var modeBtnA_b: UIImage = UIImage(named: "playmode_b_btn")!
    
    var modeBtnB_a: UIImage = UIImage(named: "trigmode_a_btn")!
    var modeBtnB_b: UIImage = UIImage(named: "trigmode_b_btn")!
    
    var overlayCircleCache: [String: MKCircle]? = [:]
    var overlayCache: [String: MKOverlay]? = [:]
    
    var keyPickerVC: PianoRollCollectionViewController? = nil
    var appSettingsVC: ControlCenterViewController? = nil
    var mainMenuVC: MainMenuViewController? = nil
    var saveLoadVC: LayersTableViewController? = nil

    @IBOutlet weak var mapView: MKMapView!
    var userPinView: MKAnnotationView!
    let locationManager = CLLocationManager()
    
    static let sessionMgmt = SessionManagement()
    static let orchester = AuOrchester()
    static let viewAnimation = ViewAnimation()
    static let uiStyleTools = UIElementAppreneceTools()

    var uiTintColorText = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    var uiTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

    var mapUpdateTimer = Timer()
    var sleepTimer = Timer()

    var currentLocation = CLLocationCoordinate2D()
    var initScreenTouchPos: [Double] = [0.0, 0.0]
    var currScreenTouchPos: [Double] = [0.0, 0.0]
    
    var beaconIsSelected = false
    var controlPanelIsPresent = false
    
    var lPress = false
    
//    var playbackPaused: Bool { return sessionData.first?.playbackMode == 1 }
    var beaconsInRange = [RLM_BeaconData]()
    
    var selectedBeaconAnnotation: MKAnnotation? = nil
    
    var selectedBeaconData: RLM_BeaconData? {
        
        if sessionData.count > 0 {
            if sessionData[0].selectedBeacon != nil {
                return sessionData[0].selectedBeacon
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    
    @IBOutlet var mainMenuCTV: UIView!
    @IBOutlet var saveLoadCTW: UIView!
    
    @IBOutlet var keyPickerContainerView: UIView!
    
    @IBOutlet var settingsContainerView: UIView!
    @IBOutlet var settingsFxView: UIVisualEffectView!

    @IBOutlet var mainMenuViewContainer: UIView!
    @IBOutlet var longPressOutlet: UILongPressGestureRecognizer!
    
    @IBOutlet var beaconControlPanelContainerView: UIView!
    @IBOutlet var beaconControlPanelEffectView: UIVisualEffectView!
    @IBOutlet var beaconControlPanel: UIView!
    
    @IBOutlet var beaconHeadline: UITextField!
    @IBAction func beaconHeadlineAction(_ sender: UITextField) {

        do {
            try realm.write {
                if sessionData[0].selectedBeacon != nil {
                    sessionData[0].selectedBeacon?.name = beaconHeadline.text!
                }
            }
        } catch {
            print("Error: \(error)")
        }

    }
    
    @IBOutlet weak var toggleUiBtn: UIButton!
    @IBAction func toggleUiBtnAction(_ sender: UIButton) {
        print("toggleUiBtnAction")
        
//        modeBtnA.isHidden = !modeBtnA.isHidden
//        modeBtnB.isHidden = !modeBtnB.isHidden
        layerBtn.isHidden = !layerBtn.isHidden
        settingsBtn.isHidden = !settingsBtn.isHidden
        playPauseBtn.isHidden = !playPauseBtn.isHidden
        
        if (playPauseBtn.isHidden) {
            toggleUiBtn.setImage(toggleUiBtnImageUp,  for: .normal)
        } else {
            toggleUiBtn.setImage(toggleUiBtnImageDown,  for: .normal)
        }
    }
    
    @IBOutlet weak var modeBtnA: UIButton!
    @IBAction func modeBtnAAction(_ sender: UIButton) {
        print("modeBtnAAction")
        
        do {
            try realm.write {
                if sessionData.first!.trackingMode == 1 {
                    sessionData.first!.trackingMode = 0
                } else {
                    sessionData.first!.trackingMode = 1
                }
            }
        } catch {
            print("Error: \(error)")
        }
                
        if (sessionData.first!.trackingMode == 1) {
            modeBtnA.setImage(modeBtnA_a, for: .normal)
        } else {
            modeBtnA.setImage(modeBtnA_b, for: .normal)
        }
        
    }
    
    @IBOutlet weak var modeBtnB: UIButton!
    @IBAction func modeBtnBAction(_ sender: UIButton) {
        print("modeBtnBAction")
        
        do {
            try realm.write {
                sessionData.first!.holdNotes = !sessionData.first!.holdNotes
            }
        } catch {
            print("Error: \(error)")
        }
        
        if (sessionData.first!.holdNotes) {
            modeBtnB.setImage(modeBtnB_a, for: .normal)
        } else {
            modeBtnB.setImage(modeBtnB_b, for: .normal)
        }
    
    }
    

    @IBOutlet var deleteButtonOutlet: UIButton!
    @IBAction func deleteCalloutButton(_ sender: UIButton) {
         if selectedBeaconAnnotation != nil {
            showBeaconActionsMenu(sender)
         } else {
            print("ERROR: selectedBeacon != nil")
        }
    }

    
    func updateMainMenuBtn(btn: UIButton, isActive: Bool) {
        print("updateMainMenuBtn")
        
        if sessionData != nil {
            if (sessionData[0].playbackPaused) {
                playPauseBtn.setImage(resumePlaybackBtnImage,  for: .normal)
            } else {
                playPauseBtn.setImage(pausePlaybackBtnImage, for: .normal)
            }
        }
        
    }
    
    @IBOutlet var layerBtn: UIButton!
    @IBAction func layerBtnAction(_ sender: UIButton) {
        //updateMainMenuBtn(btn: (hbgMenuBtn)!, isActive: false)
//        mainMenuVC?.view.isHidden = false

        if ((saveLoadVC) != nil) {
            saveLoadVC!.refresh()
        }
        
        ViewAnimation().fade(
            viewToAnimate: (beaconControlPanelContainerView)!,
            aDuration: 0.25,
            hideView: true,
            aMode: UIView.AnimationOptions.curveEaseIn
        )

        ViewAnimation().fade(
             viewToAnimate: self.settingsFxView,
             aDuration: 0.25,
             hideView: false,
             aMode: UIView.AnimationOptions.curveEaseIn
        )

        ViewAnimation().fade(
            viewToAnimate: (saveLoadCTW)!,
            aDuration: 0.25,
            hideView: false,
            aMode: UIView.AnimationOptions.curveEaseIn
        )
        
    }
    
    @IBOutlet var playPauseBtn: UIButton!
    @IBAction func playPausBtnAction(_ sender: UIButton) {
        print("muteBtnAction")
        
        let realm_thr = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()

        if sessionData != nil {
            if sender.state == .highlighted {
            
                do {
                    try realm_thr.write {
                        sessionData![0].playbackPaused = !(sessionData![0].playbackPaused)
                    }
                } catch {
                    print("Error: \(error)")
                }
                
                if (sessionData![0].playbackPaused) {
                    playPauseBtn.setImage(resumePlaybackBtnImage,  for: .normal)
                } else {
                    playPauseBtn.setImage(pausePlaybackBtnImage, for: .normal)
                }
            }
        }
    }
    
    
    @IBOutlet var settingsBtn: UIButton!
    @IBAction func settingsBtnAction(_ sender: UIButton) {
//        beaconControlPanelContainerView.isHidden = true
        
        ViewAnimation().fade(
            viewToAnimate: (beaconControlPanelContainerView)!,
            aDuration: 0.25,
            hideView: true,
            aMode: UIView.AnimationOptions.curveEaseIn
        )
        
        
  
        toggleSettingsView(hideView: false)
        
        if !(checkPermissions()) {
            showLocationRequestMenu()
        }
        
    }
    
    
    @IBOutlet var hbgMenuBtn: UIButton!
    @IBAction func hbgMenuBtnAction(_ sender: UIButton) {
        print("hbgMenuBtnAction")
        
        if !mapView.isUserInteractionEnabled {
            unhibernate()
        }
        
        if (mainMenuCTV.isHidden) {
            sender.accessibilityLabel = "Main Menu Button H"
        } else {
            sender.accessibilityLabel = "Main Menu Button V"
        }
        if (sessionData[0].playbackPaused) {
            mainMenuVC?.muteBtnText.text = "RESUME"
        } else {
            mainMenuVC?.muteBtnText.text = "PAUSE"
        }
        
        ViewAnimation().fade(
            viewToAnimate: mainMenuCTV, aDuration: 0.25,
            hideView: !(mainMenuCTV.isHidden), aMode: UIView.AnimationOptions.curveEaseIn
        )
        
        updateMainMenuBtn(btn: sender, isActive: sender.accessibilityLabel == "Main Menu Button H")
        beaconControlPanelContainerView.isHidden = true
    
    }
    
 
    @IBAction func longPressGestureAction(_ sender: UILongPressGestureRecognizer) {
        // TODO: Remove state conditionals for continuous update (ios13/iPhone11+ bug)
        // TODO: Fix jitter or make static

        print("longPressGestureAction")
    
        let mapTouchLocation = sender.location(in: mapView)
        let touchLocationCoordinate = mapView.convert( mapTouchLocation, toCoordinateFrom: mapView )
        
        currScreenTouchPos = [touchLocationCoordinate.latitude, touchLocationCoordinate.longitude]
        let allowAdding = (sessionData.first?.trackingMode != 0)
        
        if sessionData.first?.trackingMode != 1 || !MainViewController.sessionMgmt.gpsPermissionGranted() {
            currentLocation = CLLocationCoordinate2D(latitude: touchLocationCoordinate.latitude, longitude: touchLocationCoordinate.longitude)
        }
        
        if sender.state == .began {
            lPress = true
            initScreenTouchPos = [
                Double(touchLocationCoordinate.latitude), Double(touchLocationCoordinate.longitude)]
            
            if !beaconIsSelected && allowAdding {
                let _ = addBeaconData( lat: initScreenTouchPos[0], lng: initScreenTouchPos[1], mView: mapView )
                mainUpdate()
            }
        }
        
        if sender.state == .began || sender.state == .cancelled {
            if (beaconIsSelected) {
                if (selectedBeaconAnnotation != nil) {
                 editBeaconRadius(
                     currScreenTouchPos: currScreenTouchPos,
                     selectedBeacon: selectedBeaconAnnotation!
                 )
                }

                if selectedBeaconData != nil {
                    updateBeaconOverlay( beacon: selectedBeaconData!, mapView: mapView )
                }
            }
     
        }
        
        if sender.state == .changed {
//          TODO: Fix jitter
            if (beaconIsSelected) {
                if (selectedBeaconAnnotation != nil) {
                    editBeaconRadius(
                       currScreenTouchPos: currScreenTouchPos,
                       selectedBeacon: selectedBeaconAnnotation!
                    )
                }
            }
        }
        
        
        if sender.state == .ended {
            lPress = false
            if (beaconIsSelected) {
                if (selectedBeaconAnnotation != nil) {
                    editBeaconRadius(
                        currScreenTouchPos: currScreenTouchPos,
                        selectedBeacon: selectedBeaconAnnotation!
                    )
                }

                if selectedBeaconData != nil {
                    updateBeaconOverlay( beacon: selectedBeaconData!, mapView: mapView )
                }
            }

            updateBeaconApperance()
        }
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("traitCollectionDidChange")

        if traitCollection.userInterfaceStyle == .light {
            uiTintColorText = UIColor.white
            uiTintColor = UIColor.white
        } else {
            uiTintColorText = UIColor.black
            uiTintColor = UIColor.black
        }
    }
    
    
    func checkPermissions() -> Bool {
        print("checkPermissions")
        
        if MainViewController.sessionMgmt.gpsPermissionGranted() {
            return true
        } else {
            return false
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        let touched = event?.allTouches?.first
        
        if (touched?.location(in: self.view).y)! > beaconControlPanelContainerView.frame.height {
            if controlPanelIsPresent && !beaconControlPanelContainerView.isHidden {
                toggleControlPanel(makeVisable: false)
            } else {
                beaconControlPanelContainerView.isHidden = true
            }
        }
 
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager")
    
        if sessionData.count > 0 {
            if sessionData.first?.trackingMode == 1 {
                
                currentLocation = CLLocationCoordinate2D(
                    latitude: (locations.last?.coordinate.latitude)!,
                    longitude: (locations.last?.coordinate.longitude)!
                )
            } else {
                mapView.showsUserLocation = true
            }
        }
    
    }
    
    
    @objc func mainUpdate() {
        print("mainUpdate")
        
//        if (sessionData.first!.holdNotes) {
//            modeBtnB.setImage(modeBtnB_a, for: .normal)
//        } else {
//            modeBtnB.setImage(modeBtnB_b, for: .normal)
//        }
//
//        if (sessionData.first!.trackingMode == 1) {
//            modeBtnA.setImage(modeBtnA_a, for: .normal)
//        } else {
//            modeBtnA.setImage(modeBtnA_b, for: .normal)
//        }
        
        if traitCollection.userInterfaceStyle == .light {
            uiTintColorText = UIColor.white
            uiTintColor = UIColor.white
        } else {
            uiTintColorText = UIColor.black
            uiTintColor = UIColor.black
        }
        
        if sessionData.count < 1 {
            MainViewController.sessionMgmt.initSessionData(mapView: mapView)
        }

        if !(sessionData.first?.playbackPaused)! {
            updateBeaconsInRange(userLat: currentLocation.latitude, userLng: currentLocation.longitude)

            MainViewController.orchester.updateNotes()
            
            mapUpdateTimer.invalidate()
            mapUpdateTimer = Timer.scheduledTimer(
                timeInterval: sessionData[0].mainUpdateRate, target: self, selector: #selector(mainUpdate), userInfo: nil, repeats: true
            )
        }
        
        let curActivity = self.locationManager.activityType
        if Int(sessionData[0].locationUpdateMode) == 0 && curActivity != CLActivityType.fitness {
            self.locationManager.activityType = CLActivityType.fitness
        }
        if Int(sessionData[0].locationUpdateMode) == 1 && curActivity != CLActivityType.automotiveNavigation {
            self.locationManager.activityType = CLActivityType.automotiveNavigation
        }
        
        MainViewController.orchester.updateOrchestra()
        
        // Check if longpress?
        if (!lPress) {
            updateBeaconApperance()
        }
        

    }

    
    override func viewDidLoad() {
        print("viewDidLoad")
                
        mapUpdateTimer.invalidate()
        MainViewController.sessionMgmt.rlmDataGC()
        
        initSession()
        initMapView()
        initBeacons()
        
        updateBeaconApperance()

        MainViewController.orchester.updateOrchestra()
        MainViewController.orchester.updateNotes()
        
        initSchedule()
        unhibernate()
        
        toggleDeviceGpsMode(currentMode: (sessionData.first?.trackingMode)!)
        
        initUI()
        
        if traitCollection.userInterfaceStyle == .dark {
            uiTintColorText = UIColor.white
            uiTintColor = UIColor.white
        } else {
            uiTintColorText = UIColor.black
            uiTintColor = UIColor.black
        }
        
        super.viewDidLoad()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if traitCollection.userInterfaceStyle == .light {
            uiTintColorText = UIColor.white
            uiTintColor = UIColor.white
        } else {
            uiTintColorText = UIColor.black
            uiTintColor = UIColor.black
        }
        
        if (segue.identifier == "keyPickerEmbedSegue") {
            keyPickerVC = segue.destination as? PianoRollCollectionViewController
        }
        
        if (segue.identifier == "MainMenuViewSegue") {
            mainMenuVC = segue.destination as? MainMenuViewController
            mainMenuVC?.mainVC = self
        }
        
        if (segue.identifier == "settingsViewEmbedSegue") {
            appSettingsVC = segue.destination.children[0].children[0] as? ControlCenterViewController
            
            for chv in segue.destination.children {
                for ch in chv.children {
                    let chvc = ch as? ControlCenterViewController
                    chvc?.mainVC = self
                }
            }
            appSettingsVC?.mainVC = self
        }
        
        if (segue.identifier == "saveLoadSegue") {
            saveLoadVC = segue.destination.children.first as? LayersTableViewController
            saveLoadVC?.mainVC = self
        }
    }
    
    
}
