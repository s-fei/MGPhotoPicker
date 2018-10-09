//
//  MGPhotoPicker.swift
//  MGPhotoPicker
//
//  Created by song on 16/8/4.
//  Copyright © 2016年 song. All rights reserved.
//

// MARK: 正餐在最下面啊

import UIKit
import AssetsLibrary
import MGProgressHUD

@objcMembers public class MGPhotoPicker: NSObject,CAAnimationDelegate {
    
    /*! window的RootViewController */
    var pickerVC:MGPickerViewController!
    
    /*! 最多选中多少个 */
    var selectMaxNum:Int = 1{
        didSet{
            if pickerVC != nil
            {
                pickerVC.selectMaxNum = selectMaxNum
            }
            
        }
    }
    /*! 是否有划线和添加文字功能 */
    var isEditDraw = true {
        didSet{
            CLImageEditorTheme.share().isEditDraw = isEditDraw
        }
    }
    /*! 确认或取消后的回调 */
    var completionBlock:((_ imageModels:[MGImageModel]?) ->())!
    
    /*! 弹出窗显示多少张最近的图片*/
    var customImageNum:Int  = 20{
        didSet{
            if pickerVC != nil
            {
                pickerVC.customImageNum = customImageNum
            }
            
        }
    }
    
    /*! 外部不要调用此方法额  调了也没有用 */
    fileprivate static let instancePicker = MGPhotoPicker()
    @objc fileprivate dynamic var pickerWindow:UIWindow!
    fileprivate var isHidden = false
    
    override init() {
        super.init()
    }
    
    fileprivate func createWindow(){
        
        pickerWindow = UIWindow(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        pickerWindow.windowLevel = UIWindow.Level(rawValue: 999) //UIWindowLevelAlert:2000  UIWindowLevelStatusBar:1000
        pickerWindow.backgroundColor = UIColor.clear
        pickerVC = MGPickerViewController()
        pickerVC.customImageNum = customImageNum
        pickerVC.completionBlock = {
            [weak self](imageModels,viewController)in
            guard let strongSelf = self else { return }
            if let count = imageModels?.count, count > 0 {
                strongSelf.tapInteriorConfirmAction(imageModels)
                //                return
            }
        }
        pickerWindow.rootViewController = pickerVC
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapWindowAction))
        tapGesture.delegate = self
        pickerVC.view.addGestureRecognizer(tapGesture)
        
