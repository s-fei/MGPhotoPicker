//
//  ViewController.swift
//  MGPhotoPicker
//
//  Created by spf on 12/20/2017.
//  Copyright (c) 2017 spf. All rights reserved.
//

import UIKit
import MGPhotoPicker

class ViewController: UIViewController {
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func action(_ sender: Any) {
        MGPhotoPicker.showView(selectMaxNum: 3, isEditDraw: true) { (models) in
            print("Models:\(String(describing: models))")
            self.imageView.image = models?.first?.fullScreen_Image()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

