import UIKit
import MapKit

import RealmSwift

import CoreLocation
import Foundation
import AVFoundation



extension MainViewController {

    
    func getAlertController(aTitle: String?, aMessage: String?, prefStyle: UIAlertController.Style) -> UIAlertController{
        
        var alertController = UIAlertController(
            title: aTitle,
            message: aMessage,
            preferredStyle: prefStyle
        )
        
        if getDeviceType() != 3 {
            alertController = UIAlertController(
                title: aTitle,
                message: aMessage,
                preferredStyle: UIAlertController.Style.alert
            )
        }
        
        return alertController
    }
    
    
    func addBlurView(bgView: UIView) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        bgView.backgroundColor = UIColor.clear
        blurEffectView.backgroundColor = UIColor.clear

        blurEffectView.frame = bgView.frame
        bgView.insertSubview(blurEffectView, at:1)
        
        return blurEffectView
    }
    
    func removeBlurView(bView: UIVisualEffectView){
        bView.removeFromSuperview()
    }
    

    func showLocationRequestMenu() {
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()!
        
        if sessionData != nil {
            if sessionData!.count > 0 {
                
                let alertController = getAlertController(
                    aTitle: nil,
                    aMessage: "Location tracking is currently disabled",
                    prefStyle: UIAlertController.Style.alert
                )
                alertController.view.tintColor = uiTintColor
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.bounds
                
                let openSettingsAction = UIAlertAction(title: "Edit Settings", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    let url = NSURL(string:UIApplication.openSettingsURLString)! as URL
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                    (result : UIAlertAction) -> Void in
                    print("")
                }
                
                alertController.addAction(openSettingsAction)
                alertController.addAction(cancelAction)

                if self.traitCollection.userInterfaceStyle == .dark {
                     alertController.view.tintColor = UIColor.white
                 } else {
                     alertController.view.tintColor = UIColor.black
                 }
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }

    
    func showBeaconActionsMenu(_ sender: UIButton) {
        
//        @IBOutlet var beaconControlPanelContainerView: UIView!
//        @IBOutlet var beaconControlPanelEffectView: UIVisualEffectView!
//        @IBOutlet var beaconControlPanel: UIView!
    
        beaconControlPanel.tintColorDidChange()
        
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()!
        
        if sessionData != nil {
            if sessionData!.count > 0 {
                
                let alertController = getAlertController(
                    aTitle: nil,
                    aMessage: nil,
                    prefStyle: UIAlertController.Style.actionSheet
                )
                alertController.view.tintColor = uiTintColor
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.bounds
                
                //            let setGpsAction = UIAlertAction(title: "Track URL", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                //                print("setGpsAction")
                //                // 1. Validate url
                //                // 2. Write DB
                //                // 3. Interpolate position
                //            }
                
                let clearAction = UIAlertAction(title: "Clear", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    
                    self.clearBeaconNotes()
                    if self.keyPickerVC != nil {
                        self.keyPickerVC?.resetPianoRoll()
                    }
                }
                
                let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    
                    self.deleteBeacons(anoList: [(sessionData![0].selectedBeacon)!], mapView: self.mapView)
                    self.toggleControlPanel(makeVisable: false)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(clearAction)
                //            alertController.addAction(setGpsAction)
                alertController.addAction(deleteAction)
                alertController.addAction(cancelAction)
                
                if self.traitCollection.userInterfaceStyle == .dark {
                     alertController.view.tintColor = UIColor.white
                 } else {
                     alertController.view.tintColor = UIColor.black
                 }
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func showClearMenu() {
        
        if sessionData.count > 0 {
            
            let alertController = getAlertController(
                aTitle: "Remove all spheres?", aMessage: nil, prefStyle: UIAlertController.Style.alert
            )
            
            alertController.view.tintColor = uiTintColor
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = self.view.bounds
            
            let clarAllAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let anoList = Array(self.beaconDataRLM)
                
                self.deleteBeacons(anoList: anoList, mapView: self.mapView)
                
                ViewAnimation().fade(
                    viewToAnimate: self.beaconControlPanelContainerView,
                    aDuration: 0.25,
                    hideView: true,
                    aMode: UIView.AnimationOptions.curveEaseIn)
                
                if !MainViewController.sessionMgmt.gpsPermissionGranted() {
                    self.showLocationRequestMenu()
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                (result : UIAlertAction) -> Void in
                
                if !MainViewController.sessionMgmt.gpsPermissionGranted() {
                    self.showLocationRequestMenu()
                }
            }
            
            alertController.addAction(clarAllAction)
            alertController.addAction(cancelAction)
            alertController.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            
            if self.traitCollection.userInterfaceStyle == .dark {
                 alertController.view.tintColor = UIColor.white
             } else {
                 alertController.view.tintColor = UIColor.black
             }
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
    }
    

    func showSleepTimerMenu() {
        
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()

        if (sessionData != nil) {
            if sessionData!.count > 0 {
                
                let alertController = getAlertController(
                    aTitle: "Select delay",
                    aMessage: nil,
                    prefStyle: UIAlertController.Style.actionSheet
                )
                alertController.view.tintColor = uiTintColor
                
                self.sleepTimer.invalidate()
                self.unhibernate()
                
                let setNoneAction = UIAlertAction(title: "None", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    self.setSleepTimer(delay: 0)
                }
                
                let setTenAction = UIAlertAction(title: "10min", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    self.setSleepTimer(delay: 10 * 60)
                }
                
                let setThirtyAction = UIAlertAction(title: "30min", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    self.setSleepTimer(delay: 30 * 60)
                }
                
                let setSixtyAction = UIAlertAction(title: "60min", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    self.setSleepTimer(delay: 60 * 60)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(setNoneAction)
                alertController.addAction(setTenAction)
                alertController.addAction(setThirtyAction)
                alertController.addAction(setSixtyAction)
                alertController.addAction(cancelAction)
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.bounds
                alertController.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                
                if self.traitCollection.userInterfaceStyle == .dark {
                     alertController.view.tintColor = UIColor.white
                 } else {
                     alertController.view.tintColor = UIColor.black
                 }
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func showMainMenu(_ sender: UIButton) {
        
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        if (sessionData != nil) {
            if sessionData!.count > 0 {
                
                var muteBtnTitle = ""
                
                if sessionData![0].playbackPaused{
                    muteBtnTitle = "RESUME"
                } else {
                    muteBtnTitle = "PAUSE"
                }
                
                let alertController = getAlertController(
                    aTitle: nil,
                    aMessage: nil,
                    prefStyle: UIAlertController.Style.actionSheet
                )
                
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = self.view.bounds
                
                let settingsAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    self.toggleSettingsView(hideView: false)
                    
                    if !MainViewController.sessionMgmt.gpsPermissionGranted() {
                        self.showLocationRequestMenu()
                    }
                }
                
                let muteAction = UIAlertAction(title: muteBtnTitle, style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    
                    let realm = try! Realm()
                    let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()!
                    
                    if sessionData != nil {
                        if !self.controlPanelIsPresent {
                            
                            ViewAnimation().fade(
                                viewToAnimate: self.beaconControlPanelContainerView,
                                aDuration: 0.25,
                                hideView: true,
                                aMode: UIView.AnimationOptions.curveEaseIn)
                        }
                        
                        do {
                            try realm.write {
                                sessionData![0].playbackPaused = !sessionData![0].playbackPaused
                            }
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                    
                }
                
                let timerAction = UIAlertAction(title: "Pause", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    if !self.controlPanelIsPresent {
                        
                        ViewAnimation().fade(
                            viewToAnimate: self.beaconControlPanelContainerView,
                            aDuration: 0.25,
                            hideView: true,
                            aMode: UIView.AnimationOptions.curveEaseIn)
                    }
                    
                    self.showSleepTimerMenu()
                }
                
                let resetAction = UIAlertAction(title: "Reset", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                    self.unhibernate()
                    self.resetSettings()
                    
                    let realm = try! Realm()
                    let layers: Results<RLM_Layer_12>? = RLM_AsyncData().async_layerData()!
                    
                    if layers != nil {
                        for l in layers! {
                            do {
                                try realm.write {
                                    l.active = false
                                }
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }
                    
                    self.toggleDeviceGpsMode(currentMode: 1)
                    self.showClearMenu()
                }
                
                let cancelAction = UIAlertAction(title: "↩︎", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in }
                
                alertController.addAction(settingsAction)
                alertController.addAction(muteAction)
                alertController.addAction(timerAction)
                alertController.addAction(resetAction)
                alertController.addAction(cancelAction)
                alertController.view.tintColor = uiTintColor
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        
    }

}
