import UIKit
import MapKit
import RealmSwift
import CoreLocation
import Foundation
import AVFoundation


extension MainViewController {

    
    func initUI() {
        view.tintColor = uiTintColor
        //updateMainMenuBtn(btn: hbgMenuBtn, isActive: false)
        
        ViewAnimation().fade(
            viewToAnimate: self.beaconControlPanelContainerView,
            aDuration: 0.25,
            hideView: true,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
        // TODO:
        if traitCollection.userInterfaceStyle == .light {
            //hbgBtnOpenImage  = UIImage(named: "hbg_open_b")!
            //hbgBtnCloseImage = UIImage(named: "hbg_close_b")!
        } else {
            //hbgBtnOpenImage  = UIImage(named: "hbg_open_w")!
            //hbgBtnCloseImage = UIImage(named: "hbg_close_w")!
        }
        
        layerBtn.isHidden = true
        settingsBtn.isHidden = true
        playPauseBtn.isHidden = true
        
        if (playPauseBtn.isHidden) {
            toggleUiBtn.setImage(toggleUiBtnImageUp,  for: .normal)
        } else {
            toggleUiBtn.setImage(toggleUiBtnImageDown,  for: .normal)
        }
        
        toggleSettingsView(hideView: true)
    }
    
    
    func initSchedule() {
        if !mapUpdateTimer.isValid {
            mapUpdateTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(mainUpdate),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    
    func getDeviceType() -> Int {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .tv:
            return 1
        case .pad:
            return 2
        case .phone:
            return 3
        case .unspecified:
            return 4
        default:
            return 5
        }
    }
    
    
    func initBeacons() {
        
        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
     
        if sessionData != nil {
            if (sessionData?.first?.sessionBeacons.count)! > 0 {
                for instr in (sessionData?.first?.sessionBeacons)! {
                    do {
                        try realm.write {
                            instr.active = false
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        for ano in mapView.annotations {
            let anoView = mapView.view(for: ano)
            
            // TODO: Conditional
            anoView?.image = UIImage(named:"beacon_active")!
        }
    }
    
    
    func initMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.pointOfInterestFilter = .none
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.userLocation.title = ""
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    
    func initSession() {
        
        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>?   = RLM_AsyncData().async_sessionData()
        let beaconDataRLM: Results<RLM_BeaconData>? = RLM_AsyncData().async_beaconData()
        let layers: Results<RLM_Layer_12>?          = RLM_AsyncData().async_layerData()
        
        if sessionData != nil {
            if sessionData!.count < 1 {
                MainViewController.sessionMgmt.initSessionData(mapView: mapView)
            }
        }
        
        do {
            try realm.write {
                if layers != nil && beaconDataRLM != nil {
                    if layers!.count > 0 {
                        for l in layers! {
                            if l.active {
                                for b in l.beacons {
                                    if sessionData?.first?.sessionBeacons.filter({ $0.id == b.id }).count == 0 {
                                        sessionData?.first?.sessionBeacons.append(b)
                                    }
                                    b.deleted = false
                                }
                            }
                        }
                    } else {
                        for b in beaconDataRLM! {
                            sessionData?.first?.sessionBeacons.append(b)
                        }
                    }
                }
                
                
            }
        } catch {
            print("Error: \(error)")
        }
        

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: AVAudioSession.CategoryOptions.mixWithOthers )
        } catch {
            print("Failed to set audio session category: mixWithOthers, Error: \(error)")
        }
    }
    

}
