//
//  RLM_Layer.swift
//  Envau
//
//  Created by Tim Sandgren on 2018-03-27.
//  Copyright © 2018 Anetherwhisker. All rights reserved.
//

import Foundation
import RealmSwift


class RLM_Layer_12: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var active: Bool = false
    
    var beacons = List<RLM_BeaconData>()
}
