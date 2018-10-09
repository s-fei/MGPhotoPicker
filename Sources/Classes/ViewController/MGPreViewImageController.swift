//
//  MGEditOrPreViewImageController.swift
//  MogoRenter
//
//  Created by song on 16/8/8.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//


/**
 预览页面 可以有编辑功能
 */


import UIKit
import MGProgressHUD


class MGPreViewImageController: BasePhotoViewController {
    fileprivate let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    fileprivate let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    
    let dismissAnimator = DismisssAnimator()
    
    @IBOutlet weak var topView: UIView!{
        didSet{
            topView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    @IBOutlet weak var closeBtn: UIButton!{
        didSet{
            closeBtn.addTarget(self, action: #selector(closeBtnAction(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var selectBtn: UIButton!
        {
        didSet{
        }
    }
    @IBOutlet weak var titlLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!{
        didSet{
            bottomView.layer.shadowOffset = CGSize(width: -5, height: 0);
            bottomView.layer.shadowOpacity = 0.3;
            bottomView.layer.shadowColor = UIColor.black.cgColor;
            bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    
    @IBOutlet weak var selectNumLabel: UILabel!{
        didSet{
            selectNumLabel.layer.cornerRadius = selectNumLabel.bounds.size.height/2
            selectNumLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var confirmBtn: UIButton!{
        didSet{
            confirmBtn.addTarget(self, action: #selector(confirmBtnAction(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.alwaysBounceHorizontal = true;
            collectionView.isPagingEnabled = true
            collectionView.register(UINib(nibName: "MGPreViewCell", bundle: ResourcesBundle)  , forCellWithReuseIdentifier: "MGPreViewCell")
        }
    }
    
    var imageViewFrame:CGRect?
    var currentIndex = 0
    var imageModelArray = [MGImageModel](){
        didSet{
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    var isFinishEdit = false
    var isCameraImage = false
    
    /*! 是否有编辑功能 如果有编辑功能，就没有取消和选中功能
     */
    var isEditImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlLabel.text = String(currentIndex+1) + "/" + String(imageModelArray.count)
        let model = imageModelArray[currentIndex]
        selectBtn.isSelected = model.isSelecet
        let selectArr = imageModelArray.filter { (model) -> Bool in
            return model.isSelecet
        }
        
        selectNumLabel.text = String(selectArr.count)
        
        if !isEditImage
        {
            selectBtn.addTarget(self, action: #selector(selectBtnAction(_:)), for: .touchUpInside)
        }
        else
        {
            selectBtn.setImage(nil, for: UIControl.State())
            selectBtn.setImage(nil, for: .selected)
            selectBtn.setTitle("编辑", for: UIControl.State())
            selectBtn.addTarget(self, action: #selector(editBtnAction(_:)), for: .touchUpInside)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.contentSize = CGSize(width: screenWidth * CGFloat(imageModelArray.count), height: screenHeight);
        collectionView.contentOffset = CGPoint(x: screenWidth*CGFloat(currentIndex), y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCameraImage {
            //            UIApplication.sharedApplication().statusBarHidden = statusBarHidden
            //            UIApplication.sharedApplication().statusBarStyle = statusBarStyle
        }
    }
    
    /**
     关闭按钮功能
     
     - parameter btn: <#btn description#>
     */
    @objc func closeBtnAction(_ btn:UIButton) {
        if isEditImage && isFinishEdit{
            let alertController = UIAlertController(title: "温馨提示",
                                                    message: "退出后将无法保存编辑后的图片。",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "确认", style: .default,
                                         handler: {
                                            [weak self] action in
                                            guard let strongSelf = self else { return }
                                            if let realCompletion = strongSelf.completionBlock {
                                                for model in strongSelf.imageModelArray{
                                                    model.fullScreenImage = nil
                                                    model.aspectThumbImage = nil
                                                    model.thumbImage = nil
                                                }
                                                realCompletion(nil , strongSelf)
                                            }
                                            
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.present(alertController, animated: true , completion: nil)
            }
            else if let popPresenter = alertController.popoverPresentationController{
                popPresenter.sourceView = self.view;
                popPresenter.sourceRect = self.view.bounds;
                self.present(alertController, animated: true , completion: nil)
            }
        }
        else
        {
            if let realComoletion = self.completionBlock
            {
                realComoletion(nil,self)
            }
        }
    }
    
    /*! 选择和取消 */
    @objc func selectBtnAction(_ btn:UIButton) {
        if isSelectMax(btn){
            MGProgressHUD.showTextAndHiddenView(view, message: "最多可选\(selectMaxNum)张")
        }
        else
        {
            let model = imageModelArray[currentIndex]
            selectBtn.isSelected = !selectBtn.isSelected
            model.isSelecet = selectBtn.isSelected
            
            let selectArr = imageModelArray.filter { (model) -> Bool in
                return model.isSelecet
            }
            
            selectNumLabel.text = String(selectArr.count)
        }
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0,0.1,0.2,0.4,0.6]
        scaleAnimation.values = [1,1.3,1.5,1.3,1]
        scaleAnimation.duration = 0.6
        selectNumLabel.layer.add(scaleAnimation, forKey: "")
    }
    
    /*! 判断是否已经到了最大选择张数 */
    func isSelectMax(_ btn:UIButton) -> Bool{
        let currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == selectMaxNum && selectMaxNum != 1 && !selectBtn.isSelected  {
            return true
        }
        
        if currentImageModels.count == selectMaxNum && selectMaxNum == 1 && !selectBtn.isSelected {
            let model = currentImageModels.first
            model?.isSelecet = false
        }
        
        return false
    }
    
    /*! 确认按钮 确认后直接回到项目页面中去 */
    @objc func confirmBtnAction(_ btn:UIButton) {
        var currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == 0 {
//            MGProgressHUD.showTextAndHiddenView(view, message: "请选择照片")
//            return
            let model = imageModelArray[currentIndex]
            model.isSelecet = true
            selectBtn.isSelected = true
            currentImageModels = [model]
        }
        if let realCompletion = completionBlock
        {
            realCompletion(currentImageModels,self)
        }
    }
    
    /*! 编辑功能  直接过渡到编辑页面 */
    @objc func editBtnAction(_ btn:UIButton) {
        let model = imageModelArray[currentIndex]
        let imageController = CLImageEditor(image:model.fullScreen_Image() , delegate: self)
        present(imageController!, animated: false, completion: nil)
    }
}

// MARK: - CLImageEditorDelegate
extension MGPreViewImageController:CLImageEditorDelegate{
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        if imageModelArray.count >  currentIndex {
            let model = imageModelArray[currentIndex]
            model.fullScreenImage = image
            //            if !isCameraImage {
            //                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            //            }
            collectionView.reloadItems(at: [IndexPath(row: currentIndex, section: 0)])
        }
        isFinishEdit = true
        editor.dismiss(animated: false, completion: nil)
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: false, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension MGPreViewImageController:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return imageModelArray.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MGPreViewCell", for: indexPath)
        if let preViewCell = cell as? MGPreViewCell
        {
            let model = imageModelArray[indexPath.row]
            preViewCell.zoomView.image =  model.fullScreen_Image()
            preViewCell.zoomView.show()
            preViewCell.zoomView.tapImageBlock = {
                [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.topView.alpha == 1 || strongSelf.topView.alpha == 0 {
                    UIView.animate(withDuration: 0.3, animations: {
                        strongSelf.topView.alpha =  strongSelf.topView.alpha == 1 ? 0:1
                        strongSelf.bottomView.alpha =  strongSelf.bottomView.alpha == 1 ? 0:1
                    })
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int((scrollView.contentOffset.x+CGFloat(0.1))/scrollView.bounds.width)
        titlLabel.text = String(currentIndex+1) + "/" + String(imageModelArray.count)
        let model = imageModelArray[currentIndex]
        selectBtn.isSelected = model.isSelecet
    }
}

