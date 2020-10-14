import Foundation
import RealmSwift


class RLM_SessionData: Object {
    
    let projectData = List<RLM_BeaconData>()
    var beaconsInRange = List<RLM_BeaconData>()
    
    @objc dynamic var selectedBeacon: RLM_BeaconData? = nil
    @objc dynamic var name = ""
    
    @objc dynamic var masterVolume = 0.5
    @objc dynamic var reverbAmount = 1.0
    
    @objc dynamic var isMuted = false
    
    @objc dynamic var trackingPaused = false
    @objc dynamic var playbackPaused = false
    
    @objc dynamic var playbackMode = 3
    @objc dynamic var holdNotes = true
    @objc dynamic var ampFromDistance = true
    
    @objc dynamic var updateRate = 0.0
    @objc dynamic var ampValueWindowSize = 0.0
    
    @objc dynamic var attackDuration = 0.1
    @objc dynamic var decayDuration = 1.0
    @objc dynamic var releaseDuration = 1.0
    
    @objc dynamic var carrierMultiplier = 1.0
    @objc dynamic var modulatingMultiplier = 1.0
    @objc dynamic var modulationIndex = 0.0
    
    @objc dynamic var detuningMultiplier = 1.0
    @objc dynamic var detuningOffset = 0.0
    
    @objc dynamic var mainUpdateRate = 1.0
    @objc dynamic var locationUpdateMode = 1
    
    @objc dynamic var delayTime = 2.5
    @objc dynamic var delayFeedback = 0.0
    @objc dynamic var delayMix = 0.25
    @objc dynamic var delayDecay = 0.25
    @objc dynamic var delayDamping = 0.1
}
