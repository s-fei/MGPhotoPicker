//
//  MGPickerViewController.swift
//  MogoRenter
//
//  Created by song on 16/8/8.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

/**
 *
 * 这个是弹出框的RootViewController
 *
 */

import UIKit
import AssetsLibrary
import MGProgressHUD

class MGPickerViewController: BasePhotoViewController {
    
    /*! 进入预览的专场动画 */
    let presentAnimator = PresentAnimator()
    var contentView:UIView!
    var toolBarView:MGPhotoToolBarView!
    var pickerCollectionView:UICollectionView!
    var editBarView:UIView!
    var cameraVC = ZLCameraViewController(){
        didSet{
            cameraVC.maxCount = 1;
            cameraVC.cameraType = ZLCameraType.single;
        }
    }
    
    var customImageNum:Int  = 20 {
        didSet{
            if pickerCollectionView != nil {
                pickerCollectionView.reloadData()
            }
        }
    }
    let assetsLibrary = ALAssetsLibrary()
    /*! 相册组集合 */
    var groupModelArray = [ALAssetsGroup]()
    /*! 最近多少的集合 */
    var imageModelArray = [MGImageModel]()
    /*! 所有照片组中的照片 */
    var allImageModelArray = [MGImageModel]()
    var collectionViewHight:CGFloat = UIScreen.main.bounds.width/2 - 10
    deinit
    {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        contentView = UIView(frame: CGRect.zero)
        contentView.backgroundColor = kColors_LightBg
        view.addSubview(contentView)
        
        toolBarView = MGPhotoToolBarView(frame: CGRect.zero)
        toolBarView.backgroundColor = kColors_LightGrayBg.withAlphaComponent(0.7)
        contentView.addSubview(toolBarView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        pickerCollectionView = UICollectionView(frame: CGRect.zero,collectionViewLayout: layout)
        pickerCollectionView.delegate = self
        pickerCollectionView.dataSource = self
        pickerCollectionView.alwaysBounceHorizontal = true;
        pickerCollectionView.showsHorizontalScrollIndicator = false
        pickerCollectionView.register(MGImageCollectionCell.self, forCellWithReuseIdentifier: "MGImageCollectionCell")
        pickerCollectionView.backgroundColor = kColors_LightBg
        contentView.addSubview(pickerCollectionView)
        
        editBarView = UIView(frame: CGRect.zero)
        
        editBarView.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1)
        contentView.addSubview(editBarView)
        
        photoLibToImages()
        
    }
    
