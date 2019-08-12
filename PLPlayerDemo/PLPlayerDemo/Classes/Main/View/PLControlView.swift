//
//  PLControlView.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/9.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit

class PLControlView: UIView {
    weak var delegate: PLControlViewDelegate?

}

extension PLControlView{
    func resetStatus(){}
}

protocol PLControlViewDelegate: class{
    
}
