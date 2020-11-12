//
//  MainMenuViewController.swift
//  Envau
//
//  Created by Tim Sandgren on 2018-03-08.
//  Copyright © 2018 Anetherwhisker. All rights reserved.
//

import UIKit
import RealmSwift

class MainMenuViewController: UIViewController {
    
    var mainVC: MainViewController? = nil
    
    
    @IBAction func settingsBtnAction(_ sender: UIButton) {
        print("settingsBtnAction")

        if mainVC != nil {
            mainVC?.updateMainMenuBtn(btn: (mainVC?.hbgMenuBtn)!, isActive: false)
            
            ViewAnimation().fade(
                viewToAnimate: (self.view.superview)!,
                aDuration: 0.5,
                hideView: true,
                aMode: UIView.AnimationOptions.curveEaseIn)
            
            mainVC?.toggleSettingsView(hideView: false)
            
            if !(mainVC?.checkPermissions())! {
                mainVC?.showLocationRequestMenu()
            }
        }
    }
    
    
    @IBAction func saveLoadBtnAction(_ sender: UIButton) {
        print("saveLoadBtnAction")

        mainVC?.updateMainMenuBtn(btn: (mainVC?.hbgMenuBtn)!, isActive: false)
        
        if ((mainVC?.saveLoadVC) != nil) {
            mainVC?.saveLoadVC!.refresh()
        }
        
        ViewAnimation().fade(
            viewToAnimate: (mainVC?.settingsFxView)!,
            aDuration: 0.25,
            hideView: false,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
        ViewAnimation().fade(
            viewToAnimate: (view.superview)!,
            aDuration: 0.25,
            hideView: true,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
        ViewAnimation().fade(
            viewToAnimate: (mainVC?.saveLoadCTW)!,
            aDuration: 0.25,
            hideView: false,
            aMode: UIView.AnimationOptions.curveEaseIn)
        
    }
    
    @IBOutlet var muteBtnText: UILabel!
    
    @IBAction func muteBtnAction(_ sender: UIButton) {
        print("muteBtnAction")
        
        let realm_thr = try! Realm()
        let sessionData: Results<RLM_Session_14>? = RLM_AsyncData().async_sessionData()

        if sessionData != nil {
            if sender.state == .highlighted {
                
                if mainVC != nil {
                    do {
                        try realm_thr.write {
                            sessionData![0].playbackPaused = !(sessionData![0].playbackPaused)
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                    
                    if (sessionData![0].playbackPaused) {
                        muteBtnText.text = "RESUME"
                    } else {
                        muteBtnText.text = "PAUSE"
                    }
                } else {
                    print("mainVC == nil")
                }
            }
        }
        
    }
    
    
    @IBAction func resetBtnAction(_ sender: UIButton) {
        if mainVC != nil {
            mainVC?.unhibernate()
            
            mainVC?.resetSettings()
            
            mainVC?.showClearMenu()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveLoadView" {
            let saveLoadVC = segue.destination.children[0] as? LayersTableViewController
            saveLoadVC?.mainVC = mainVC
        }
    }
    

}
