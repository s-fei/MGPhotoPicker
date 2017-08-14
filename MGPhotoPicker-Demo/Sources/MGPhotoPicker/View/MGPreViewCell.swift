//
//  MGEditCell.swift
//  MogoRenter
//
//  Created by song on 16/8/8.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

import UIKit

class MGPreViewCell: UICollectionViewCell {

    var zoomView:MGZoomView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let frame = UIScreen.main.bounds
        zoomView = MGZoomView(frame: frame)
        contentView.addSubview(zoomView)
        zoomView?.originFrame = CGRect.zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        zoomView.frame = contentView.bounds
    }

}
