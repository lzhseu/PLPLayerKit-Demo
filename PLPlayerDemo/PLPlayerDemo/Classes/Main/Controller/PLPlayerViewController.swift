//
//  PLPlayerViewController.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/8.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit
import PLPlayerKit
import SnapKit
import JGProgressHUD

class PLPlayerViewController: UIViewController {

    // MARK: - 自定义属性
    var playUrl: URL? {
        didSet{
            if playUrl?.absoluteString != oldValue?.absoluteString{
                guard let player = player else { return }
                stop()
                setPlayer()
                player.play()
            }
        }
    }
    var player: PLPlayer?
    var isDisapper = false
    
    // MARK: - 懒加载属性
    private lazy var playBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.setImage(UIImage(named: "play"), for: .normal)
        btn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        btn.sizeToFit()
        return btn
    }()
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        btn.backgroundColor = UIColor(white: 0, alpha: 0.5)
        btn.layer.cornerRadius = 22
        btn.sizeToFit()
        return btn
    }()
    
    private lazy var singleTap: UITapGestureRecognizer = {
        let singleTab = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        return singleTab
    }()
    
    /// 此属性已经不用
    /*
    private lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Loading"
        hud.vibrancyEnabled = true
        return hud
    }()
    */
    
    private lazy var thumbImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "qn_niu"))
        imgView.clipsToBounds = true
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        return imgView
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        return effectView
    }()
    
    // MARK: - 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setPlayer()
    }
    
    //视图将要出现的时候调用
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    ///视图将要消失的时候
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    ///视图已经消失
    override func viewDidDisappear(_ animated: Bool) {
        isDisapper = true
        stop()
        super.viewDidDisappear(animated)
    }
    
    ///视图已经出现
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isDisapper = false
        guard let player = player else {
            return
        }
        if !player.isPlaying{
            player.play()
        }
    }
    
    
    ///修改状态栏风格 白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    ///状态栏是否隐藏
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    ///状态栏更改的动画类型
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - 设置UI
extension PLPlayerViewController{
    private func setUI(){
        /// 设置背景颜色
        view.backgroundColor = UIColor.white
        
        /// 加入单击屏幕手势
        view.addGestureRecognizer(singleTap)
       
        view.addSubview(playBtn)
        playBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }

        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview().offset(-10)
            make.height.width.equalTo(44)
        }

        view.addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        thumbImageView.addSubview(effectView)
        effectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


// MARK: - 设置player
extension PLPlayerViewController{
    private func setPlayer(){
        
        let option = PLPlayerOption.default()
        option.setOptionValue(15, forKey: PLPlayerOptionKeyTimeoutIntervalForMediaPackets)

        /* // 为什么加上其他的设置就会Crash???
        var format: PLPlayFormat = kPLPLAY_FORMAT_UnKnown
        if let urlStr = playUrl?.absoluteString.lowercased() {
            if urlStr.hasSuffix(".mp4") {
                format = kPLPLAY_FORMAT_MP4
            } else if urlStr.hasPrefix("rmtp:") {
                format = kPLPLAY_FORMAT_FLV
            } else if urlStr.hasSuffix(".m3u8") {
                format = kPLPLAY_FORMAT_M3U8
            } else if urlStr.hasSuffix(".mp3") {
                format = kPLPLAY_FORMAT_MP3
            }
            option.setOptionValue(format, forKey: PLPlayerOptionKeyVideoPreferFormat)
        }
        */
        
        /// 初始化 PLPlayer
        player = PLPlayer.init(url: playUrl, option: option)
        player?.delegate = self
        player?.isBackgroundPlayEnable = true  //进入后台是否继续播放
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)//不知道干嘛
        
        /// 获取视频输出视图并添加为到当前 UIView 对象的 Subview
        //view.addSubview((player?.playerView)!)
        view.insertSubview((player?.playerView)!, at: 0)
        player?.playerView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        /// 回调方法的调用队列
        player?.delegateQueue = DispatchQueue.main
        
