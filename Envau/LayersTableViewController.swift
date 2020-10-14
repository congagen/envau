//
//  LayersTableViewController.swift
//  Envau
//
//  Created by Tim Sandgren on 2018-03-27.
//  Copyright © 2018 Anetherwhisker. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation


class LayersTableViewController: UITableViewController {

    var mainVC: MainViewController? = nil
    var textField: UITextField? = nil
    var selectedLayer: RLM_Layer_12? = nil
    
    var colorA = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
    var colorB = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1)

    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    lazy var realm = try! Realm()
    lazy var beaconDataRLM: Results<RLM_BeaconData> = { self.realm.objects(RLM_BeaconData.self) }()
    lazy var sessionData: Results<RLM_Session_14> = { self.realm.objects(RLM_Session_14.self) }()
    lazy var rlmLayers: Results<RLM_Layer_12> = { self.realm.objects(RLM_Layer_12.self) }()
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        if (mainVC != nil) {
            mainVC?.toggleLayersView(hideView: true)
        }
    }
    
    
    func saveLayer() {
        print("saveLayer")

        let saLayer = RLM_Layer_12()

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd - HH:mm"
        let result = formatter.string(from: date)

        
        do {
            try realm.write {
                saLayer.active = false
                saLayer.id = UUID().uuidString
                saLayer.name = String(result)
                
                for b in (sessionData.first?.sessionBeacons)! {
                    if b.deleted == false {
                        saLayer.beacons.append(b)
                    }
                }
                
                self.realm.add(saLayer)
            }
        } catch {
            print("Error: \(error)")
        }
        
        mainVC?.updateBeaconApperance()
    }
    
    
    @IBAction func shareBtnAction(_ sender: UIBarButtonItem) {
        // Iterate active layers?
    }
    
    
    @IBAction func saveBtnActon(_ sender: UIBarButtonItem) {
        print("saveBtnActon")
        
        saveLayer()
        
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
    }
    
    
    func getDeviceType() -> Int {
        print("getDeviceType")

        switch UIDevice.current.userInterfaceIdiom {
        case .tv:
            return 1
        case .pad:
            return 2
        case .phone:
            return 3
        case .unspecified:
            return 4
        default:
            return 5
        }
    }
    
    
    func configurationTextField(textField: UITextField!)
    {
        if let _ = textField {
            self.textField = textField!
            if selectedLayer != nil {
                self.textField?.text = selectedLayer?.name
            }
        }
    }
    
    
    func handleCancel(alertView: UIAlertAction!)
    {
        print(self.textField?.text! ?? "")
    }
    
    
    func handleOk(alertView: UIAlertAction!)
    {
        do {
            try realm.write {
                if selectedLayer != nil {
                    if textField?.text != nil { selectedLayer?.name = (textField?.text)! }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
        
        mainVC?.updateBeaconApperance()

    }

    
    func showRenameAlert(aMessage: String?){
        print("showRenameAlert")

        let alert = UIAlertController(
            title: "",
            message: "",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:handleOk))
        
        if self.traitCollection.userInterfaceStyle == .dark {
            alert.view.tintColor = UIColor.white
        } else {
            alert.view.tintColor = UIColor.black
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getAllLayerBeacons(onlyActive: Bool) -> [RLM_BeaconData]? {
        
        var bcns: [RLM_BeaconData]? = []
        
        for l in rlmLayers {
            if onlyActive {
                if l.active {
                    for b in l.beacons {
                        bcns?.append(b)
                    }
                }
            } else {
                for b in l.beacons {
                    bcns?.append(b)
                }
            }
        }
        
        return bcns!
    }
    
    
    func toggleLayer(layer: RLM_Layer_12, solo: Bool) {
        
        var activeLayerBeacons = getAllLayerBeacons(onlyActive: true)

        do {
            try realm.write {
                layer.active = !layer.active
//
//                if solo {
//                    sessionData.first?.sessionBeacons.removeAll()
//                }
            }
        } catch {
            print("Error: \(error)")
        }
    
        do {
            try realm.write {
                if layer.active {
                    for b in layer.beacons {
                        b.deleted = false
                        let beaconInSession = sessionData.first?.sessionBeacons.filter( {$0.id == b.id} )
                        if beaconInSession?.count == 0 {
                            sessionData.first?.sessionBeacons.append(b)
                        }
                    }
                } else {
                    activeLayerBeacons = getAllLayerBeacons(onlyActive: true)
                    
                    for b in beaconDataRLM {
                        let beaconInLayer = layer.beacons.filter({$0.id == b.id}).count > 0
                        let beaconInOtherActiveLayers = (activeLayerBeacons?.filter( {$0.id == b.id} ).count)! > 0
                        
                        if beaconInLayer && !beaconInOtherActiveLayers {
                            b.deleted = true
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        DispatchQueue.main.async {
            self.mainVC?.updateBeaconApperance()
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        
        if rlmLayers[section].id != "" {
            selectedLayer = rlmLayers[section]
            if selectedLayer != nil {
                
                if selectedLayer!.active {
                    cell.textLabel?.textColor = colorA
                    cell.detailTextLabel?.textColor = colorA
                } else {
                    cell.textLabel?.textColor = colorB
                    cell.detailTextLabel?.textColor = colorB
                }
                
                self.tableView.reloadData()
                self.tableView.reloadInputViews()

                self.toggleLayer(layer: self.selectedLayer!, solo: false)
                
            }
        }
    }

    
    func RemoveLayer(indexP: IndexPath) {
        
        let section = indexP.section
        let layer = rlmLayers[section]
    
        do {
            try realm.write {
                realm.delete(layer)
            }
        } catch {
            print("Error: \(error)")
        }
        
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
        
        mainVC?.updateBeaconApperance()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none

        let layer = rlmLayers[section]
        
        cell.textLabel?.text = String(layer.name)
        cell.detailTextLabel?.text = "Spheres: " + String(layer.beacons.count)
        cell.restorationIdentifier = layer.id
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.accessibilityHint = String(layer.name) + " Spheres: " + String(layer.beacons.count)
        
        if layer.active {
            cell.textLabel?.textColor = colorA
            cell.detailTextLabel?.textColor = colorA
        } else {
            cell.textLabel?.textColor = colorB
            cell.detailTextLabel?.textColor = colorB
        }
  
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let section = indexPath.section
        
        if rlmLayers[section].id != "" {
            selectedLayer = rlmLayers[section]
        }
        
//        let renameAction = UITableViewRowAction(style: .normal, title: "Rename") { (rowAction, indexPath) in
//            self.showRenameAlert(aMessage: self.selectedLayer?.name)}
//        renameAction.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0, alpha: 0.5)
//
//        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
//            self.RemoveLayer(indexP: indexPath)}
//        deleteAction.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
        let renameAction = UIContextualAction(
            style: .normal,
            title: "Rename",
            handler: {_,_,_  in self.showRenameAlert(aMessage: self.selectedLayer?.name)}
        )
                
        let deleteAction = UIContextualAction(
            style: .normal,
            title: "Delete",
            handler: {_,_,_  in self.RemoveLayer(indexP: indexPath)}
        )
                
        return UISwipeActionsConfiguration(actions: [renameAction, deleteAction])
    }
    

    func refresh() {
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.userInterfaceStyle == .dark {
             colorA = UIColor.white
             colorB = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
          } else {
             colorA = UIColor.black
             colorB = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
          }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("APPEAR")
        if self.traitCollection.userInterfaceStyle == .dark {
            colorA = UIColor.white
            colorB = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
         } else {
            colorA = UIColor.black
            colorB = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
         }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rlmLayers.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.allowsMultipleSelection = false

        return screenHeight * 0.11
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    

}
























//    func appendActiveLayerBeaconsBeacons(removeOthers: Bool) {
//        let activeLayers = rlmLayers.filter( { $0.active == true } )
//
//        print("UpdateBeacons: ActiveLayers: " + String(activeLayers.count))
//
//        if removeOthers {
//            sessionData.first?.sessionBeacons.removeAll()
//        }
//
//        for l in activeLayers {
//            for b in l.beacons {
//                b.deleted = false
//
//                if sessionData.first?.sessionBeacons.filter({$0.id == b.id}).count == 0 {
//                    do {
//                        try realm.write {
//                            sessionData.first?.sessionBeacons.append(b)
//                            b.deleted = false
//                        }
//                    } catch {
//                        print("Error: \(error)")
//                    }
//                }
//            }
//        }
//    }










//func toggleLayer(layer: RLM_Layer_12, solo: Bool) {
//    print("toggleLayer: " + layer.id)
//
//    // ALERT?: APPEND / SWITCH
//
//    // let allLayerBeacons = getAllLayerBeacons()
//
//    for l in rlmLayers {
//        do {
//            try realm.write {
//                l.active = (l.id == layer.id) && !layer.active
//            }
//        } catch {
//            print("Error: \(error)")
//        }
//    }
//
//    do {
//        try realm.write {
//            // IF SWITCH:
//            //         On:  Iterate SessionBeacons -> Remove if not in LayerBeacons
//            //         Off: Remove from SessionBeacons if in allLayerBeacons
//            if solo {
//                sessionData.first?.sessionBeacons.removeAll()
//            }
//
//            // On:  Iterate LayerBeacons -> Insert in Session if not exists
//            // Off: None
//            if layer.active {
//                print("layer.active: " + String(layer.active))
//                for b in layer.beacons {
//                    print("Adding: " + String(b.id))
//
//                    b.deleted = false
//                    let beaconInSession = sessionData.first?.sessionBeacons.filter( {$0.id == b.id} )
//
//                    if beaconInSession?.count == 0 {
//                        sessionData.first?.sessionBeacons.append(b)
//                    }
//                }
//            }
//        }
//    } catch {
//        print("Error: \(error)")
//    }
//
//}
