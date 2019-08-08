//
//  UIView-Extension.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/8.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit
import JGProgressHUD
import SnapKit
import MMMaterialDesignSpinner

private let loadingTag = 99999
private let fullLoadingTag = 88888
private let errorViewTag = 77777
private let tipTag = 66666

extension UIView{
    
    func protoTypeHUD() -> JGProgressHUD {
        /// 先判断之前有没有旧的HUD，有则消除
        let oldHud: JGProgressHUD? = self.viewWithTag(tipTag) as? JGProgressHUD
        if oldHud != nil{
            oldHud!.dismiss(animated: false)
        }
        
        let HUD = JGProgressHUD(style: .dark)
        HUD.interactionType = .blockAllTouches  //HUD及所在的View都不能交互
        let an = JGProgressHUDFadeZoomAnimation()
        HUD.animation = an
        HUD.square = false
        HUD.tag = tipTag
        HUD.delegate = self
        return HUD
    }
    
    func loadingHUD() -> JGProgressHUD{
        let oldHud: JGProgressHUD? = self.viewWithTag(tipTag) as? JGProgressHUD
        if oldHud != nil{
            oldHud!.dismiss(animated: false)
        }
        
        let HUD = protoTypeHUD()
        HUD.tag = loadingTag
        return HUD
    }
    
    /// 加载图片
    func showImageLoadingWithTip(tip: String, imageName: String?){
        let HUD = loadingHUD()
        HUD.textLabel.text = tip
        HUD.textLabel.font = UIFont.systemFont(ofSize: 14)
        HUD.show(in: self)
    }
    
    /// 加载{默认加载}
    func showNormalLoadingWithTip(tip: String){
        showImageLoadingWithTip(tip: tip, imageName: nil)
    }
    
    /// 加载{默认加载，无文字}
    func showLoadingHUD(){
        showNormalLoadingWithTip(tip: "")
    }
    
    /// 加载成功
    func showSuccessTip(tip: String){
        let hud = loadingHUD()
        hud.textLabel.text = tip
        hud.textLabel.font = UIFont.systemFont(ofSize: 14)
        hud.detailTextLabel.text = nil
        hud.layoutChangeAnimationDuration = 0.2
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self)
        hud.dismiss(afterDelay: 2)
    }
    
    /// 加载失败
    func showFailTip(tip: String){
        let hud = loadingHUD()
        hud.textLabel.text = tip
        hud.textLabel.font = UIFont.systemFont(ofSize: 14)
        hud.detailTextLabel.text = nil
        hud.layoutChangeAnimationDuration = 0.2
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self)
        hud.dismiss(afterDelay: 2)
    }
    
    /// 隐藏加载
    func hideLoading(){
        guard let hud = viewWithTag(loadingTag) as? JGProgressHUD else { return }
        hud.dismiss()
    }
    
    
    
    /// 提示 （文字+副标题+图片）
    func showImageTip(tip: String?, message: String?, imageName: String?){
        let imgView = UIImageView(image: UIImage(named: imageName ?? ""))
        imgView.contentMode = UIView.ContentMode.scaleAspectFit
        imgView.backgroundColor = UIColor.red
        let hud = protoTypeHUD()
        hud.indicatorView = JGProgressHUDIndicatorView(contentView: imgView)
        hud.textLabel.text = tip
        hud.detailTextLabel.text = message
        hud.textLabel.font = UIFont.systemFont(ofSize: 14)
        hud.show(in: self)
        hud.dismiss(afterDelay: 2)
    }
    
    /// 提示 （文字+图片）
    func showImageTip(tip: String?, imageName: String?){
        showImageTip(tip: tip, message: nil, imageName: imageName)
    }
    
    /// 警告 （标题+副标题+默认图片）
    func showWarningTip(tip: String?, message: String?){
        showImageTip(tip: tip, message: message, imageName: "failure")
    }
    
    /// 警告（标题+默认图片）
    func showWarningTip(tip: String?){
        showWarningTip(tip: tip, message: nil)
    }
    
    /// 提示（文字+位置）
    func showTip(tip: String, position: JGProgressHUDPosition){
        let hud = protoTypeHUD()
        hud.position = position
        hud.indicatorView = nil
        hud.textLabel.text = tip
        hud.textLabel.font = UIFont.systemFont(ofSize: 14)
        hud.show(in: self)
        hud.dismiss(afterDelay: 2)
    }
    
    /// 提示（只文字）
    func showTip(tip: String){
        showTip(tip: tip, position: .center)
    }
    
    
    
    func showFullLoadingWithTip(tip: String){
        var loadingView = viewWithTag(fullLoadingTag)
        if loadingView != nil{
            return
        }
        loadingView = UIView(frame: bounds)
        loadingView!.tag = fullLoadingTag
        addSubview(loadingView!)
        loadingView!.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let spinner = MMMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinner.lineWidth = 2.5
        spinner.center = loadingView!.center
        spinner.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        spinner.tintColor = UIColor(r: 0, g: 136, b: 187)
        loadingView!.addSubview(spinner)
        bringSubviewToFront(loadingView!)
        spinner.startAnimating()
        
        if tip.count > 0 {
            let loadLabel = UILabel(frame: CGRect(x: 0, y: 80, width: 150, height: 20))
            loadLabel.text = tip
            loadLabel.textColor = UIColor(r: 0, g: 136, b: 187)
            loadLabel.font = UIFont.systemFont(ofSize: 12)
            loadLabel.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            loadingView?.addSubview(loadLabel)
            loadLabel.snp.makeConstraints { (make) in
                make.top.equalTo(spinner.snp.bottom).offset(5)
                make.centerX.equalTo(spinner)
                make.height.equalTo(20)
            }
        }
    }
    
    func showFullLoading(){
        showFullLoadingWithTip(tip: "Loading")
    }
    
    func hideFullLoading(){
        var loadingView = viewWithTag(fullLoadingTag)
        if loadingView != nil{
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                loadingView?.removeFromSuperview()
            }) { (finished) in
                loadingView = nil
            }
        }
    }
}

// MARK: - JGProgressHUD 代理方法
extension UIView: JGProgressHUDDelegate{
    
}
