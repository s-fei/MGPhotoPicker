//
//  MGAlbumCell.swift
//  MogoRenter
//
//  Created by song on 16/8/9.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

import UIKit
import AssetsLibrary

class MGAlbumCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    
    var assetsGroup:ALAssetsGroup?{
        didSet{
            guard let `assetsGroup` = assetsGroup else { return }
            if assetsGroup.posterImage() != nil
            {
                iconImageView.backgroundColor = UIColor.clear
                iconImageView.image = assetsGroup.groupImage()
            }
            else
            {
                iconImageView.backgroundColor = UIColor.lightGray
                iconImageView.image = nil
            }
            
            if let name = assetsGroup.value(forProperty: ALAssetsGroupPropertyName) as? String{
                if (name == "相机胶卷" || name == "camera roll" || name == "Camera Roll")
                {
                    titleLabel.text = "相机胶卷"
                }
                else
                {
                    titleLabel.text = name
                }
                numLabel.text = String(assetsGroup.numberOfAssets()) + "张"
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
