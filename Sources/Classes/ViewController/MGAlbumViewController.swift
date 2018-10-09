//
//  MGAlbumViewController.swift
//  MogoRenter
//
//  Created by song on 16/8/9.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//
/**
 显示相册各组
 */


import UIKit
import  AssetsLibrary

class MGAlbumViewController: BasePhotoViewController {
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: CGFloat.leastNormalMagnitude))
            tableView.estimatedRowHeight = 500.0
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(UINib(nibName: "MGAlbumCell", bundle: ResourcesBundle), forCellReuseIdentifier: "MGAlbumCell")
        }
    }
    
    var groupModelArray = [ALAssetsGroup](){
        didSet{
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "相册"
        UINavigationBar.appearance().tintColor = kColors_Red
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelAction))
        tableView.reloadData()
        if groupModelArray.count > 0 {
            let  group = groupModelArray[0]
            let  vc = MGGrounpPhotosViewController(nibName: "MGGrounpPhotosViewController", bundle: ResourcesBundle)
            vc.assetsGroup = group
            if let name = group.value(forProperty: ALAssetsGroupPropertyName) as? String{
                if (name == "相机胶卷" || name == "camera roll" || name == "Camera Roll")
                {
                    vc.title = "相机胶卷"
                }
                else
                {
                    vc.title = name
                }
            }
            vc.completionBlock = {
                [weak self](imageModels,viewController)in
                guard let strongSelf = self else { return }
                
                guard let realCompletion = strongSelf.completionBlock else { return }
                realCompletion(imageModels , strongSelf)
            }
            navigationController?.pushViewController(vc, animated: false)
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func cancelAction(){
        guard let realCompletion = completionBlock else { return }
        realCompletion(nil , self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension MGAlbumViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MGAlbumCell", for: indexPath)
        if let albumCell = cell as? MGAlbumCell
        {
            let  group = groupModelArray[indexPath.row]
            albumCell.assetsGroup = group
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if let  cell =  tableView.cellForRow(at: indexPath) as? MGAlbumCell {
            let  group = groupModelArray[indexPath.row]
            let  vc = MGGrounpPhotosViewController(nibName: "MGGrounpPhotosViewController", bundle: ResourcesBundle)
            vc.assetsGroup = group
            vc.title = cell.titleLabel.text
            vc.completionBlock = {
                [weak self](imageModels,viewController)in
                guard let strongSelf = self else { return }
                guard let realCompletion = strongSelf.completionBlock else { return }
                realCompletion(imageModels , strongSelf)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