        /// 设置内容缩放以适应固定方面。 余数是透明的（默认是填满整个画面）
        player?.playerView?.contentMode = UIView.ContentMode.scaleAspectFit
    }
}

// MARK: - player的代理方法
extension PLPlayerViewController: PLPlayerDelegate{
    
    /// 告知代理对象 PLPlayer 即将开始进入后台播放任务
    func playerWillBeginBackgroundTask(_ player: PLPlayer) {
        player.pause()
    }
    
    /// 告知代理对象 PLPlayer 即将结束后台播放状态任务
    func playerWillEndBackgroundTask(_ player: PLPlayer) {
        player.resume()
    }
    
    /// 播放状态回调
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        // TODO: 不同的播放状态下可以设置不同的UI等等
        if isDisapper{
            stop()
            hideWaiting()
            return
        }
        
        if state == PLPlayerStatus.statusPlaying ||
            state == PLPlayerStatus.statusPaused ||
            state == PLPlayerStatus.statusStopped ||
            state == PLPlayerStatus.statusError ||
            state == PLPlayerStatus.statusUnknow ||
            state == PLPlayerStatus.statusCompleted{
            
            hideWaiting()
            
        }else if state == PLPlayerStatus.statusPreparing ||
            state == PLPlayerStatus.statusReady ||
            state == PLPlayerStatus.statusCaching ||
            state == PLPlayerStatus.stateAutoReconnecting{
            
            showWaiting()
        }
    }
    
    /// 播放错误回调
    func player(_ player: PLPlayer, stoppedWithError error: Error?) {
        // TODO: 错误：尝试重连，失败需给出信息
        view.showFailTip(tip: "加载失败")
        hideWaiting()
    }
    
    /// 回调将要渲染的帧数据
    func player(_ player: PLPlayer, willRenderFrame frame: CVPixelBuffer?, pts: Int64, sarNumerator: Int32, sarDenominator: Int32) {
        DispatchQueue.main.async {
            if !UIApplication.shared.isIdleTimerDisabled{
                UIApplication.shared.isIdleTimerDisabled = true  //设置屏幕常亮
            }
        }
    }
    
    /// 回调音频数据
    func player(_ player: PLPlayer, willAudioRenderBuffer audioBufferList: UnsafeMutablePointer<AudioBufferList>, asbd audioStreamDescription: AudioStreamBasicDescription, pts: Int64, sampleFormat: PLPlayerAVSampleFormat) -> UnsafeMutablePointer<AudioBufferList> {
        return audioBufferList
    }
    
    /// 第一帧出现时
    func player(_ player: PLPlayer, firstRender firstRenderType: PLPlayerFirstRenderType) {
        thumbImageView.isHidden = true
    }
    
}


// MARK: - 事件监听函数
extension PLPlayerViewController{
    
    @objc private func playBtnClick(){
        guard let player = player else { return }
        player.resume()
    }
    
    @objc private func closeBtnClick(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func singleTapAction(){
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
        }else{
            player.resume()
        }
    }
}


// MARK: - 其它控制函数
extension PLPlayerViewController{
    private func stop(){
        UIApplication.shared.isIdleTimerDisabled = false  //屏幕不常亮
        player?.stop()
    }
    
    private func showWaiting(){
        playBtn.isHidden = true
        guard let view = player?.playerView else { return }
        //hud.show(in: view)
        view.showFullLoading()
        view.bringSubviewToFront(closeBtn)
    }
    
    private func hideWaiting(){
        //hud.dismiss()
        view.hideFullLoading()
        if player?.status != PLPlayerStatus.statusPlaying {
            playBtn.isHidden = false
            player?.playerView?.bringSubviewToFront(playBtn)
        }
    }
}

//rtmp://202.69.69.180:443/webcast/bshdlive-pc