    func  photoLibToImages(){
        
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { [weak self](group, stop) in
            guard let strongSelf = self else { return }
            if group != nil
            {
                group?.setAssetsFilter(ALAssetsFilter.allPhotos())
                if let count = group?.numberOfAssets(), count > 0 {
                    strongSelf.groupModelArray.append(group!)
                    strongSelf.groupModelArray = strongSelf.groupModelArray.reversed()
                    if let name = group?.value(forProperty: ALAssetsGroupPropertyName) as? String {
                        if (name == "所有照片" || name == "相机胶卷" || name == "camera roll" || name == "Camera Roll")
                        {
                            strongSelf.imageModelFromGroup(group!)
                        }
                    }
                }
            }
            else
            {
                if  strongSelf.imageModelArray.count == 0 && strongSelf.groupModelArray.count > 0
                {
                    strongSelf.imageModelFromGroup(strongSelf.groupModelArray.first!)
                }
                else if strongSelf.imageModelArray.count == 0 && strongSelf.groupModelArray.count == 0
                {
                    MGProgressHUD.showView(strongSelf.pickerCollectionView,
                                           iconImage: nil,
                                           message: "暂无最近照片",
                                           detailText: nil)
                }
                
            }
        }) {[weak self] (error) in
            guard let strongSelf = self else { return }
            let progressHub = MGProgressHUD.showTextAndHiddenView(strongSelf.view, message: "读取相册出错,关闭请重试")
            progressHub?.locationMode = .bottom
        }
    }
    /**
     获得需要显示的组的多张照片
     
     - parameter group:这是一个图片组
     */
    func  imageModelFromGroup(_ group:ALAssetsGroup){
        var imagesArr = [MGImageModel]()
        group.enumerateAssets({ (aset, index, stop) in
            if aset != nil
            {
                let model = MGImageModel()
                model.aset = aset
                imagesArr.append(model)
            }
        })
        allImageModelArray = imagesArr.reversed()
        if allImageModelArray.count > customImageNum
        {
            imageModelArray = Array(allImageModelArray.prefix(customImageNum))
        }
        else
        {
            imageModelArray = allImageModelArray
        }
        MGProgressHUD.hiddenAllhubToView(contentView, animated: true)
        if imageModelArray.count == 0 {
            MGProgressHUD.showView(pickerCollectionView,
                                   iconImage: nil,
                                   message: "暂无最近照片",
                                   detailText: nil)
        }
        pickerCollectionView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = statusBarStyle
        UIApplication.shared.isStatusBarHidden = statusBarHidden
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        toolBarView.frame = CGRect(x: 0, y:0, width: view.bounds.width, height:40)
        pickerCollectionView.frame = CGRect(x: 0, y: toolBarView.frame.maxY+5, width: view.bounds.width, height: collectionViewHight)
        editBarView.frame = CGRect(x: 0, y: pickerCollectionView.frame.maxY, width: view.bounds.width, height: 3)
        contentView.frame = CGRect(x: 0, y: view.bounds.height - editBarView.frame.maxY, width: view.bounds.width, height: editBarView.frame.maxY)
    }
    
    /**
     修改确认按钮的显示
     */
    func changConfirmAcionText(){
        let currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        let btn = toolBarView.btnArr.last
        if currentImageModels.count > 0 {
            btn?.titleLabel?.text = "确认(\(currentImageModels.count))"
            btn?.setTitle("确认(\(currentImageModels.count))", for: UIControl.State())
        }
        else
        {
            btn?.titleLabel?.text = "确认"
            btn?.setTitle("确认", for: UIControl.State())
        }
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension MGPickerViewController:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        self.changConfirmAcionText()
        return imageModelArray.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MGImageCollectionCell", for: indexPath)
        if let imageCell = cell as? MGImageCollectionCell
        {
            let model = imageModelArray[indexPath.row]
            imageCell.currentModel = model
            if model.aset != nil {
                let image = model.aspectThumb_Image()
                imageCell.imageView.image = image
                imageCell.selectBtn.isSelected = model.isSelecet
                imageCell.tapSelectbtnBlock = {
                    [weak self] (btn:UIButton)in
                    guard let strongSelf = self else { return }
                    if strongSelf.isSelectMax(btn){
                        let progressHub = MGProgressHUD.showTextAndHiddenView(strongSelf.view, message: "最多可选\(strongSelf.selectMaxNum)张")
                        progressHub?.locationMode = .bottom
                    }
                    else
                    {
                        btn.isSelected = !btn.isSelected
                        model.isSelecet = btn.isSelected
                        strongSelf.changConfirmAcionText()
                    }
                }
            }
        }
        
        return cell
    }
    
    
    func isSelectMax(_ btn:UIButton) -> Bool{
        let currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == selectMaxNum && selectMaxNum != 1 && !btn.isSelected {
            return true
        }
        
        if currentImageModels.count == selectMaxNum && selectMaxNum == 1 && !btn.isSelected{
            let model = currentImageModels.first
            model?.isSelecet = false
            let index = imageModelArray.index(of: model!)
            
            if let cell = pickerCollectionView.cellForItem(at: IndexPath(row: index!, section: 0)) as?MGImageCollectionCell {
                cell.selectBtn.isSelected = false
            }
        }
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let model = imageModelArray[indexPath.row]
        let image:UIImage? = model.aset?.aspectThumb_Image()
        let imageSize = image?.size ?? CGSize(width: 50, height: 50)
        return CGSize(width: (collectionViewHight - 5)*imageSize.width/imageSize.height, height: (collectionViewHight - 5))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 2.5, left: 0, bottom: 2.5, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let  cell =  collectionView.cellForItem(at: indexPath) as? MGImageCollectionCell {
            let imageController = MGPreViewImageController(nibName: "MGPreViewImageController", bundle: ResourcesBundle)
            let imageViewFrame = cell.convert(cell.imageView.frame, to: nil)
            imageController.imageViewFrame = imageViewFrame
            imageController.currentIndex = indexPath.row
            imageController.imageModelArray = imageModelArray
            imageController.completionBlock = {
                [weak self] (imageModels,viewController) in
                guard let strongSelf = self else { return }
                strongSelf.pickerCollectionView.reloadData()
                //                let cell = imageController.collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: imageController.currentIndex, inSection: 0)) as! MGPreViewCell
                //                imageController.dismissAnimator.toView = cell.zoomView.imageView
                if let realCompletion = strongSelf.completionBlock, let count = imageModels?.count, count > 0 {
                    realCompletion(imageModels!,strongSelf)
                    return
                }
                viewController?.dismiss(animated: true, completion: nil)
            }
            imageController.transitioningDelegate = self
            presentAnimator.originView = cell.imageView
            //            imageController.dismissAnimator.fromView = cell.imageView
            //            dismissAnimator = imageController.dismissAnimator
            present(imageController, animated: true, completion: nil)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension MGPickerViewController:UIViewControllerTransitioningDelegate{
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil;
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
}


class MGImageCollectionCell: UICollectionViewCell {
    var imageView:UIImageView!
    var selectBtn:UIButton!
    var imageLayer:CALayer!
    
    var tapSelectbtnBlock : ((_ btn:UIButton) ->())!
    
    var selectBtnSpacing:CGFloat = 5.0 {
        didSet{
            layoutSubviews()
        }
    }
    
    var currentModel:MGImageModel!{
        didSet{
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame:CGRect.zero)
        //        imageView.layer.borderColor = UIColor(colorLiteralRed: 188.0/255, green: 188.0/255, blue: 188.0/255, alpha: 1).CGColor
        //        imageView.layer.borderWidth = 0.5
        contentView.addSubview(imageView)
        imageLayer = CALayer()
        imageLayer.frame = imageView.bounds
        imageLayer.backgroundColor = UIColor.black.withAlphaComponent(0.05).cgColor
        imageView.layer.addSublayer(imageLayer)
        
        selectBtn = UIButton(type: .custom)
        selectBtn.setImage(UIImage(named: "pic_unSelectedIcon", in: ResourcesBundle, compatibleWith: nil), for: UIControl.State())
        selectBtn.setImage(UIImage(named: "pic_selectedIcon", in: ResourcesBundle, compatibleWith: nil), for: .selected)
        selectBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 5)
        contentView.addSubview(selectBtn)
        selectBtn.addTarget(self, action: #selector(chooseBtn(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func chooseBtn(_ btn:UIButton){
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0,0.05,0.1,0.2,0.3]
        scaleAnimation.values = [1,1.1,1.2,1.1,1]
        scaleAnimation.duration = 0.3
        btn.layer.add(scaleAnimation, forKey: "")
        guard let realBlock = tapSelectbtnBlock else { return }
        realBlock(btn)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        imageLayer.frame = imageView.bounds
        selectBtn.frame = CGRect(x: contentView.frame.width - 40 - selectBtnSpacing, y: selectBtnSpacing, width: 40, height: 40)
    }
}

/*
 toolBarView顶部的按钮额
 */

class MGPhotoToolBarView:UIView{
    
    enum BarActionType:Int {
        case cancel = 0 //取消
        case preview = 1//预览
        case photo = 2//相册
        case camera = 3//拍照
        case edit  = 4//编辑
        case confirm = 5 // 确定
    }
    
    /*! 取消或确定的回调 */
    typealias typeBlock = (_ actionType:BarActionType) -> ()
    var selectBtnBlock:typeBlock!
    var btnArr = [UIButton]()
    
    fileprivate var topLineView:UIView!
    fileprivate var bottomLineView:UIView!
    
    //    private var btnTitleDict = [["key":"image","value":"cancel_icon","type":BarActionType.Cancel.rawValue],
    //                                ["key":"image","value":"preview_icon","type":BarActionType.Preview.rawValue],
    //                                ["key":"image","value":"photo_icon","type":BarActionType.Photo.rawValue],
    //                                ["key":"image","value":"camera_icon","type":BarActionType.Camera.rawValue],
    //                                ["key":"image","value":"edit_icon","type":BarActionType.Edit.rawValue],
    //                                ["key":"image","value":"confirm_icon","type":BarActionType.Confirm.rawValue]]
    
    fileprivate var btnTitleDict = [
        ["key":"image","value":"preview_icon","type":BarActionType.preview.rawValue],
        ["key":"image","value":"photo_icon","type":BarActionType.photo.rawValue],
        ["key":"image","value":"camera_icon","type":BarActionType.camera.rawValue],
        ["key":"image","value":"edit_icon","type":BarActionType.edit.rawValue],
        ["key":"text","value":"确定","type":BarActionType.confirm.rawValue]]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        topLineView = UIView(frame: CGRect.zero)
        topLineView.backgroundColor = kColors_LightLine
        addSubview(topLineView)
        
        bottomLineView = UIView(frame: CGRect.zero)
        bottomLineView.backgroundColor = kColors_LightLine
        addSubview(bottomLineView)
        
        btnArr.removeAll()
        for index in 1...btnTitleDict.count{
            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.clipsToBounds = true
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.showsTouchWhenHighlighted = true
            //            if index == 1 || index == btnTitleDict.count {
            //                btn.setTitleColor(UIColor(colorLiteralRed: 45.0/255, green: 45.0/255, blue: 45.0/255, alpha: 1), forState: .Normal)
            //            }
            //            else
            //            {
            //                btn.setTitleColor(UIColor(colorLiteralRed: 246.0/255, green: 80.0/255, blue: 0.0/255, alpha: 1), forState: .Normal)
            //            }
            btn.setTitleColor(UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255, alpha: 1), for: UIControl.State())
            
            let dict = btnTitleDict[index-1]
            if dict["key"] != nil {
                let string = dict["key"] as? String
                if string == "text" {
                    btn.setTitle(dict["value"] as? String, for: UIControl.State())
                    //                    btn.backgroundColor = kColors_LightBg
                    //                    btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    
                }
                else if string == "image"
                {
                    btn.setImage(UIImage(named:(dict["value"] as! String), in: ResourcesBundle, compatibleWith: nil), for: UIControl.State())
                }
            }
            addSubview(btn)
            btn.addTarget(self, action: #selector(selectBtn(_:)), for: .touchUpInside)
            btnArr.append(btn)
        }
    }
    
    @objc func selectBtn(_ btn:UIButton)  {
        if selectBtnBlock != nil && btnArr.contains(btn) {
            let index = btnArr.index(of: btn)
            let dict = btnTitleDict[index!]
            if let realBlock = self.selectBtnBlock , dict["type"] != nil {
                realBlock((BarActionType(rawValue: dict["type"] as! BarActionType.RawValue))!)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topLineView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        bottomLineView.frame = CGRect(x: 0, y:  bounds.height - 1, width: bounds.width, height: 0.5)
        
        for (index,btn) in btnArr.enumerated() {
            if index == 0  {
                btn.frame = CGRect(x:0, y: 0.5, width: 60, height: bounds.height-2)
            }
            else if index == btnArr.count - 1
            {
                let prevBtn = btnArr[0]
                let leftLine = UILabel(frame: CGRect(x:bounds.width - prevBtn.frame.width , y: prevBtn.frame.minY + 8 , width: 1, height: prevBtn.frame.height - 16))
                leftLine.text = ""
                leftLine.backgroundColor = kColors_LightLine
                addSubview(leftLine)
                btn.frame = CGRect(x:bounds.width - prevBtn.frame.width , y: prevBtn.frame.minY, width: prevBtn.frame.width, height: prevBtn.frame.height)
            }
            else
            {
                let prevBtn = btnArr[0]
                let width = (bounds.width - 2*prevBtn.frame.width)/CGFloat((btnArr.count - 2))
                btn.frame = CGRect(x:prevBtn.frame.maxX + width*CGFloat(index - 1), y: prevBtn.frame.minY, width: width , height: prevBtn.frame.height)
            }
        }
    }
}

