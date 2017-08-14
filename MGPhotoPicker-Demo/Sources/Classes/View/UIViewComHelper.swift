//
//  UIViewComHelper.swift
//  MogoRenter
//
//  Created by Harly on 16/5/3.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//
import SDWebImage

public class UIViewComHelper: NSObject
{
    public static func realFontSize (_ font:UIFont? , title:NSString? , maxSize:CGSize) -> CGSize
    {
        guard let `title` = title else { return CGSize.zero }
        var basicFont = UIFont.systemFont(ofSize: 14)
        
        if let realFont = font
        {
            basicFont = realFont
        }
        
        let attribute = [NSFontAttributeName:basicFont]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = title.boundingRect(with: maxSize, options: option , attributes: attribute, context: nil).size
        return size;
    }
    
    public static func realImageSize (_ image:UIImage?) -> CGSize
    {
        if image == nil
        {
            return CGSize()
        }
        
        let imgScale = image!.scale
        var finalSize = image!.size
        if imgScale != UIScreen.main.scale
        {
            let scare = imgScale/UIScreen.main.scale
            finalSize = CGSize(width: image!.size.width*scare, height: image!.size.height*scare)
        }
        return finalSize
    }
    
    public static func setShadowForView (_ view:UIView ,  needCornerRadius:Bool)
    {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize()
        view.layer.shadowOpacity = 0.2
//        view.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
        if needCornerRadius
        {
            view.layer.cornerRadius = 3
        }
        
    }
    
    public static func tipsScallingImage(_ url : String? , imageView : UIImageView , withSize: ((CGSize) -> Void)? = nil)
    {
        if let realUrl = url
        {
            tipsScallingImage(realUrl, placeHoldSting: nil, imageView: imageView , withSize: withSize)
        }
        
    }
    
    public static func tipsScallingImage(_ imageUrl : String? ,placeHoldSting:String?, imageView : UIImageView , withSize: ((CGSize) -> Void)? = nil)
    {
        guard let url = imageUrl else { return }
        
        var finalUrl = ""
        
        if url.contains(".png")
        {
            finalUrl = url
        }
        else
        {
            let scale = UIScreen.main.scale
            let scareStr = String(format: "%.0f", scale)
            let suffix = "\(scareStr).png"
            finalUrl = url + suffix
        }
        
        UIViewComHelper.setupWebImage(finalUrl, forImageView: imageView, withPlaceHoldImage: placeHoldSting, runningProgress: nil, tracingImageSize: withSize) { (image) in
            if finalUrl != url
            {
                let imageSize = UIViewComHelper.realImageSize(image)
                
                //高度作限制，如果超出高度则用原image高度以防超出
                let height = imageSize.height >= imageView.frame.size.height ? imageView.frame.size.height : imageSize.height
                //如果不是scale拼接的图，那就不用处理了
                imageView.frame = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y , width: imageSize.width , height: height)
                
                if let completion = withSize
                {
                    completion(imageSize)
                }
            }
        }
    }

    
    public static func clearImageCache()
    {
        SDWebImageManager.shared().cancelAll()
        SDWebImageManager.shared().imageCache?.clearDisk(onCompletion: nil)
        SDWebImageManager.shared().imageCache?.clearMemory()
    }
    
    public static func setupWebResizeImage(_ originalUrlString:String?,
                    forImageView imageView:UIImageView,
                    withPlaceHoldImage placeHolderImage:String?)
              
    {
        imageView.sd_cancelCurrentImageLoad()
        if let urlString = originalUrlString
        {
            
            let url = URL(string: urlString)
            
            if let placeHolderImageString = placeHolderImage {
                
                imageView.sd_setImage(with: url as URL!, placeholderImage: UIImage(named: placeHolderImageString), options: .cacheMemoryOnly, completed: { (image, error, type, url) in
                    guard error == nil else { return }
                    guard image != nil else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1
                        }, completion: {  _ in
                            imageView.image = image
                    })
                })            }
            else
            {
                imageView.sd_setImage(with: url as URL!, completed: { (image, error , type, url) in
                    guard error == nil else { return }
                    guard image != nil else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1
                        }, completion: {  _ in
                            imageView.image = image
                    })
                })
            }
            
            
        }
        
        
        
    }
    
    public static func setupWebImage(_ originalUrlString:String?,
                       forImageView imageView:UIImageView,
                                    withPlaceHoldImage placeHolderImage:String?,
                           runningProgress:((Int,Int)->())?,
                           tracingImageSize:((CGSize)->())?)
    {
        imageView.sd_cancelCurrentImageLoad()
        if let urlString = originalUrlString
        {

            let url = URL(string: urlString)
            if let placeHolderImageString = placeHolderImage {
                imageView.sd_setImage(with: url as URL!, placeholderImage: UIImage(named: placeHolderImageString), options: .cacheMemoryOnly, completed: { (image, error, type, url) in
                    guard error == nil else { return }
                    guard let realImage = image else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    
                    if let sizeClosure = tracingImageSize
                    {
                        sizeClosure(realImage.size)
                    }
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                         imageView.alpha = 1
                        }, completion: {  _ in
                            imageView.image = realImage
                    })
                })
            }
            else
            {
                imageView.sd_setImage(with: url as URL!, completed: { (image, error , type, url) in
                    guard error == nil else { return }
                    guard let realImage = image else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    
                    
                    if let sizeClosure = tracingImageSize
                    {
                        sizeClosure(realImage.size)
                    }
                    
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1
                        }, completion: {  _ in
                            imageView.image = realImage
                    })
                })
            }
            
        }
    }
    
    
    public static func setupWebImage(_ originalUrlString:String?,
                         forImageView imageView:UIImageView,
            withPlaceHoldImage placeHolderImage:String?,
                                runningProgress:((Int,Int)->())?,
                               tracingImageSize:((CGSize)->())?,
                               completedImage:((UIImage)->())?)
    {
        imageView.sd_cancelCurrentImageLoad()
        if let urlString = originalUrlString
        {
            let url = URL(string: urlString)
            
            if let placeHolderImageString  = placeHolderImage  {
                imageView.sd_setImage(with: url as URL!, placeholderImage: UIImage(named: placeHolderImageString), options: .cacheMemoryOnly, completed: { (image, error, type, url) in
                    guard error == nil else { return }
                    guard let realImage = image else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    
                    if let completedImageBlock = completedImage
                    {
                        completedImageBlock(realImage)
                    }
                    if let sizeClosure = tracingImageSize
                    {
                        sizeClosure(realImage.size)
                    }
                    
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1
                        }, completion: {  _ in
                            imageView.image = realImage
                    })
                    
                })
            }
            else
            {
                imageView.sd_setImage(with: url as URL!, completed: { (image, error , type, _) in
                    guard error == nil else { return }
                    guard let realImage = image else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    
                    if let completedImageBlock = completedImage
                    {
                        completedImageBlock(realImage)
                    }
                    if let sizeClosure = tracingImageSize
                    {
                        sizeClosure(realImage.size)
                    }
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1
                        }, completion: {  _ in
                            imageView.image = realImage
                    })
                    
                })
            }
        }
    }
    
    
}
