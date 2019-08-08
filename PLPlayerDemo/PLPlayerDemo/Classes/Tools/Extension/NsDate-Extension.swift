//
//  NsDate-Extension.swift
//  LiveApp
//
//  Created by 卢卓桓 on 2019/7/31.
//  Copyright © 2019 zhineng. All rights reserved.
//

import Foundation

extension NSDate {
    class func getCurrentTime() -> String {
        let nowDate = NSDate()
        let interval = nowDate.timeIntervalSince1970
        //print("\(interval)")
        return "\(interval)"
    }
}
