//
//  PLLiveViewController.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/8.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit
import SnapKit

class PLLiveViewController: UIViewController {
    
    // MARK: - 懒加载属性
    private lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text = "暂无直播列表，您可以点击左上角的按钮扫描二维码观看直播、或者点击右上角手动输入直播地址播放"
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

}

// MARK: - 设置UI
extension PLLiveViewController{
    private func setUI(){
        setNavigationBar()
        
        view.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalToSuperview().offset(-50)
        }
    }
    
    private func setNavigationBar(){
        
        navigationItem.title = "直播"
        
        let scanBtn = UIButton(type: .custom)
        scanBtn.setImage(UIImage(named: "scan"), for: .normal)
        scanBtn.sizeToFit()
        scanBtn.addTarget(self, action: #selector(scanBtnClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: scanBtn)
        
        let urlBtn = UIButton(type: .custom)
        urlBtn.setImage(UIImage(named: "url"), for: .normal)
        urlBtn.sizeToFit()
        urlBtn.addTarget(self, action: #selector(urlBtnClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: urlBtn)
    }
}


// MARK: - 事件监听函数
extension PLLiveViewController{
    
    @objc private func scanBtnClick(){
        print("scan click...")
    }
    
    @objc private func urlBtnClick(){
        print("url click...")
        let alert = UIAlertController(title: "输入URL播放", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "输入URL"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action) in
            let urlStr = alert.textFields?.first?.text
            // TODO: 判断是不是正确的URL格式
            //以下假设正确
            let playController = PLPlayerViewController()
            playController.playUrl = URL(string: urlStr!)
            self.present(playController, animated: true, completion: nil)
            //self.navigationController?.pushViewController(playController, animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(sureAction)
        self.present(alert, animated: true, completion: nil)
    }
}
