//import Foundation
//import RealmSwift
//import UIKit
//
//class SettingsViewController: UITableViewController {
//    
//    var mainVC: MainViewController? = nil
//    
//    let realm = try! Realm()
////    var containerView: UIView? = nil
//    var mainViewController: MainViewController? = nil
//    
//    lazy var sessionData: Results<RLM_Session_12> = {
//        self.realm.objects(RLM_Session_12.self) }()
//
//    
//// -----------------------------------------------------------------------------
//    
//    
//    func saveSettings(propName: String, propValue: Double) {
//        if sessionData.count > 0 {
//            do {
//                try realm.write {
//                    switch propName {
//                        
//                        
//                    case "masterVolume":
//                        sessionData[0].masterVolume = propValue
//                        
//                    case "reverbAmount":
//                        sessionData[0].reverbAmount = propValue
//                        
//                    case "reverbFeedback":
//                        sessionData[0].reverbFeedback = propValue
//                        
//                    case "reverbCutoff":
//                        sessionData[0].reverbCutoff = propValue
//                        
//                    case "audioEffectA":
//                        sessionData[0].audioFxAmoutA = propValue
//                        
//                    case "audioEffectB":
//                        sessionData[0].audioFxAmoutB = propValue
//                        
//                    case "audioEffectC":
//                        sessionData[0].audioFxAmoutC = propValue
//                        
//                    case "dryWetFxMix":
//                        sessionData[0].dryWetFxMix = propValue
//                        
//                    case "attack":
//                        sessionData[0].attackDuration = propValue
//                    case "decay":
//                        sessionData[0].decayDuration = propValue
//                    case "release":
//                        sessionData[0].releaseDuration = propValue
//                        
//                    case "updateRate":
//                        sessionData[0].updateRate = propValue
//                        
//                    case "carrier":
//                        sessionData[0].carrierMultiplier = propValue
//                    case "detuningMultiplier":
//                        sessionData[0].detuningMultiplier = propValue
//                    case "detuningOffset":
//                        sessionData[0].detuningOffset = propValue
//                        
//                    case "mainUpdateRate":
//                        sessionData[0].mainUpdateRate = propValue
//                        
//                    case "trackingMode":
//                        sessionData[0].trackingMode = Int(propValue)
//                        
//                    case "locationUpdateMode":
//                        sessionData[0].locationUpdateMode = Int(propValue)
//                        
//                    case "activationMode":
//                        sessionData[0].holdNotes = Int(propValue) == 1
//                        
//                    case "seqMode":
//                        sessionData[0].sequencerMode = Int(propValue)
//                        
//                    case "seqType":
//                        sessionData[0].sequencerType = Int(propValue)
//                        
//                    case "seqSpeed":
//                        sessionData[0].sequencerSpeed = Int(propValue)
//                        
//                    default:
//                        break
//                    }
//                }
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
//    
//    
//    
//    
//    @IBAction func closeBtn(_ sender: UIBarButtonItem) {
//        mainViewController?.toggleSettingsView(hideView: true)
//    }
//
//
//    func sliceValString(rawString: String, sliceLen: Int) -> String {
//        return String(rawString.prefix(sliceLen))
//    }
//
//    
//    // ---------------------------------------------------------------------------
//    // MIXER
//    
//    @IBOutlet var masterVolumeSliderOutlet: UISlider?
//    @IBAction func masterVolumeSliderAction(_ sender: UISlider) {
//        saveSettings(propName: "masterVolume", propValue: Double(sender.value))
//    }
//    
//    
//    @IBOutlet var audioEffectA_Outlet: UISlider!
//    @IBAction func audioEffectA_Action(_ sender: UISlider) {
//        saveSettings(propName: "audioEffectA", propValue: Double(sender.value))
//    }
//    
////    @IBOutlet var audioEffectB_Outlet: UISlider!
////    @IBAction func audioEffectB_Action(_ sender: UISlider) {
////        saveSettings(propName: "audioEffectB", propValue: Double(sender.value))
////    }
//    
////    @IBOutlet var audioEffectC_Outlet: UISlider!
////    @IBAction func audioEffectC_Action(_ sender: UISlider) {
////        saveSettings(propName: "audioEffectC", propValue: Double(sender.value))
////    }
//    
////    @IBOutlet var reverbCutoffSliderOutlet: UISlider!
////    @IBAction func reverbCutoffSliderAction(_ sender: UISlider) {
////        saveSettings(propName: "reverbCutoff", propValue: Double(sender.value))
////    }
//    
//    
////    @IBOutlet var reverbFeedbackSliderOutlet: UISlider!
////    @IBAction func reverbFeedbackSliderAction(_ sender: UISlider) {
////        saveSettings(propName: "reverbFeedback", propValue: Double(sender.value))
////    }
//    
//    @IBOutlet var reverbSliderOutlet: UISlider!
//    @IBAction func reverbSliderAction(_ sender: UISlider) {
//        saveSettings(propName: "reverbAmount", propValue: Double(sender.value))
//    }
//
//    @IBOutlet var dryWetFxSliderOutlet: UISlider!
//    @IBAction func dryWetFxSliderAction(_ sender: UISlider) {
//        saveSettings(propName: "dryWetFxMix", propValue: Double(sender.value))
//    }
//    
//    
//    // ---------------------------------------------------------------------------
//    // ENVELOPE
//    
//    
//    @IBOutlet var attackSliderOutlet: UISlider!
//    @IBAction func attackSliderAction(_ sender: UISlider) {
//        saveSettings(propName: "attack", propValue: Double(sender.value))
//    }
//    
//    
//    @IBOutlet var decaySliderOutlet: UISlider!
//    @IBAction func decaySliderAction(_ sender: UISlider) {
//        saveSettings(propName: "decay", propValue: Double(sender.value))
//    }
//    
//    
//    @IBOutlet var releaseSliderOutlet: UISlider!
//    @IBAction func releaseSliderAction(_ sender: UISlider) {
//        saveSettings(propName: "release", propValue: Double(sender.value))
//    }
//    
//    
//    // ---------------------------------------------------------------------------
//    // SYSTEM
//    
//    @IBOutlet var trackingModeSegmentControl: UISegmentedControl!
//    @IBAction func trackingModeSegmentControlAction(_ sender: UISegmentedControl) {
//        saveSettings(propName: "trackingMode", propValue: Double(sender.selectedSegmentIndex))
//        print(sender.selectedSegmentIndex)
//    }
//    
//    @IBOutlet var locationUpdateOutlet: UISegmentedControl!
//    @IBAction func locationUpdateSegmetAction(_ sender: UISegmentedControl) {
//        saveSettings(propName: "locationUpdateMode", propValue: Double(sender.selectedSegmentIndex))
//        print(sessionData[0].locationUpdateMode)
//    }
//    
//    @IBOutlet var activationModeSegmentOutlet: UISegmentedControl!
//    @IBAction func activationModeSegmentAction(_ sender: UISegmentedControl) {
//        saveSettings(propName: "activationMode", propValue: Double(sender.selectedSegmentIndex))
//    }
//    
//    
//    // ---------------------------------------------------------------------------
//    
//    
////    @IBAction func permissionsSettingsBtnAtcon(_ sender: UIButton) {
////        let url = NSURL(string:UIApplicationOpenSettingsURLString)! as URL
////
////        UIApplication.shared.open(url, options: [:], completionHandler: nil)
////    }
//    
//
//// -----------------------------------------------------------------------------
//
//    
//    func updateControls() {
//        if sessionData.count > 0 {
//            masterVolumeSliderOutlet?.value = Float((sessionData[0].masterVolume))
//   
//            if activationModeSegmentOutlet != nil {
//                
//                if sessionData[0].holdNotes {
//                    activationModeSegmentOutlet.selectedSegmentIndex = 1
//                } else {
//                    activationModeSegmentOutlet.selectedSegmentIndex = 0
//                }
//                
//                audioEffectA_Outlet.value = Float(sessionData[0].audioFxAmoutA)
//                
//                dryWetFxSliderOutlet.value = Float(sessionData[0].dryWetFxMix)
//                reverbSliderOutlet.value = Float(sessionData[0].reverbAmount)
//          
//                attackSliderOutlet.value = Float((sessionData[0].attackDuration))
//                decaySliderOutlet.value = Float((sessionData[0].decayDuration))
//                releaseSliderOutlet.value = Float((sessionData[0].releaseDuration))
//                
//                trackingModeSegmentControl.selectedSegmentIndex = sessionData[0].trackingMode
//                locationUpdateOutlet.selectedSegmentIndex = Int(sessionData[0].locationUpdateMode)
//                
//            }
//        }
//        
//        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        updateControls()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//
//}
