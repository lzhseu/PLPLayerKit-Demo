//
//  UIBarButtonItem-Extension.swift
//  LiveApp
//
//  Created by 卢卓桓 on 2019/7/21.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit

extension UIBarButtonItem{
    
    //便利构造函数  1.必须以convenience  2.在构造函数中必须明确地调用一个设计的构造函数
    convenience init(normalImage: String, highlightedImage: String = "", size: CGSize = CGSize.zero){
        
        let btn = UIButton()
        btn.setImage(UIImage(named: normalImage), for: .normal)
        
        if(highlightedImage != ""){
            btn.setImage(UIImage(named: highlightedImage), for: .highlighted)
        }
        
        if(size == CGSize.zero){
            btn.sizeToFit()
        }else{
            btn.frame = CGRect(origin: .zero, size: size)
        }
        
        self.init(customView: btn)
    }
}
