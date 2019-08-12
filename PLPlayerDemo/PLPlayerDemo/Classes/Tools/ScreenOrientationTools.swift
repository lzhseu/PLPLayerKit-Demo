//
//  ScreenOrientationTools.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/12.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit

class ScreenOrientationTools {
    // 强制旋转横屏
    class func forceOrientationLandscape(view: UIView) {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.isForceLandscape = true
        appdelegate.isForcePortrait = false
        appdelegate.isForceAllDerictions = false
        _ = appdelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: view.window)
        let oriention = UIInterfaceOrientation.landscapeRight // 设置屏幕为横屏
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    // 强制旋转竖屏
    class func forceOrientationPortrait(view: UIView) {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.isForceLandscape = false
        appdelegate.isForcePortrait = true
        appdelegate.isForceAllDerictions = false
        _ = appdelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: view.window)
        let oriention = UIInterfaceOrientation.portrait // 设置屏幕为竖屏
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

}
