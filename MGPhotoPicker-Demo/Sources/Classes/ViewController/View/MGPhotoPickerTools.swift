//
//  UIViewComHelper.swift
//  MogoRenter
//
//  Created by Harly on 16/5/3.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

let KScreenWidth = UIScreen.main.bounds.width
let KScreenHeight = UIScreen.main.bounds.height

let kColors_LightBg = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1)
let kColors_LightGrayBg = UIColor(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1)
let kColors_LightLine = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1)
let kColors_Red = UIColor(red: 246.0 / 255.0, green: 80.0 / 255.0, blue: 0 / 255.0, alpha: 1)

let subheadFont = UIFont.systemFont(ofSize: 14)

let PathBundle = Bundle(for: MGImageModel.self).path(forResource: "Resources", ofType: "bundle")

let ResourcesBundle:Bundle? = (PathBundle != nil ? Bundle(path: PathBundle!) : nil)