        /*! 点击toolBar上的btn额 */
        pickerVC.toolBarView.selectBtnBlock = {
            [weak self] (actionType)in
            guard let strongSelf = self else { return }
            switch actionType {
            case .cancel:
                strongSelf.tapWindowAction()
                break
            case .preview:
                strongSelf.tapPreviewAction()
                break
            case .photo:
                strongSelf.tapPhotoAction()
                break
            case .camera:
                strongSelf.tapCameraAction()
                break
            case .edit:
                strongSelf.tapEditAction()
                break
            case .confirm:
                let currentImageModels = strongSelf.pickerVC.imageModelArray.filter { (model) -> Bool in
                    return  model.isSelecet
                }
                strongSelf.tapConfirmAction(currentImageModels)
                break
            }
        }
    }
    
    /**
     显示出来的动画，没有采用pop库
     */
    func show(){
        pickerWindow.isHidden = false
        let moveAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        let height = UIScreen.main.bounds.width/2 + 100
        moveAnimation.keyTimes = [0,0.15,0.3,0.45,0.55,0.65]
        moveAnimation.values = [height,height*2/3,height/3,0,8,0]
        moveAnimation.duration = 0.65
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = CAMediaTimingFillMode.forwards
        pickerVC.contentView.layer.add(moveAnimation, forKey: "")
        
        pickerVC.view.layer.opacity = 0
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.toValue = 1
        alphaAnimation.duration = 0.5
        alphaAnimation.isRemovedOnCompletion = false;
        alphaAnimation.fillMode = CAMediaTimingFillMode.forwards;
        pickerVC.view.layer.add(alphaAnimation, forKey: "")
        pickerVC.view.layer.opacity = 1
    }
    
    /*! 隐藏控件 主要处理一些动画 */
    func dismiss(){
        if !isHidden  && pickerVC != nil{
            isHidden = true
            pickerWindow.isUserInteractionEnabled = false
            let moveAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            let height = pickerVC.contentView.bounds.height
            moveAnimation.keyTimes = [0,0.5]
            moveAnimation.values = [0,height]
            moveAnimation.duration = 0.5
            moveAnimation.isRemovedOnCompletion = false
            moveAnimation.fillMode = CAMediaTimingFillMode.forwards
            moveAnimation.delegate = self
            pickerVC.contentView.layer.add(moveAnimation, forKey: "")
            
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.toValue = 0
            alphaAnimation.duration = 0.50
            alphaAnimation.delegate = self
            alphaAnimation.isRemovedOnCompletion = false;
            alphaAnimation.fillMode = CAMediaTimingFillMode.forwards;
            pickerVC.view.layer.add(alphaAnimation, forKey: "dismissAlpaAnimation")
            pickerVC.view.layer.opacity = 0
            
        }
    }
    
    /*! 隐藏全部屏幕 */
    func dissmissWithFullScreen(){
        if !isHidden  && pickerVC != nil{
            isHidden = true
            pickerWindow.isUserInteractionEnabled = false
            let moveAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            let height = pickerWindow.bounds.height
            moveAnimation.keyTimes = [0,0.4]
            moveAnimation.values = [0,height]
            moveAnimation.duration = 0.4
            moveAnimation.isRemovedOnCompletion = false
            moveAnimation.fillMode = CAMediaTimingFillMode.forwards
            moveAnimation.delegate = self
            pickerWindow.layer.add(moveAnimation, forKey: "")
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.toValue = 0
            alphaAnimation.duration = 0.50
            alphaAnimation.delegate = self
            alphaAnimation.isRemovedOnCompletion = false;
            alphaAnimation.fillMode = CAMediaTimingFillMode.forwards;
            pickerVC.view.layer.add(alphaAnimation, forKey: "dismissAlpaAnimation")
            pickerVC.view.layer.opacity = 0
        }
    }
    
    /*! 隐藏控件后移除 */
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        if pickerWindow != nil{
            isHidden = false
            pickerWindow.isHidden = true
            pickerWindow.removeFromSuperview()
            pickerWindow = nil
            pickerVC = nil
            completionBlock = nil
            selectMaxNum = 1
        }
    }
    
    
    /*! 点击空白处隐藏控件 */
    @objc func  tapWindowAction(){
        if let block = completionBlock
        {
            block(nil)
        }
        dismiss()
    }
    
    // MARK: - toolBar对应的功能
    /*! 预览 */
    func tapPreviewAction(){
        let currentImageModels = pickerVC.imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == 0 {
            let progressHub = MGProgressHUD.showTextAndHiddenView(pickerVC.view, message: "请选择照片")
            progressHub?.locationMode = .bottom
            return
        }
        let imageController = MGPreViewImageController(nibName: "MGPreViewImageController", bundle: ResourcesBundle)
        imageController.imageViewFrame = CGRect.zero
        imageController.currentIndex = 0
        imageController.imageModelArray = currentImageModels
        imageController.completionBlock = {
            [weak self](imageModels,viewController)in
            guard let strongSelf = self else { return }
            UIApplication.shared.statusBarStyle = strongSelf.pickerVC.statusBarStyle
            UIApplication.shared.isStatusBarHidden = strongSelf.pickerVC.statusBarHidden
            strongSelf.pickerVC.pickerCollectionView.reloadData()
            viewController?.dismiss(animated: true, completion: nil)
            if let count = imageModels?.count, count > 0 {
                strongSelf.tapInteriorConfirmAction(imageModels)
            }
        }
        pickerVC.present(imageController, animated: true, completion: nil)
        
    }
    
    /*! 相册 */
    func tapPhotoAction(){
        let  vc = MGAlbumViewController(nibName: "MGAlbumViewController", bundle: ResourcesBundle)
        vc.groupModelArray = pickerVC.groupModelArray
        let baseNav = UINavigationController(rootViewController: vc)
        vc.completionBlock = {
            [weak self](imageModels,viewController)in
            guard let strongSelf = self else { return }
            viewController?.navigationController!.dismiss(animated: true, completion: nil)
            if let count = imageModels?.count, count > 0 {
                strongSelf.tapInteriorConfirmAction(imageModels)
            }
        }
        pickerVC.present(baseNav, animated: true, completion: nil)
    }
    
    /*! 编辑 */
    func tapEditAction(){
        let currentImageModels = pickerVC.imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == 0 {
            let progressHub = MGProgressHUD.showTextAndHiddenView(pickerVC.view, message: "请选择照片")
            progressHub?.locationMode = .bottom
            return
        }
        let imageController = MGPreViewImageController(nibName: "MGPreViewImageController", bundle: ResourcesBundle)
        imageController.isEditImage = true
        imageController.imageViewFrame = CGRect.zero
        imageController.currentIndex = 0
        imageController.imageModelArray = currentImageModels
        imageController.completionBlock = {
            [weak self](imageModels,viewController)in
            guard let strongSelf = self else { return }
            strongSelf.pickerVC.pickerCollectionView.reloadData()
            viewController?.dismiss(animated: true, completion: nil)
            if let count = imageModels?.count, count > 0 {
                strongSelf.tapInteriorConfirmAction(imageModels)
            }
        }
        pickerVC.present(imageController, animated: true, completion: nil)
        
    }
    
    /*! 拍照 */
    func tapCameraAction(){
        pickerVC.cameraVC.callback = {
            [weak self] (cameras) in
            guard let strongSelf = self else { return }
            if let arr = cameras as? NSArray {
                //在这里得到拍照结果
                if(arr.count > 0)
                {
                    var models = [MGImageModel]()
                    arr.enumerateObjects({ (data, index, stop) in
                        if let camera = data as? ZLCamera{
                            let model = MGImageModel()
                            model.thumbImage = camera.thumbImage
                            model.fullScreenImage = camera.photoImage
                            model.isSelecet = true
                            models.append(model)
                        }
                    })
                    
                    if models.count == 0 {
                        MGProgressHUD.showTextAndHiddenView(strongSelf.pickerVC.cameraVC.view, message: "请重新拍照")
                        return
                    }
                    /*! 进入预览编辑页面 */
                    let imageController = MGPreViewImageController(nibName: "MGPreViewImageController", bundle: ResourcesBundle)
                    imageController.isCameraImage = true
                    imageController.isEditImage = true
                    imageController.imageViewFrame = CGRect.zero
                    imageController.currentIndex = 0
                    imageController.imageModelArray = models
                    imageController.completionBlock = {
                        [weak self](imageModels,viewController)in
                        guard let strongSelf = self else { return }
                        strongSelf.pickerVC.pickerCollectionView.reloadData()
                        viewController?.dismiss(animated: true, completion: nil)
                        if let count = imageModels?.count, count > 0 {
                            strongSelf.pickerVC.cameraVC.isReloadData = false
                            strongSelf.pickerVC.cameraVC.dismiss(animated: false, completion: nil)
                            strongSelf.tapInteriorConfirmAction(imageModels)
                        }
                    }
                    strongSelf.pickerVC.cameraVC.present(imageController, animated: false, completion: nil)
                }
                else
                {
                    strongSelf.pickerVC.cameraVC.dismiss(animated: true, completion: {
                        
                    })
                }
            }
            else
            {
                strongSelf.pickerVC.cameraVC.dismiss(animated: true, completion: {
                    
                })
            }
        }
        pickerVC.cameraVC.showPickerVc(pickerVC)
    }
    
    /*! 确认 */
    func tapConfirmAction(_ currentImageModels:[MGImageModel]?){
        if currentImageModels == nil || currentImageModels!.count == 0 {
            let progressHub = MGProgressHUD.showTextAndHiddenView(pickerVC.view, message: "请选择照片")
            progressHub?.locationMode = .bottom
            return
        }
        UIApplication.shared.statusBarStyle = pickerVC.statusBarStyle
        UIApplication.shared.isStatusBarHidden = pickerVC.statusBarHidden
        if let block = completionBlock  {
            for model in currentImageModels! {
                if model.isNewImage() {
                    UIImageWriteToSavedPhotosAlbum(model.fullScreen_Image()!, self, nil, nil);
                }
            }
            block(currentImageModels)
        }
        dismiss()
    }
    
    func tapInteriorConfirmAction(_ currentImageModels:[MGImageModel]?){
        if currentImageModels == nil || currentImageModels!.count == 0 {
            let progressHub = MGProgressHUD.showTextAndHiddenView(pickerVC.view, message: "请选择照片")
            progressHub?.locationMode = .bottom
            return
        }
        UIApplication.shared.statusBarStyle = pickerVC.statusBarStyle
        UIApplication.shared.isStatusBarHidden = pickerVC.statusBarHidden
        if let block = completionBlock  {
            for model in currentImageModels! {
                if model.isNewImage() {
                    UIImageWriteToSavedPhotosAlbum(model.fullScreen_Image()!, self, nil, nil);
                }
            }
            block(currentImageModels)
        }
        dissmissWithFullScreen()
    }
    
}
// MARK: - UIGestureRecognizerDelegate
extension MGPhotoPicker:UIGestureRecognizerDelegate{
    /*! 防止view影响点击事件 */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == pickerWindow.rootViewController?.view {
            return true
        }
        return false
    }
}

