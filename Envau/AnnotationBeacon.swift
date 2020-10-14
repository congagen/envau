import MapKit
import UIKit
import Foundation


class AnnotationBeacon: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var headline: String?

    var name: String?
    var title: String?
    var id: String
    

    init(anoData: RLM_BeaconData) {
        self.name = ""
        self.title = ""
        self.headline = ""
        self.id = ""
        
        self.coordinate = CLLocationCoordinate2D(
            latitude:  0,
            longitude: 0
        )
        
        super.init()
    }

}
