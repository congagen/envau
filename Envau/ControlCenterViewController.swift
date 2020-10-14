//
//  ControlCenterViewController.swift
//  Envau
//
//  Created by Tim Sandgren on 2018-04-25.
//  Copyright © 2018 Anetherwhisker. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit


class ControlCenterViewController: UIViewController {

    lazy var realm = try! Realm()
    lazy var sessionData: Results<RLM_Session_14>?   = RLM_AsyncData().async_sessionData()
    lazy var beaconDataRLM: Results<RLM_BeaconData>? = RLM_AsyncData().async_beaconData()
    lazy var layers: Results<RLM_Layer_12>?          = RLM_AsyncData().async_layerData()
    lazy var keyItems: Results<RLM_Note>?            = RLM_AsyncData().async_keyData()
    
    var mainVC: MainViewController? = nil
    
    //    var containerView: UIView? = nil
    
    
    // -----------------------------------------------------------------------------

    
    func saveSettings(propName: String, propValue: Double) {
        
        if sessionData != nil {
            if sessionData!.count > 0 {
                do {
                    try realm.write {
                        switch propName {
                            
                            
                        case "masterVolume":
                            sessionData![0].masterVolume = propValue
                            
                        case "reverbAmount":
                            sessionData![0].reverbAmount = propValue
                            
                        case "reverbFeedback":
                            sessionData![0].reverbFeedback = propValue
                            
                        case "reverbCutoff":
                            sessionData![0].reverbCutoff = propValue
                            
                        case "audioEffectA":
                            sessionData![0].audioFxAmoutA = propValue
                            
                        case "audioEffectB":
                            sessionData![0].audioFxAmoutB = propValue
                            
                        case "audioEffectC":
                            sessionData![0].audioFxAmoutC = propValue
                            
                        case "dryWetFxMix":
                            sessionData![0].dryWetFxMix = propValue
                            
                        case "attack":
                            sessionData![0].attackDuration = propValue
                        case "decay":
                            sessionData![0].decayDuration = propValue
                        case "release":
                            sessionData![0].releaseDuration = propValue
                            
                        case "updateRate":
                            sessionData![0].updateRate = propValue
                            
                        case "carrier":
                            sessionData![0].carrierMultiplier = propValue
                        case "detuningMultiplier":
                            sessionData![0].detuningMultiplier = propValue
                        case "detuningOffset":
                            sessionData![0].detuningOffset = propValue
                            
                        case "mainUpdateRate":
                            sessionData![0].mainUpdateRate = propValue
                            
                        case "touchMode":
                            sessionData![0].trackingMode = Int(propValue)
                            mainVC?.toggleDeviceGpsMode(currentMode: Int(propValue))
                            
                        case "locationUpdateMode":
                            sessionData![0].locationUpdateMode = Int(propValue)
                            
                        case "holdNotes":
                            sessionData![0].holdNotes = Int(propValue) == 1
                            
                        case "seqMode":
                            sessionData![0].sequencerMode = Int(propValue)
                            
                        case "seqType":
                            sessionData![0].sequencerType = Int(propValue)
                            
                        case "seqSpeed":
                            sessionData![0].sequencerSpeed = Int(propValue)
                            
                        default:
                            break
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        
        }
    }

    
    @IBAction func closeNavBtnAction(_ sender: UIBarButtonItem) {
        mainVC?.toggleSettingsView(hideView: true)
    }
    
    // ---------------------------------------------------------------------------
    // MIXER
    
    @IBOutlet var masterVolumeSliderOutlet: UISlider?
    @IBAction func masterVolumeSliderAction(_ sender: UISlider) {
        saveSettings(propName: "masterVolume", propValue: Double(sender.value))
    }
    
    
    @IBOutlet var audioEffectA_Outlet: UISlider!
    @IBAction func audioEffectA_Action(_ sender: UISlider) {
        saveSettings(propName: "audioEffectA", propValue: Double(sender.value))
    }
    
    @IBOutlet var dryWetFxSliderOutlet: UISlider!
    @IBAction func dryWetFxSliderAction(_ sender: UISlider) {
        saveSettings(propName: "dryWetFxMix", propValue: Double(sender.value))
    }
    
    
    @IBOutlet var reverbSliderOutlet: UISlider!
    @IBAction func reverbSliderAction(_ sender: UISlider) {
        saveSettings(propName: "reverbAmount", propValue: Double(sender.value))
    }
    
    // ---------------------------------------------------------------------------
    // ENVELOPE
    
    
    @IBOutlet var attackSliderOutlet: UISlider!
    @IBAction func attackSliderAction(_ sender: UISlider) {
        saveSettings(propName: "attack", propValue: Double(sender.value))
    }
    
    
    @IBOutlet var decaySliderOutlet: UISlider!
    @IBAction func decaySliderAction(_ sender: UISlider) {
        saveSettings(propName: "decay", propValue: Double(sender.value))
    }
    
    
    @IBOutlet var releaseSliderOutlet: UISlider!
    @IBAction func releaseSliderAction(_ sender: UISlider) {
        saveSettings(propName: "release", propValue: Double(sender.value))
    }
    
    
    // ---------------------------------------------------------------------------
    // SYSTEM
    
    @IBOutlet var positionSourceSwitch: UISwitch!
    @IBAction func positionSourceSwitch(_ sender: UISwitch) {
        // GPS = 1 / Touch = 0
        if sender.isOn {
            saveSettings(propName: "touchMode", propValue: Double(0))
        } else {
            saveSettings(propName: "touchMode", propValue: Double(1))
        }
    }
    
    
    @IBOutlet var poistionUpdateSpeedSwitch: UISwitch!
    @IBAction func positionUpdateSpeedSwitchAction(_ sender: UISwitch) {
        // (0 = Walking, 1 = Car)
        
        if sender.isOn {
            saveSettings(propName: "locationUpdateMode", propValue: Double(1))
        } else {
            saveSettings(propName: "locationUpdateMode", propValue: Double(0))
        }        
    }
    
    
    @IBOutlet var playModeSwitch: UISwitch!
    @IBAction func playModeSwitchAction(_ sender: UISwitch) {
        
        if sender.isOn {
            saveSettings(propName: "holdNotes", propValue: Double(1))
        } else {
            saveSettings(propName: "holdNotes", propValue: Double(0))
        }
    }
    
    
    // ---------------------------------------------------------------------------
    
    
    //    @IBAction func permissionsSettingsBtnAtcon(_ sender: UIButton) {
    //        let url = NSURL(string:UIApplicationOpenSettingsURLString)! as URL
    //
    //        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    //    }
    
    
    // -----------------------------------------------------------------------------
    
    
    func updateControls() {
        
        if sessionData != nil {
            if sessionData!.count > 0 {
                if (masterVolumeSliderOutlet != nil) { masterVolumeSliderOutlet?.value = Float((sessionData![0].masterVolume)) }
                
                if (playModeSwitch != nil) {
                    if sessionData![0].holdNotes {
                        playModeSwitch.isOn = true
                    } else {
                        playModeSwitch.isOn = false
                    }
                }
                
                if (audioEffectA_Outlet != nil) { audioEffectA_Outlet.value = Float(sessionData![0].audioFxAmoutA) }
                
                if (dryWetFxSliderOutlet != nil) { dryWetFxSliderOutlet.value = Float(sessionData![0].dryWetFxMix) }
                if (reverbSliderOutlet != nil) { reverbSliderOutlet.value = Float(sessionData![0].reverbAmount) }
                
                if (attackSliderOutlet != nil) { attackSliderOutlet.value = Float((sessionData![0].attackDuration)) }
                if (decaySliderOutlet != nil) { decaySliderOutlet.value = Float((sessionData![0].decayDuration)) }
                if (releaseSliderOutlet != nil) { releaseSliderOutlet.value = Float((sessionData![0].releaseDuration)) }
                
                if (poistionUpdateSpeedSwitch != nil) {
                    poistionUpdateSpeedSwitch.isOn = (Int(sessionData![0].locationUpdateMode)) != 1
                }
                
                if (positionSourceSwitch != nil) {
                    positionSourceSwitch.isOn = (sessionData![0].trackingMode == 0)
                }
            
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateControls()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
