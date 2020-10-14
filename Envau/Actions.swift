import UIKit
import MapKit
import RealmSwift
import CoreLocation
import Foundation
import AVFoundation


extension MainViewController {

    
    func setTrackingMode(trMode: Int){
        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        if (sessionData != nil) {
            do {
                try realm.write {
                    sessionData?.first?.trackingMode = trMode
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    

    func toggleDeviceGpsMode(currentMode: Int) {
        print("toggleDeviceGpsMode")

        if currentMode == 1 {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
            
            focusMap(focusLat: mapView.userLocation.coordinate.latitude,
                     focusLng: mapView.userLocation.coordinate.longitude)
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func toggleSettingsView(hideView: Bool) {
        print("toggleSettingsView")

        appSettingsVC?.updateControls()
        
        ViewAnimation().fade(
            viewToAnimate: self.settingsFxView,
            aDuration: 0.25,
            hideView: hideView,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
        ViewAnimation().fade(
            viewToAnimate: self.settingsContainerView,
            aDuration: 0.25,
            hideView: hideView,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
    }
    
    
    func toggleLayersView(hideView: Bool) {
        print("toggleLayersView")

        ViewAnimation().fade(
            viewToAnimate: self.settingsFxView,
            aDuration: 0.0,
            hideView: hideView,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
        ViewAnimation().fade(
            viewToAnimate: self.saveLoadCTW,
            aDuration: 0.0,
            hideView: hideView,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
    }
    
    
    @objc func shutdownAudio() {
        print("shutdownAudio")
        
        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        MainViewController.orchester.masterMixer.volume = 0
        MainViewController.orchester.toggleAudiokit(active: false)
        
        if (sessionData != nil) {
            do {
                try realm.write {
                    sessionData![0].playbackPaused = true
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
    }
    
    
    @objc func unhibernate(){
        print("unhibernate")
        DispatchQueue.main.async {
            self.mainUpdate()
        }

        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        if !mapUpdateTimer.isValid {
        }
        
        if sleepTimer.isValid{
            sleepTimer.invalidate()
        }
        
        mapView.layer.opacity = 1.0
        mapView.isUserInteractionEnabled = true
        MainViewController.orchester.toggleAudiokit(active: true)
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        if sessionData != nil {
            MainViewController.orchester.masterMixer.volume = sessionData![0].masterVolume
        }
        
        
        do {
            //try AVAudioSession.sharedInstance().setCategory( .playback, with: AVAudioSession.CategoryOptions.mixWithOthers )
            try AVAudioSession.sharedInstance().setCategory(.playback, options: AVAudioSession.CategoryOptions.mixWithOthers )
        } catch {
            print("Failed to set audio session category: mixWithOthers, Error: \(error)")
        }
        
        setTrackingMode(trMode: 1)
        
        if sessionData != nil {
            do {
                try realm.write {
                    sessionData![0].playbackPaused = false
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
    }

    
    @objc func hibernate() {
        print("hibernate")
        
        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        if sessionData != nil {
            if sessionData!.count > 0 {
                
                mapView.isUserInteractionEnabled = false
                mapView.layer.opacity = 0.5
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                locationManager.allowsBackgroundLocationUpdates = false
                locationManager.stopUpdatingLocation()
                
                MainViewController.orchester.liftAllKeys()
                
                do {
                    try realm.write {
                        sessionData![0].playbackPaused = !sessionData![0].playbackPaused
                        sessionData![0].playbackMode = 1
                    }
                } catch {
                    print("Error: \(error)")
                }
                
                Timer.scheduledTimer(
                    timeInterval: 20,
                    target: self,
                    selector: #selector(shutdownAudio),
                    userInfo: nil,
                    repeats: false
                )
                
            }
        }
        
    }
    
    
    func showLocationSettings() {
        if let url = NSURL(string:UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url as URL)
        }
    }
    
    
    func focusMap(focusLat: Double, focusLng: Double) {
        print("focusMap")
        
        _ = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        if sessionData != nil {
            if sessionData!.count > 0 && !(Bool(sessionData?.first?.trackingMode == 0)) {
                let center = CLLocationCoordinate2D(latitude: focusLat, longitude: focusLng)
                let region = MKCoordinateRegion(center: center, span: mapView.region.span)
                
                mapView.setRegion(region, animated: true)
                mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            }
        }
    }
    

    func toggleControlPanel(makeVisable: Bool) {
        print("toggleControlPanel")
        
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()

        beaconControlPanel.layer.masksToBounds = true
        beaconControlPanel.layer.cornerRadius = 20
        
        beaconControlPanelEffectView.layer.masksToBounds = true
        beaconControlPanelEffectView.layer.cornerRadius = 20
        
        beaconControlPanelContainerView.clipsToBounds = false
        
        if self.traitCollection.userInterfaceStyle == .dark {
            beaconControlPanelContainerView.layer.shadowColor = UIColor.white.cgColor
        } else {
            beaconControlPanelContainerView.layer.shadowColor = UIColor.black.cgColor
        }
        
        beaconControlPanelContainerView.layer.shadowOffset = CGSize.zero
        beaconControlPanelContainerView.layer.shadowRadius = 10
        beaconControlPanelContainerView.layer.shadowOpacity = Float(0.1)
        beaconControlPanelContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: beaconControlPanelContainerView.bounds, cornerRadius: 20).cgPath
        
        if traitCollection.userInterfaceStyle != .dark {
            beaconControlPanelEffectView.tintColor = .lightGray
            beaconControlPanelEffectView.backgroundColor = .white
            beaconControlPanel.backgroundColor = .white
        } else {
            beaconControlPanelEffectView.tintColor = .darkGray
            beaconControlPanelEffectView.backgroundColor = .darkGray
            beaconControlPanel.backgroundColor = .darkGray
        }
        
        ViewAnimation().fade(
            viewToAnimate: self.beaconControlPanelContainerView,
            aDuration: 0.0,
            hideView: false,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
        if sessionData != nil {
            if sessionData!.count > 0 {
                if makeVisable {
                    if selectedBeaconAnnotation != nil && keyPickerVC != nil {
                        keyPickerVC?.resetPianoRoll()
                        
                        let lat = Double((selectedBeaconAnnotation?.coordinate.latitude)!)
                        let lng = Double((selectedBeaconAnnotation?.coordinate.longitude)!)
                        let hl = String(String(lat).prefix(6) + ", " + String(lng).prefix(6))
                        
                        beaconHeadline.text = hl
                    }
                }
                
                if makeVisable {
                    
                    ViewAnimation().fade(
                        viewToAnimate: self.beaconControlPanelContainerView,
                        aDuration: 0.0,
                        hideView: true,
                        aMode: .curveEaseInOut
                    )
                    controlPanelIsPresent = false
                    
                    ViewAnimation().fade(
                        viewToAnimate: self.beaconControlPanelContainerView,
                        aDuration: 0.4,
                        hideView: false,
                        aMode: .curveEaseInOut
                    )
                    controlPanelIsPresent = true
                    
                } else {
                    
                    ViewAnimation().fade(
                        viewToAnimate: self.beaconControlPanelContainerView,
                        aDuration: 0.4,
                        hideView: true,
                        aMode: .curveEaseInOut
                    )
                    controlPanelIsPresent = false
                    
                }
                
            }
        }

    }

    
    func setSleepTimer(delay: Double){
        print("setSleepTimer")

        self.sleepTimer.invalidate()
        
        //playModeBtn.setImage(UIImage(named: "hiber_btn_on"), for: UIControlState.normal)
        
        self.sleepTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(delay),
            target: self,
            selector: #selector(self.hibernate),
            userInfo: nil,
            repeats: false
        )
    }
    
    
    func resetSettings(){
        print("resetSettings")
        
        let realm = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()

        if sessionData != nil {
            do {
                try realm.write {
                    sessionData![0].masterVolume = 1.0
                    
                    sessionData![0].reverbFeedback = 0.8
                    sessionData![0].reverbCutoff = 4000
                    sessionData![0].reverbAmount = 0.8
                    
                    sessionData![0].attackDuration = 0.5
                    sessionData![0].decayDuration = 1.0
                    sessionData![0].releaseDuration = 2.0
                    
                    sessionData![0].dryWetFxMix = 0.1
                    
                    sessionData![0].audioFxAmoutA = 1000
                    sessionData![0].audioFxAmoutB = 0.2
                    sessionData![0].audioFxAmoutC = 0.2
                    sessionData![0].audioFxAmoutD = 0.2
                    
                    sessionData![0].carrierMultiplier = 1.0
                    sessionData![0].modulatingMultiplier = 1.0
                    sessionData![0].modulationIndex = 1.0
                    
                    sessionData![0].detuningMultiplier = 1.0
                    sessionData![0].mainUpdateRate = 1.0
                    
                    sessionData![0].locationUpdateMode = 1
                    sessionData![0].trackingMode = 1
                    
                    sessionData![0].holdNotes = true
                    sessionData![0].ampFromDistance = true
                    
                    self.toggleDeviceGpsMode(currentMode: 1)
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
    }

    
}
