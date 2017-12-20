//
//  BasePhotoViewController.swift
//  MogoRenter
//
//  Created by song on 16/8/11.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//
/**
 相册部分基类啊
 */

import UIKit

class BasePhotoViewController: UIViewController {
    
    /*! 最大可选张数 */
    var selectMaxNum:Int = MGPhotoPicker.selectMaxNumMethod()
    /*! 取消和完成后的回调 */
    var completionBlock:((_ imageModels:[MGImageModel]?,_ viewController:BasePhotoViewController?) ->())!
    
    var statusBarStyle = UIApplication.shared.statusBarStyle
    var statusBarHidden = UIApplication.shared.isStatusBarHidden
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
