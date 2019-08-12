//
//  PLLongNavigationController.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/12.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit

class PLLongNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - 属性重写
    /// 此属性是为了能够在子控制器中拿到 statusBar 的使用权
    override var childForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
    
    /* //没用啊
    //是否支持屏幕翻转
    override var shouldAutorotate: Bool{
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    //支持屏幕旋转方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
    */
}
