import Foundation
import RealmSwift
import MapKit
import CoreLocation


//class BeaconManagement {

extension MainViewController {
    
    
    func clearBeaconNotes(){
        print("clearBeaconNotes")
        
        
        let currentBeacon = sessionData[0].selectedBeacon
        
        do {
            try realm.write {
                currentBeacon?.activeNotes.removeAll()
            }
        } catch {
            print("Error: \(error)")
        }
        
//        for nData in (currentBeacon?.activeNotes)! {
//            removeBeaconNote(keyVal: nData.noteValue)
//        }
    }

    func addBeaconNote(keyVal: Int)  {
        print("addBeaconNote")
        
        do {
            try realm.write {
                let newKey = RLM_Note()
                newKey.noteValue = keyVal
                sessionData[0].selectedBeacon?.activeNotes.append(newKey)
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
    func removeBeaconNote(keyVal: Int) {
        print("removeBeaconNote")
        
        for ndata in (sessionData[0].selectedBeacon?.activeNotes)!.enumerated() {
            if ndata.element.noteValue == keyVal {
                do {
                    try realm.write {
                        sessionData[0].selectedBeacon?.activeNotes.remove(at: ndata.offset)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        
    }
    
    
    func setBeaconIcon(ano: MKAnnotation, isActive: Bool, mapView: MKMapView) {
        print("setBeaconIcon")
        
        let anoView = mapView.view(for: ano)
        let anoPinView: MKAnnotationView? = anoView
        let seelectedInMap = mapView.selectedAnnotations.first
        let touchMode = (sessionData.first?.trackingMode == 0)

        if isActive {
            // print("setBeaconIcon: beacon_active")
            
            if seelectedInMap?.coordinate.latitude == ano.coordinate.latitude && seelectedInMap?.coordinate.longitude == ano.coordinate.longitude && !touchMode {
                
                // TODO: Conditional
                anoPinView?.image = UIImage(named:"beacon_active_selected")!
                
            } else {
                
                // TODO: Conditional
                anoPinView?.image = UIImage(named:"beacon_active")!
            }
            //anoPinView?.setSelected(true, animated: true)
            
        } else {
            
            if seelectedInMap?.coordinate.latitude == ano.coordinate.latitude && seelectedInMap?.coordinate.longitude == ano.coordinate.longitude && !touchMode {
                
                // TODO: Conditional
                anoPinView?.image = UIImage(named:"beacon_deactivated_selected")!
            } else {
                
                // TODO: Conditional
                anoPinView?.image = UIImage(named:"beacon_deactivated")!
            }
            //anoPinView?.setSelected(false, animated: false)
        }
        
        anoView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    
    func deleteBeacons(anoList: [RLM_BeaconData], mapView: MKMapView) {
        print("deleteBeacons")
        
        let keepList: List<RLM_BeaconData>? = nil
        
        for b in (sessionData.first?.sessionBeacons)! {
            if anoList.filter( { $0.id ==  b.id } ).count == 0 {
                keepList?.append(b)
            }
        }
        
        do {
            try Realm().write {
                if keepList != nil {
                    sessionData.first?.sessionBeacons = keepList!
                }
                
                for b in anoList {
                    b.deleted = true
                    updateBeaconOverlay(beacon: b, mapView: mapView)
                }
                
            }
        } catch {
            print("Error: \(error)")
        }
        
        updateBeaconApperance()
    }
    

    func addBeacon(anoDbData: RLM_BeaconData, mapView: MKMapView) {
        print("addBeacon")
        let realm = try! Realm()
        
        let ano = AnnotationBeacon(anoData: anoDbData)
        let lat = anoDbData.latitude
        let lng = anoDbData.longitude
        
        ano.name  = anoDbData.id
        ano.title = anoDbData.id
        ano.headline = String(lat).prefix(6) + ", " + String(lng).prefix(6)
        ano.coordinate.latitude  = lat
        ano.coordinate.longitude = lng
        
        mapView.addAnnotation(ano)
        
        do {
            try realm.write {
                let utl = NoteNames()
                
                let keyStr = utl.getNoteName(
                    noteNumber: anoDbData.rootNote, noteOctave: anoDbData.octave)
                
                anoDbData.noteValueName = keyStr[0]
            }
        } catch {
            print("Error: \(error)")
        }
        
        setBeaconIcon(ano: ano, isActive: anoDbData.active, mapView: mapView)
        
    }
    
    
    func addBeaconData(lat: Double, lng: Double, mView: MKMapView) -> RLM_BeaconData? {
        print("addBeaconData")
        let newBeacon = RLM_BeaconData()
        let initRadius = (abs(mView.region.span.latitudeDelta) + 0.1) * 5000
        
        do {
            try realm.write {
                newBeacon.id = UUID().uuidString
                newBeacon.name = String(lat).prefix(6) + ", " + String(lng).prefix(6)
                newBeacon.noteValueName = ""
                newBeacon.latitude = lat
                newBeacon.longitude = lng
                newBeacon.repeating = false
                newBeacon.interval = 1.0
                newBeacon.noteDuration = 0.1
                newBeacon.amplitide = 0.5
                newBeacon.activeRadius = Int(initRadius)
                newBeacon.deleted = false
                realm.add(newBeacon)
                
                sessionData.first?.sessionBeacons.append(newBeacon)
            }
        } catch {
            print("Error: \(error)")
        }
        
        addBeacon(anoDbData: newBeacon, mapView: mapView)
        updateBeaconOverlay(beacon: newBeacon, mapView: mapView)

        return newBeacon
    }
    
    
    func addBeaconOverlay(initOverlay: Bool, curNote: RLM_BeaconData,  mapView: MKMapView) {
        print("addBeaconOverlay")
        
        var currentOverlays: [MKOverlay] = []
        
        if !initOverlay {
            currentOverlays = mapView.overlays.filter {
                $0.coordinate.latitude == curNote.latitude && $0.coordinate.longitude == curNote.longitude
            }
        }
        
        if currentOverlays.count == 0 || initOverlay {
            let areaCircle = MKCircle(center: CLLocationCoordinate2DMake(
                curNote.latitude, curNote.longitude), radius: Double(curNote.activeRadius)
            )
            
            
            mapView.addOverlay(areaCircle)
            overlayCircleCache![curNote.id] = areaCircle
            overlayCache![curNote.id] = areaCircle
        }
        
//        let polygonPoints: [CLLocationCoordinate2D] = [
//            CLLocationCoordinate2D(latitude: -40, longitude: -40),
//            CLLocationCoordinate2D(latitude: 40,  longitude: 40),
//            CLLocationCoordinate2D(latitude: 0,   longitude: 40),
//            CLLocationCoordinate2D(latitude: 40,  longitude: 0)
//        ]
//        let poly = MKPolygon(coordinates: polygonPoints, count: polygonPoints.count)
//        mapView.addOverlay(poly)
        
    }
    
    
    func editBeaconRadius(currScreenTouchPos: [Double], selectedBeacon: MKAnnotation) {
        print("editBeaconRadius")
                
        let touchPosition = CLLocation(latitude: currScreenTouchPos[0], longitude: currScreenTouchPos[1])
        let beaconPosition = CLLocation( latitude: (selectedBeacon.coordinate.latitude), longitude: (selectedBeacon.coordinate.longitude) )
        var touchDistanceFromAno = touchPosition.distance(from: beaconPosition)
        
        if touchDistanceFromAno > 1000000000 { touchDistanceFromAno = 1000000000 }
    
        do {
            try realm.write {
                let anoData = beaconDataRLM.filter({ $0.id == selectedBeacon.title })
                
                if anoData.count > 0 {
                    anoData.first?.activeRadius = Int(touchDistanceFromAno)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    func updateBeaconOverlay(beacon: RLM_BeaconData, mapView: MKMapView) {
        print("updateBeaconOverlay")
        
        let currentOverlays = mapView.overlays.filter{
            $0.coordinate.latitude == beacon.latitude && $0.coordinate.longitude == beacon.longitude
        }
     
        if (sessionData.first?.sessionBeacons.filter({$0.id == beacon.id}).count == 0) || beacon.deleted {
            print("sessionData.first?.sessionBeacons.filter -> DELETE")
            if currentOverlays.count > 0 { mapView.removeOverlay(currentOverlays[0]) }
        } else {
            if currentOverlays.count > 0 {
                if (overlayCircleCache?.keys.contains(beacon.id))! {
                    let currentC = overlayCircleCache![beacon.id]
                    if currentC!.coordinate.latitude != beacon.latitude || currentC?.coordinate.longitude != beacon.longitude || Double(currentC!.radius) != Double(beacon.activeRadius) {
                        mapView.removeOverlays([currentOverlays[0]])
                        addBeaconOverlay(initOverlay: true, curNote: beacon, mapView: mapView)
                    }
                } else {
                    mapView.removeOverlays([currentOverlays[0]])
                    addBeaconOverlay(initOverlay: true, curNote: beacon, mapView: mapView)
                }
            } else {
                addBeaconOverlay(initOverlay: true, curNote: beacon, mapView: mapView)
            }
        }
    }
    
    
    func updateBeaconsInRange(userLat: Double, userLng: Double){
        print("updateBeaconsInRange")

        let beaconsInRange = getBeaconsInRange(userLat: userLat, userLng: userLng, useManualRange: false, manualRange: 0.0)
        
        do {
            try realm.write {
                sessionData.first!.beaconsInRange.removeAll()
                
                for a in beaconsInRange!.enumerated() {
                    
                    sessionData.first?.beaconsInRange.insert(a.element, at: a.offset)
                    
                    if sessionData[0].ampFromDistance {
                        a.element.currentDistance = Int(
                            CLLocation(
                                latitude: userLat, longitude: userLng).distance(
                                    from: CLLocation(latitude: a.element.latitude, longitude: a.element.longitude)
                            )
                        )
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
    func getBeaconsInRange(userLat: Double, userLng: Double, useManualRange: Bool, manualRange: Double) -> [RLM_BeaconData]? {
        print("getBeaconsInRange")
        
        let userLoc = CLLocation(latitude: userLat, longitude: userLng)        
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()
        
        if sessionData != nil {
            if((sessionData!.first?.sessionBeacons.count)! > 0) {
                if (useManualRange) {
                    return (sessionData!.first?.sessionBeacons.filter {
                        (!$0.deleted && CLLocation(
                            latitude: $0.latitude, longitude: $0.longitude).distance(from: userLoc) < Double(manualRange))})!
                } else {
                    return (sessionData!.first?.sessionBeacons.filter {
                        (!$0.deleted && CLLocation(
                            latitude: $0.latitude, longitude: $0.longitude).distance(from: userLoc) < Double($0.activeRadius))})!
                }
            }
        }
        
        return []
    }

    
    // TODO
    // func updateBeaconApperance() -> [RLM_BeaconData]? {
    func updateBeaconApperance() {
        print("----------------------------------------------------------------------")
        print("updateBeacons")

        let currentLocation: CLLocationCoordinate2D = mapView.userLocation.coordinate
        
        let sessionBeaconsInRange = getBeaconsInRange(
            userLat: currentLocation.latitude, userLng: currentLocation.longitude, useManualRange: false, manualRange: 0.0
        )
        
        updateBeaconsInRange(userLat: currentLocation.latitude, userLng: currentLocation.longitude)

        for bec in beaconDataRLM {
            
            do {
                try realm.write {
                    bec.active = !(sessionBeaconsInRange!.contains(bec)) && bec.activeNotes.count > 0
                    //bec.active = bec.activeNotes.count > 0
                }
            } catch {
                print("Error: \(error)")
            }
                        
            let mapviewBeacon = mapView.annotations.filter {
                $0.coordinate.latitude == bec.latitude && $0.coordinate.longitude == bec.longitude
            }
            
            if mapviewBeacon.count > 0 {
                if !bec.deleted {
                    setBeaconIcon(ano: mapviewBeacon[0], isActive: bec.active, mapView: mapView)
                } else {
                    mapView.removeAnnotation(mapviewBeacon[0])
                }
            } else {
                if !bec.deleted {
                    addBeacon(anoDbData: bec, mapView: mapView)
                }
            }
            
            updateBeaconOverlay(beacon: bec, mapView: mapView)

        }
    
        
        //return sessionBeaconsInRange
    }
    

    func deleteDraggedAnotation() {
        //        if self.sessionData[0].selectedBeacon != nil {
        //            self.deleteBeacons(anoList: [(self.sessionData[0].selectedBeacon)!])
        //        }
    }
    


}
