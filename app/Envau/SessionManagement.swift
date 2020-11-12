import Foundation
import RealmSwift
import MapKit


class SessionManagement {


    lazy var realm = try! Realm()
    lazy var sessionData: Results<RLM_Session_14>?   = RLM_AsyncData().async_sessionData()
    lazy var beaconDataRLM: Results<RLM_BeaconData>? = RLM_AsyncData().async_beaconData()
    lazy var layers: Results<RLM_Layer_12>?          = RLM_AsyncData().async_layerData()
    lazy var keyItems: Results<RLM_Note>?            = RLM_AsyncData().async_keyData()
    
// -----------------------------------------------------------
    
    
    func rlmDataGC() {
        print("rlmDataGC")
        
        let realm = try! Realm()
        let layers: Results<RLM_Layer_12>? = RLM_AsyncData().async_layerData()
        let beaconDataRLM: Results<RLM_BeaconData>? = RLM_AsyncData().async_beaconData()
        
        if layers != nil && beaconDataRLM != nil {
            for b in beaconDataRLM! {
                
                var allLayerBeacons: [RLM_BeaconData] = []
                
                for l in layers! {
                    for b in l.beacons {
                        allLayerBeacons.append(b)
                    }
                }
                
                if b.deleted && allLayerBeacons.filter({$0.id == b.id}).count == 0 {
                    do {
                        try realm.write {
                            realm.delete(b)
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
        
    }

    
    func gpsPermissionGranted() -> Bool {
        print("gpsPermissionGranted")

        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }

    
    func initSessionData(mapView: MKMapView) {
        print("initSessionData")
        
        let realm = try! Realm()

        do {
            try realm.write {
                let sessionItem = RLM_Session_14()
                
                sessionItem.masterVolume = 1.0
                sessionItem.reverbAmount = 1.0
                
                sessionItem.delayMix = 0.0
                sessionItem.delayTime = 0.5
                sessionItem.delayFeedback = 0.5
                
                sessionItem.attackDuration = 0.5
                sessionItem.decayDuration = 1.0
                sessionItem.releaseDuration = 2.0
                
                sessionItem.carrierMultiplier = 1.0
                sessionItem.modulatingMultiplier = 1.0
                sessionItem.modulationIndex = 1.0
                
                sessionItem.trackingMode = 1

                realm.add(sessionItem)
            }
        } catch {
            print("Error: \(error)")
        }
        

        
    }
    
    
}
