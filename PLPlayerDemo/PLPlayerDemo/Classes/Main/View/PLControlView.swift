//
//  PLControlView.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/13.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit
import SnapKit

private let kPlaySpeed = ["0.5", "0.75", "1.0", "1.25", "1.5","2.0"]
private let kPlayRatio = ["默认", "全屏", "16:9", "4:3"]
private let kBgViewW = 290
private let kBarViewH = 50
private let kButtonTitleFontSize: CGFloat = 14

enum PLPLayerRatio: Int {
    case PLPlayerRatioDefault = 0,
    PLPlayerRatioFullScreen,
    PLPlayerRatio16x9,
    PLPlayerRatio4x3
}

protocol PLControlViewDelegate: class {
    func controlViewClose(controlView: PLControlView)
    func controlView(controlView: PLControlView, speed: Double)
    func controlView(controlView: PLControlView, ratio: PLPLayerRatio)
    func controlView(controlView: PLControlView, isBackgroundPlay: Bool)
    func controlViewMirror(controlView: PLControlView)
    func controlViewRotate(controlView: PLControlView)
    func controlViewCache(controlView: PLControlView) -> Bool
}

class PLControlView: UIView {
    
    // MARK: - 自定义属性
    weak var delegate: PLControlViewDelegate?

    // MARK: - 懒加载属性
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return bgView
    }()
    
    private lazy var dissmissBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "player_close"), for: .normal)
        btn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "播放设置"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var barView: UIView = {
        let barView = UIView()
        barView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return barView
    }()
    
    private lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    private lazy var contentView: UIView = {
        return UIView()
    }()
    
    private lazy var speedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "播放速度:"
        label.textColor = UIColor(white: 0.8, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    private lazy var speedValueLabel: UILabel = {
        let label = UILabel()
        label.text = "1.0"
        label.textColor = UIColor(r: 0, g: 170, b: 255)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var speedControl: UISegmentedControl = {
        let ctrl = UISegmentedControl(items: kPlaySpeed)
        ctrl.addTarget(self, action: #selector(speedControlChange), for: .valueChanged)
        let dictSelected = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(r: 0, g: 170, b: 255)]
        let dictNormal = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.5)]
        ctrl.setTitleTextAttributes(dictNormal, for: .normal)
        ctrl.setTitleTextAttributes(dictSelected, for: .selected)
        ctrl.tintColor = UIColor.clear
        return ctrl
    }()
    
    private lazy var ratioTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "分辨率:"
        label.textColor = UIColor(white: 0.8, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    private lazy var ratioControl: UISegmentedControl = {
        let ctrl = UISegmentedControl(items: kPlayRatio)
        ctrl.addTarget(self, action: #selector(ratioControlChange), for: .valueChanged)
        let dictSelected = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(r: 0, g: 170, b: 255)]
        let dictNormal = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.5)]
        ctrl.setTitleTextAttributes(dictNormal, for: .normal)
        ctrl.setTitleTextAttributes(dictSelected, for: .selected)
        ctrl.tintColor = UIColor.clear
        return ctrl
    }()
    
    private lazy var playGroundBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "background_play"), for: .normal)
        btn.setTitle("后台播放", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: kButtonTitleFontSize)
        btn.addTarget(self, action: #selector(playGroundBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var mirrorBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mirror_swtich"), for: .normal)
        btn.setTitle("镜像反转", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: kButtonTitleFontSize)
        btn.addTarget(self, action: #selector(mirrorBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var rotateBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "rotate"), for: .normal)
        btn.setTitle("屏幕旋转", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: kButtonTitleFontSize)
        btn.addTarget(self, action: #selector(rotateBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cacheBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "save"), for: .normal)
        btn.setTitle("本地缓存", for: .normal)
        btn.setTitle("缓存已开", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: kButtonTitleFontSize)
        btn.addTarget(self, action: #selector(cacheBtnClick), for: .touchUpInside)
        return btn
    }()
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        resetStatus()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - UI
extension PLControlView{
    private func setUI(){
        
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.right.bottom.top.equalToSuperview()
            make.width.equalTo(kBgViewW)
        }
        
        addSubview(dissmissBtn)
        dissmissBtn.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(bgView.snp_left)
        }
        
        bgView.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kBarViewH)
        }
        
        bgView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(barView.snp_bottom)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        initBarView()
        initContentView()
    }
    
    private func initBarView(){
        barView.addSubview(titleLabel)
        barView.addSubview(closeBtn)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        closeBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(-5)
            make.width.equalTo(closeBtn.snp_height)
        }
    }
    
    private func initContentView(){
        contentView.addSubview(speedTitleLabel)
        contentView.addSubview(speedValueLabel)
        contentView.addSubview(speedControl)
        contentView.addSubview(ratioTitleLabel)
        contentView.addSubview(ratioControl)
        contentView.addSubview(playGroundBtn)
        contentView.addSubview(mirrorBtn)
        contentView.addSubview(rotateBtn)
        contentView.addSubview(cacheBtn)
        
        speedTitleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(20)
            make.width.equalTo(speedTitleLabel.bounds.size.width)
        }
        
        speedValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(speedTitleLabel.snp_right).offset(5)
            make.centerY.equalTo(speedTitleLabel)
        }
        
        speedControl.snp.makeConstraints { (make) in
            make.left.equalTo(speedTitleLabel)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(speedTitleLabel.snp_bottom).offset(10)
            make.height.equalTo(44)
        }
        
        ratioTitleLabel.snp.makeConstraints { (make) in
            make.height.left.right.equalTo(speedTitleLabel)
            make.top.equalTo(speedControl.snp_bottom).offset(10)
        }
        
        ratioControl.snp.makeConstraints { (make) in
            make.height.left.right.equalTo(speedControl)
            make.top.equalTo(ratioTitleLabel.snp_bottom).offset(10)
        }
        
        playGroundBtn.snp.makeConstraints { (make) in
            make.left.equalTo(speedControl)
            make.right.equalTo(contentView.snp_centerX)
            make.top.equalTo(ratioControl.snp_bottom).offset(20)
            make.height.equalTo(50)
        }
        
        mirrorBtn.snp.makeConstraints { (make) in
            make.left.equalTo(playGroundBtn.snp_right)
            make.size.centerY.equalTo(playGroundBtn)
        }
        
        rotateBtn.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(playGroundBtn)
            make.top.equalTo(playGroundBtn.snp_bottom).offset(20)
        }
        
        cacheBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(mirrorBtn);
            make.height.equalTo(mirrorBtn);
            make.centerY.equalTo(rotateBtn);
            make.bottom.equalToSuperview().offset(-20);
        }
    }
}


