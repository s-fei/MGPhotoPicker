//
//  MGImageModel.swift
//  MogoRenter
//
//  Created by song on 16/8/13.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

import UIKit
import AssetsLibrary

extension ALAssetsGroup {
    
    /*! 组相册图片 */
    func groupImage() -> UIImage? {
        guard let posterImage = self.posterImage() else { return nil}
        let takeValue:CGImage = posterImage.takeUnretainedValue()
        return  UIImage(cgImage:takeValue)
    }
}


extension ALAsset {
    
    /*! 原始照片的缩略图 模糊 */
    func thumb_Image() -> UIImage? {
        guard let thumbnail = self.thumbnail() else { return nil}
        let takeValue:CGImage = thumbnail.takeUnretainedValue()
        return  UIImage(cgImage:takeValue)
    }
    /*! 取缩略图 */
    func aspectThumb_Image() -> UIImage? {
        guard let thumbnail = self.aspectRatioThumbnail() else { return nil}
        let takeValue:CGImage = thumbnail.takeUnretainedValue()
        return UIImage(cgImage:takeValue)
    }
    /*! 取大图 */
    func fullScreen_Image() -> UIImage? {
        guard let defaultRepresent = self.defaultRepresentation() else { return nil }
        guard let fullScreenImage = defaultRepresent.fullScreenImage() else { return nil }
        let takeValue:CGImage = fullScreenImage.takeUnretainedValue()
        return UIImage(cgImage:takeValue)
    }
}

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
        return  aset?.thumb_Image()
    }
    /*! 外部取值使用 */
    func aspectThumb_Image() -> UIImage?{
        if aspectThumbImage != nil {
            return  aspectThumbImage
        }
        return aset?.aspectThumb_Image()
    }
    /*! 外部取值使用 */
    func fullScreen_Image() -> UIImage?{
        if fullScreenImage != nil {
            return  fullScreenImage
        }
        return aset?.fullScreen_Image()
    }
    
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
