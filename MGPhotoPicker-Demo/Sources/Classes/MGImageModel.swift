//
//  MGImageModel.swift
//  MogoRenter
//
//  Created by song on 16/8/13.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

import UIKit
import AssetsLibrary

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
    public func thumb_Image() -> UIImage?{
        if thumbImage != nil {
            return  thumbImage
        }
        return  UIImage(cgImage:aset!.thumbnail().takeUnretainedValue())
    }
    /*! 外部取值使用 */
    public func aspectThumb_Image() -> UIImage?{
        if aspectThumbImage != nil {
            return  aspectThumbImage
        }
        return UIImage(cgImage:aset!.aspectRatioThumbnail().takeUnretainedValue())
    }
    /*! 外部取值使用 */
    public func fullScreen_Image() -> UIImage?{
        if fullScreenImage != nil {
            return  fullScreenImage
        }
        return UIImage(cgImage:aset!.defaultRepresentation().fullScreenImage().takeUnretainedValue())
    }
    
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
