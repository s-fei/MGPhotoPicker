//
//  MGImageModel.swift
//  MogoRenter
//
//  Created by song on 16/8/13.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

import UIKit
import AssetsLibrary

let KScreenWidth = UIScreen.main.bounds.width
let KScreenHeight = UIScreen.main.bounds.height

let kColors_MogoLightBg = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1)
let kColors_MogoLightGrayBg = UIColor(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1)
let kColors_MogoLightLine = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1)

let subheadFont = UIFont.systemFont(ofSize: 14)

let PathBundle = Bundle(for: MGImageModel.self).path(forResource: "Resources", ofType: "bundle")

let ResourcesBundle:Bundle? = (PathBundle != nil ? Bundle(path: PathBundle!) : nil)

public class MGImageModel: NSObject {
    /*! 赋值使用 不要取值！！！！！！*/
    var aset:ALAsset?
    /*! 赋值使用 不要取值！！！！！！*/
    var thumbImage:UIImage?
    /*! 赋值使用 不要取值！！！！！！*/
    var aspectThumbImage:UIImage?
    /*! 赋值使用 不要取值！！！！！！*/
    var fullScreenImage:UIImage?
    /*! 赋值使用 不要取值！！！！！！*/
    var isSelecet = false
    
    
    func isNewImage()->Bool{
        if fullScreenImage != nil {
            return true
        }
        return false
    }
    /*! 外部取值使用 */
    func thumb_Image() -> UIImage?{
        if thumbImage != nil {
            return  thumbImage
        }
        return  UIImage(cgImage:aset!.thumbnail().takeUnretainedValue())
    }
    /*! 外部取值使用 */
    func aspectThumb_Image() -> UIImage?{
        if aspectThumbImage != nil {
            return  aspectThumbImage
        }
        return UIImage(cgImage:aset!.aspectRatioThumbnail().takeUnretainedValue())
    }
    /*! 外部取值使用 */
    func fullScreen_Image() -> UIImage?{
        if fullScreenImage != nil {
            return  fullScreenImage
        }
        return UIImage(cgImage:aset!.defaultRepresentation().fullScreenImage().takeUnretainedValue())
    }
    
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
