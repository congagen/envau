//
//  MixerViewController.swift
//  Envau
//
//  Created by Tim Sandgren on 2018-04-05.
//  Copyright © 2018 Anetherwhisker. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit


class MixerSettingsVC: UIViewController {
    
    var mainVC: MainViewController? = nil
    
    lazy var realm = try! Realm()
    var containerView: UIView? = nil
    var mainViewController: MainViewController? = nil
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        //print("viewDidAppear")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
