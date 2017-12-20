//
//  MGGrounpPhotosViewController.swift
//  MogoRenter
//
//  Created by song on 16/8/9.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

/**
 一个相册组中的所有照片
 */

import UIKit
import AssetsLibrary
import MGProgressHUD

class MGGrounpPhotosViewController: BasePhotoViewController {
    
    let presentAnimator = PresentAnimator()
    
    @IBOutlet weak var bottomView: UIView!{
        didSet{
            bottomView.layer.shadowOffset = CGSize(width: -5, height: 0);
            bottomView.layer.shadowOpacity = 0.3;
            bottomView.layer.shadowColor = UIColor.black.cgColor;
            bottomView.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1)
        }
    }
    @IBOutlet weak var selectNumLabel: UILabel!{
        didSet{
            selectNumLabel.layer.cornerRadius = selectNumLabel.bounds.size.height/2
            selectNumLabel.layer.masksToBounds = true
        }
    }
    //    @IBOutlet weak var editBtn: UIButton!{
    //        didSet{
    //            editBtn.addTarget(self, action: #selector(editBtnAction(_:)), forControlEvents: .TouchUpInside)
    //        }
    //    }
    
    @IBOutlet weak var confirmBtn: UIButton!{
        didSet{
            confirmBtn.addTarget(self, action: #selector(confirmBtnAction(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.alwaysBounceVertical = true;
            collectionView.register(MGImageCollectionCell.self, forCellWithReuseIdentifier: "MGImageCollectionCell")
        }
    }
    var assetsGroup = ALAssetsGroup(){
        didSet{
            var imagesArr = [MGImageModel]()
            assetsGroup.enumerateAssets({ (aset, index, stop) in
                if aset != nil
                {
                    let model = MGImageModel()
                    model.aset = aset
                    imagesArr.append(model)
                }
            })
            imageModelArray = imagesArr.reversed()
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    var imageModelArray = [MGImageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editBtnAction))
        
        collectionView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }
    
    @objc func confirmBtnAction(_ btn:UIButton) {
        let currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == 0 {
            MGProgressHUD.showTextAndHiddenView(view, message: "请选择照片")
            return
        }
        if let realCompletion = completionBlock  {
            realCompletion(currentImageModels, self)
        }
    }
    
    func showSelectNumLabel(){
        let selectArr = imageModelArray.filter { (model) -> Bool in
            return model.isSelecet
        }
        selectNumLabel.text = String(selectArr.count)
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0,0.1,0.2,0.4,0.6]
        scaleAnimation.values = [1,1.3,1.5,1.3,1]
        scaleAnimation.duration = 0.6
        selectNumLabel.layer.add(scaleAnimation, forKey: "")
    }
    
    @objc func editBtnAction() {
        let currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == 0 {
            MGProgressHUD.showTextAndHiddenView(view, message: "请选择照片")
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
            strongSelf.collectionView.reloadData()
            imageController.dismiss(animated: true, completion: nil)
            if let realCompletion = strongSelf.completionBlock, let count = imageModels?.count, count > 0 {
                realCompletion(imageModels,strongSelf)
            }
        }
        present(imageController, animated: true, completion: nil)
    }
    
}

// MARK: - CLImageEditorDelegate
extension MGGrounpPhotosViewController:CLImageEditorDelegate{
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        editor.dismiss(animated: false, completion: nil)
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: false, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension MGGrounpPhotosViewController:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        self.showSelectNumLabel()
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
            imageCell.selectBtnSpacing = 0.0
            let model = imageModelArray[indexPath.row]
            imageCell.currentModel = model
            if model.aset != nil {
                let image = model.thumb_Image()
                imageCell.imageView.image = image
                imageCell.selectBtn.isSelected = model.isSelecet
                imageCell.tapSelectbtnBlock = {
                    [weak self] (btn:UIButton)in
                    guard let strongSelf = self else { return }
                    
                    if strongSelf.isSelectMax(btn){
                        MGProgressHUD.showTextAndHiddenView(strongSelf.view, message: "最多可选\(strongSelf.selectMaxNum)张")
                    }
                    else
                    {
                        btn.isSelected = !btn.isSelected
                        model.isSelecet =  btn.isSelected
                    }
                    strongSelf.showSelectNumLabel()
                }
            }
        }
        
        return cell
    }
    
    func isSelectMax(_ btn:UIButton) -> Bool{
        let currentImageModels = imageModelArray.filter { (model) -> Bool in
            return  model.isSelecet
        }
        if currentImageModels.count == selectMaxNum && selectMaxNum != 1  && !btn.isSelected {
            return true
        }
        
        if currentImageModels.count == selectMaxNum && selectMaxNum == 1  && !btn.isSelected {
            let model = currentImageModels.first
            model?.isSelecet = false
            let index = imageModelArray.index(of: model!)
            if let cell = collectionView.cellForItem(at: IndexPath(row: index!, section: 0)) as?MGImageCollectionCell {
                cell.selectBtn.isSelected = false
            }
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (KScreenWidth - 6)/4, height: (KScreenWidth - 6)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let  cell =  collectionView.cellForItem(at: indexPath) as? MGImageCollectionCell {
            let imageController = MGPreViewImageController(nibName: "MGPreViewImageController", bundle: ResourcesBundle)
            let imageViewFrame = self.view.convert(cell.imageView.frame, to: self.view)
            imageController.imageViewFrame = imageViewFrame
            imageController.currentIndex = indexPath.row
            imageController.imageModelArray = imageModelArray
            imageController.completionBlock = {
                [weak self](imageModels,viewController)in
                guard let strongSelf = self else { return }
                strongSelf.collectionView.reloadData()
                if let realCompletion = strongSelf.completionBlock, let count = imageModels?.count, count > 0 {
                    realCompletion(imageModels,strongSelf)
                    return
                }
                viewController?.dismiss(animated: true, completion: nil)
            }
            imageController.transitioningDelegate = self
            //            presentAnimator.originView = cell.imageView
            present(imageController, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate (先不加入)
extension MGGrounpPhotosViewController:UIViewControllerTransitioningDelegate{
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil//presentAnimator
    }
}



