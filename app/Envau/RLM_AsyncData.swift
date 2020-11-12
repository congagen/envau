//
//  AsyncData.swift
//  Envau
//
//  Created by Tim Sandgren on 2019-04-15.
//  Copyright © 2019 Abstraqata. All rights reserved.
//

import Foundation
import RealmSwift

class RLM_AsyncData {
    
    lazy var realm = try! Realm()
    
    lazy var beaconDataRLM: Results<RLM_BeaconData> = {
        self.realm.objects(RLM_BeaconData.self) }()
    
    lazy var sessionData: Results<RLM_Session_14> = {
        self.realm.objects(RLM_Session_14.self) }()
    
    lazy var layers: Results<RLM_Layer_12> = {
        self.realm.objects(RLM_Layer_12.self) }()
    
    lazy var keyItems: Results<RLM_Note> = {
        self.realm.objects(RLM_Note.self) }()
    
    
    //    let sessionData: Results<RLM_Session_14>   = { realm.objects(RLM_Session_14.self) }()
    func async_sessionData() -> Results<RLM_Session_14>? {
//        let realm_thr = try! Realm()
//        let results:   Results<RLM_Session_14> = { realm_thr.objects(RLM_Session_14.self) }()
//
//        let objectRef = ThreadSafeReference(to: results)
//
//        guard let r_data = realm_thr.resolve(objectRef) else {
//            return nil
//        }
        
        return sessionData
    }
    
    
    //    let beaconDataRLM: Results<RLM_BeaconData> = { realm.objects(RLM_BeaconData.self) }()
    func async_beaconData() -> Results<RLM_BeaconData>? {
//        let realm_thr = try! Realm()
//        let results:   Results<RLM_BeaconData> = { realm_thr.objects(RLM_BeaconData.self) }()
//
//        let objectRef = ThreadSafeReference(to: results)
//        guard let r_data = realm_thr.resolve(objectRef) else {
//            return nil
//        }
        
        return beaconDataRLM
    }
    
    //    let layers: Results<RLM_Layer_12>          = { realm.objects(RLM_Layer_12.self) }()
    func async_layerData() -> Results<RLM_Layer_12>? {
//        let realm_thr = try! Realm()
//        let s_Data:   Results<RLM_Layer_12> = { realm_thr.objects(RLM_Layer_12.self) }()
//
//        let objectRef = ThreadSafeReference(to: s_Data)
//        guard let r_data = realm_thr.resolve(objectRef) else {
//            return nil
//        }
        
        return layers
    }
    
    //    let keyItems: Results<RLM_Note>            = { realm.objects(RLM_Note.self) }()
    func async_keyData() -> Results<RLM_Note>? {
//        let realm_thr = try! Realm()
//        let s_Data:   Results<RLM_Note> = { realm_thr.objects(RLM_Note.self) }()
//
//        let objectRef = ThreadSafeReference(to: s_Data)
//        guard let r_data = realm_thr.resolve(objectRef) else {
//            return nil
//        }
        
        return keyItems
    }
    
    
    
    
    
}