// MARK: - 事件监听函数
extension PLControlView{
    @objc private func closeBtnClick(){
        delegate?.controlViewClose(controlView: self)
    }
    
    @objc private func speedControlChange(){
        speedValueLabel.text = kPlaySpeed[speedControl.selectedSegmentIndex]
        let doubleV = Double(kPlaySpeed[speedControl.selectedSegmentIndex])
        //let cgFloatV = CGFloat(doubleV ?? 0)
        delegate?.controlView(controlView: self, speed: doubleV ?? 1)
    }
    
    @objc private func ratioControlChange(){
        delegate?.controlView(controlView: self, ratio: PLPLayerRatio(rawValue: ratioControl.selectedSegmentIndex)!)
    }
    
    @objc private func playGroundBtnClick(){
        
    }
    
    @objc private func mirrorBtnClick(){
        delegate?.controlViewMirror(controlView: self)
    }
    
    @objc private func rotateBtnClick(){
        delegate?.controlViewRotate(controlView: self)
    }
    
    @objc private func cacheBtnClick(){
        cacheBtn.isSelected = (delegate?.controlViewCache(controlView: self))!
    }
}


// MARK: - 其他控制函数
extension PLControlView{
    
    func resetStatus(){
        speedControl.selectedSegmentIndex = 2          //选择1倍速
        ratioControl.selectedSegmentIndex = 0          //选择默认宽高比（分辨率）
        playGroundBtn.isSelected = false
        cacheBtn.isSelected = false
        speedValueLabel.text = kPlaySpeed[speedControl.selectedSegmentIndex]
    }
}
