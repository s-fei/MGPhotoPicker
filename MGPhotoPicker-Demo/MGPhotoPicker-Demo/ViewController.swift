//
//  ViewController.swift
//  MGPhotoPicker-Demo
//
//  Created by song on 2017/8/13.
//  Copyright © 2017年 song. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func click(_ sender: Any) {
        
        MGPhotoPicker.showView(selectMaxNum: 3, isEditDraw: true) { (models) in
            print("Models:\(String(describing: models))")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

