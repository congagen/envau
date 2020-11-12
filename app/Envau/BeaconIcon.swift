import Foundation
import UIKit
import MapKit
import RealmSwift

extension MainViewController: MKMapViewDelegate, UIActionSheetDelegate {

    
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKMarkerAnnotationView {
            userPinView = annotation
            userPinView.transform = CGAffineTransform(translationX: 50, y: 50)
        }
        
        if let annotation = annotation as? AnnotationBeacon {
            let identifier = "Annotation"
            var anoView: MKAnnotationView? = nil
            
            //let matching = beaconDataRLM.filter({$0.active == true && $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude})
            
            // TODO: Conditonal:
            
            let anoData = beaconDataRLM.filter({ $0.id == annotation.title })
            
            if (anoData.count > 0) {
                if (anoData.first!.active) {
                    anoView?.image = UIImage(named:"beacon_active")!
                } else {
                    anoView?.image = UIImage(named:"beacon_deactivated")!
                }
            }
            
            print("SettingIcon: DA")
            
            anoView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            anoView?.setSelected(false, animated: true)
            anoView?.isDraggable = false
            anoView?.canShowCallout = false
            
            return anoView
        } else {
            return nil
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("didAdd")
        for view in views {
            // TODO: Conditonal:
            let initImg = UIImage(named: "beacon_active")
            view.image = initImg
            
            UIView.transition(
                with: view, duration: 0.25,
                options: [.beginFromCurrentState, .transitionCrossDissolve],
                animations: {
                    view.image = initImg },
                completion: nil
            )
        }
    }
 
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let anoData = beaconDataRLM.filter({ $0.id == view.annotation?.title })
        var newImg = UIImage(named: "beacon_deactivated")
        
        let touchMode = (sessionData.first?.trackingMode == 0)

        
        // TODO: Conditional
        if (anoData.count > 0) {
            if (!touchMode) {
                if anoData.first!.active {
                    newImg = UIImage(named: "beacon_active_selected")
                } else {
                    newImg = UIImage(named: "beacon_deactivated_selected")
                }
            } else {
                  if anoData.first!.active {
                      newImg = UIImage(named: "beacon_active")
                  } else {
                      newImg = UIImage(named: "beacon_deactivated")
                  }
            }
            
        }


        if view.annotation != nil && sessionData[0].trackingMode != 0 {
            
            if view.annotation!.isKind(of: MKUserLocation.self) == false {
                
                view.image = newImg
                selectedBeaconAnnotation = view.annotation
                
                do {
                    try realm.write {
                        if anoData.count > 0 {
                            sessionData[0].selectedBeacon = anoData.first
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
                
                UIView.transition(
                    with: view, duration: 0.25,
                    options: [.beginFromCurrentState, .transitionCrossDissolve],
                    animations: {
                        view.image = newImg },
                    completion: nil
                )
                
                beaconIsSelected = true
                toggleControlPanel(makeVisable: true)
            }
        } else {
            print("Error: didSelect: view.annotation = nil")
        }
    }

    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        
        let anoData = beaconDataRLM.filter({ $0.id == view.annotation?.title })
        var newImg = UIImage(named: "beacon_active")
        
        // TODO: Conditional
        if (anoData.count > 0) {
            
            if anoData.first!.active{
                newImg = UIImage(named: "beacon_active")
            } else {
                newImg = UIImage(named: "beacon_deactivated")
            }
        }
        
        UIView.transition(
            with: view, duration: 0.25,
            options: [.beginFromCurrentState, .transitionCrossDissolve],
            animations: {
                view.image = newImg },
            completion: nil
        )
        
        do {
            try realm.write {
                sessionData[0].selectedBeacon = nil
            }
        } catch {
            print("Error: \(error)")
        }
        
        beaconIsSelected = false
        // TODO REMOVE?:
        DispatchQueue.main.async {
            self.updateBeaconApperance()
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("rendererFor overlay: MKOverlay")
        
        if let annotation = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: annotation)
            circleRenderer.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
            
//            if self.traitCollection.userInterfaceStyle == .dark {
//                circleRenderer.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1)
//            } else {
//                circleRenderer.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
//            }
            
            circleRenderer.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            
            circleRenderer.lineWidth = 1.5
            return circleRenderer
        } else {
            let polyRenderer = MKPolygonRenderer(overlay: overlay)
            polyRenderer.fillColor = UIColor.blue
            return polyRenderer
        }
    
    }

    
}




























































//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
//        var newPosition = [Double]()
//        let draggedBeacon = view.annotation as! Beacon
//        let activeRadius = draggedBeacon.annoData.activeRadius
//        let activeNotes = draggedBeacon.annoData.activeNotes
//        let anoId = draggedBeacon.annoData.id
//
//        if newState == .ending {
//            newPosition = [Double((view.annotation?.coordinate.latitude)!),
//                           Double((view.annotation?.coordinate.longitude)!)]
//
//            MainViewController.beaconMgmt.deleteDraggedAnotation()
//
//            do {
//                try realm.write {
//                    draggedBeacon.annoData.deleted = true
//                    if sessionData.count > 0 {
//                        sessionData[0].selectedBeacon?.deleted = true
//                    }
//                }
//            } catch {
//                print("Error: \(error)")
//            }
//
//            mapView.removeAnnotation(view.annotation!)
//            let newAno = MainViewController.beaconMgmt.addBeaconData(
//                lat: newPosition[0],
//                lng: newPosition[1],
//                mView: mapView
//            )
//
//            do {
//                try realm.write {
//                    newAno?.name = String(newPosition[0]).prefix(6) + ", " + String(newPosition[1]).prefix(6)
//                    newAno?.activeRadius = activeRadius
//                    newAno?.id = anoId
//
//                    for i in activeNotes {
//                        newAno?.activeNotes.append(i)
//                    }
//                }
//            } catch {
//                print("Error: \(error)")
//            }
//
//            if sessionData.first?.playbackMode == 1 {
//                let _ = MainViewController.beaconMgmt.updateBeacons(
//                    mapView: mapView,
//                    currentLocation: currentLocation
//                )
//
//                MainViewController.orchester.updateOrchestra()
//                MainViewController.orchester.updateNotes()
//            }
//        }
//    }
