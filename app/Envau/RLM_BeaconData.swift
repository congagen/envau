import Foundation
import RealmSwift

class RLM_BeaconData: Object {
    
    var activeNotes = List<RLM_Note>()
    @objc dynamic var name = ""
    @objc dynamic var id = ""
    
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var activeRadius = 100
    @objc dynamic var currentDistance = 100
    
    @objc dynamic var deleted = false
    @objc dynamic var active = false
    @objc dynamic var muted = false
    
    @objc dynamic var instrumentType = 1
    @objc dynamic var sampleName = ""
    
    @objc dynamic var amplitide = 1.0
    @objc dynamic var amplitideFromDistance = true
    
    @objc dynamic var octave = 5
    @objc dynamic var rootNote = 6
    @objc dynamic var noteValueName = ""
    
    @objc dynamic var holdKeys = false
    
    @objc dynamic var noteDuration = 1.0
    @objc dynamic var interval = 1.0
    @objc dynamic var repeating = false

}