// MARK: - 自定义扩展
public extension MGPhotoPicker{
    
    
    // MARK: 正餐在这里啊
    /**
     重点来啦！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
     注意看参数！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
     外部调用 直接回调图片数组(MGImageModel) MGImageModel 一定要通过方法来取Image啊 不要取属性
     (因为image可能存在aset或者fullScreenImage)
     例如： let model = imageModels[0]   let image = model.fullScreen_Image()
     - parameter num:             最大选择多少张
     - parameter isEditDraw:      是否有划线和添加文字功能
     - parameter completionBlock: 回调张数
     
     - returns: MGPhotoPicker?
     */
    @discardableResult
    public class func showView(selectMaxNum num:Int,isEditDraw:Bool,completionBlock: @escaping (_ imageModels:[MGImageModel]?) ->()) -> MGPhotoPicker?{
        let author = ALAssetsLibrary.authorizationStatus()
        if author == .denied || author == .restricted {
            let alertController = UIAlertController(title: "通知",
                                                    message: "需要打开图片访问权限，才可以查看图片哟~",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "去设置", style: .default,
                                         handler: {
                                            action in
                                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            guard let vc =  UIApplication.shared.keyWindow?.rootViewController else { return nil}
            
            if(UIDevice.current.userInterfaceIdiom == .phone)
            {
                vc.present(alertController, animated: true, completion: nil)
            }
            else if let  popPresenter = alertController.popoverPresentationController
            {
                popPresenter.sourceView = vc.view
                popPresenter.sourceRect = vc.view.bounds
                vc.present(alertController, animated: true, completion: nil)
            }
            return nil
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let picker =  MGPhotoPicker.sharedInstance()
        picker.isEditDraw = isEditDraw
        if num > 1 {
            picker.selectMaxNum  = num
        }
        picker.completionBlock = completionBlock
        picker.show()
        return picker
    }
    
    public class func dismissView(){
        let picker = MGPhotoPicker.instancePicker
        if picker.pickerWindow != nil{
            picker.dismiss()
        }
    }
    
    
    /**
     外部调用初始MGPhotoPicker
     
     - returns: 返回对象
     */
    public class func sharedInstance()->MGPhotoPicker{
        let picker = MGPhotoPicker.instancePicker
        if picker.pickerWindow != nil && picker.pickerWindow.isHidden == false {
            return picker
        }
        picker.createWindow()
        return picker
    }
    
    /**
     外部调用
     - returns: 返回最大选择张数
     */
    public class func selectMaxNumMethod() -> Int{
        return  MGPhotoPicker.instancePicker.selectMaxNum
    }
}



