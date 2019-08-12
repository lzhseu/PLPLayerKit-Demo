//
//  PLPlayerView.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/12.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit
import PLPlayerKit
import SnapKit

private let kEdgesSpace = 5
private let kEdgesSpaceForX = 20
private let kTopBarH = 44
private let kBottomBarH = 44
private let kCenterBtnWH = 64
private let kSnapShotBtnWH = 60
private let kBottomProgressH = 3
private let kControlViewLeftOffSetPlayerView = 290

protocol PLPlayerViewDelegate: class {
    func playerViewEnterFullScreen(playerView: PLPlayerView)
    func playerViewExitFullScreen(playerView: PLPlayerView)
    func playerViewWillPlay(playerView: PLPlayerView)
}

class PLPlayerView: UIView {

    // MARK: - 自定义属性
    weak var delegate: PLPlayerViewDelegate?
    private var player: PLPlayer?
    private var isNeedSetPlayer = true
    private var isStop = true
    private var deviceOrientation = UIDeviceOrientation.unknown
    private var playTimer: Timer?
    var playUrl: URL?

    // MARK: - 懒加载属性
    /// 顶部的控制栏
    private lazy var topBarView: UIView = {
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return topBarView
    }()

    /// 视频标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "视频标题"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }()

    /// 更多按钮
    private lazy var moreBtn: UIButton = { [weak self] in
        let btn = UIButton()
        btn.setImage(UIImage(named: "more"), for: .normal)
        btn.addTarget(self!, action: #selector(moreBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 退出全屏按钮
    private lazy var exitFullScreenBtn: UIButton = { [weak self] in
        let btn = UIButton()
        btn.setImage(UIImage(named: "player_back"), for: .normal)
        btn.addTarget(self!, action: #selector(exitFullScreenBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 屏幕中间的播放按钮
    private lazy var centerPlayButton: UIButton = { [weak self] in
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "player_play"), for: .normal)
        btn.addTarget(self!, action: #selector(playBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 屏幕中间的暂停按钮
    private lazy var centerPauseButton: UIButton = { [weak self] in
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "player_stop"), for: .normal)
        btn.addTarget(self!, action: #selector(pauseBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 全屏时底部的播放按钮
    private lazy var playBtn: UIButton = { [weak self] in
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "player_play"), for: .normal)
        btn.addTarget(self!, action: #selector(playBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 全屏时底部的暂停按钮
    private lazy var pauseBtn: UIButton = { [weak self] in
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "player_stop"), for: .normal)
        btn.addTarget(self!, action: #selector(pauseBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 底部的控制栏
    private lazy var bottomBarView: UIView = {
        let bottomBarView = UIView()
        bottomBarView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return bottomBarView
    }()

    /// 进度滑条
    private lazy var slider: UISlider = { [weak self] in
        let slider = UISlider()
        slider.isContinuous = false
        slider.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = sliderColor
        slider.addTarget(self!, action: #selector(sliderValueChange), for: .valueChanged)
        return slider
        }()

    /// 播放时间显示
    private lazy var playTimeLabel: UILabel = {
        let label = UILabel()
        label.frame.size = CGSize(width: 55, height: 15)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.text = "00:00:00"
        label.textAlignment = NSTextAlignment.center
        //label.sizeToFit()
        return label
    }()

    /// 视频时长显示
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.frame.size = CGSize(width: 55, height: 15)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.text = "00:00:00"
        label.textAlignment = NSTextAlignment.center
        //label.sizeToFit()
        return label
    }()

    /// 播放进度显示
    private lazy var bufferingView: UIProgressView = {
        let bufferingView = UIProgressView()
        bufferingView.progressTintColor = UIColor(white: 1, alpha: 1)
        bufferingView.trackTintColor = UIColor(white: 1, alpha: 0.33)
        return bufferingView
    }()

    /// 全屏按钮
    private lazy var enterFullScreenButton: UIButton = { [weak self] in
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "full-screen"), for: .normal)
        btn.addTarget(self!, action: #selector(enterFullScreenBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 截屏按钮
    private lazy var snapshotButton: UIButton = { [weak self] in
        let btn = UIButton()
        btn.setImage(UIImage(named: "screen-cut"), for: .normal)
        btn.addTarget(self!, action: #selector(snapShotBtnClick), for: .touchUpInside)
        return btn
        }()

    /// 当bottomBar隐藏时，屏幕底部的进度条
    private lazy var bottomPlayProgressView: UIProgressView = {
        let bottomPlayProgressView = UIProgressView()
        bottomPlayProgressView.progressTintColor = sliderColor
        bottomPlayProgressView.trackTintColor = UIColor.clear
        return bottomPlayProgressView
    }()

    /// 当bottomBar隐藏时，屏幕底部的缓冲条
    private lazy var bottomBufferingProgressView: UIProgressView = {
        let bottomBufferingProgressView = UIProgressView()
        bottomBufferingProgressView.progressTintColor = UIColor(white: 1, alpha: 1)
        bottomBufferingProgressView.trackTintColor = UIColor(white: 1, alpha: 0.33)
        return bottomBufferingProgressView
    }()

    /// 播放前的占位图
    private lazy var placeholderImageView: UIImageView = {
        let placeholderImageView = UIImageView(image: UIImage(named: "loading_bgView"))
        placeholderImageView.contentMode = ContentMode.scaleAspectFill
        self.clipsToBounds = true
        return placeholderImageView
    }()

    /// 单击屏幕手势
    private lazy var singleTap: UITapGestureRecognizer = {
        let singleTab = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        return singleTab
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        playUrl = URL(string: "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTimer(){
        removeTimer()
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    private func removeTimer(){
        playTimer?.invalidate()
        playTimer = nil
    }

    @objc private func timerAction(){
        guard let player = player else { return }
        slider.value = Float(CMTimeGetSeconds(player.currentTime))
        //print("---------------------------------------------")
        //print(slider.value)
        if CMTimeGetSeconds(player.totalDuration) > 0{
            let duration = Int(slider.value + 0.5)
            let hour: Int = duration / 3600
            let min: Int = (duration % 3600) / 60
            let sec: Int = duration % 60
            playTimeLabel.text = String(format: "%02d:%02d:%02d", arguments: [hour, min, sec])
            bottomPlayProgressView.progress = slider.value / Float(CMTimeGetSeconds(player.totalDuration))
        }
    }
}


// MARK: - UI
extension PLPlayerView{
    
    private func setUI(){
        backgroundColor = UIColor.black
        
        initTopBar()
        initBottomBar()
        initOtherUI()
        makeStableConstraints()
        transformWithOrientation(orientation: .portrait)
        
        addGestureRecognizer(singleTap)
    }
    
    private func initTopBar(){
        topBarView.addSubview(titleLabel)
        topBarView.addSubview(exitFullScreenBtn)
        topBarView.addSubview(moreBtn)
        addSubview(topBarView)
    }
    
    private func initBottomBar(){
        addSubview(bottomBarView)
        bottomBarView.addSubview(playBtn)
        bottomBarView.addSubview(pauseBtn)
        bottomBarView.addSubview(playTimeLabel)
        bottomBarView.addSubview(durationLabel)
        bottomBarView.addSubview(bufferingView)
        bottomBarView.addSubview(slider)
        bottomBarView.addSubview(enterFullScreenButton)
    }
    
    private func initOtherUI(){
        addSubview(centerPlayButton)
        addSubview(centerPauseButton)
        addSubview(snapshotButton)
        addSubview(bottomBufferingProgressView)
        addSubview(bottomPlayProgressView)
        //addSubview(placeholderImageView)
        insertSubview(placeholderImageView, at: 0)
        
        pauseBtn.isHidden = true
        centerPauseButton.isHidden = true
        hideBottomProgressView()
    }
    
    /// 对控件做约束，使这些控件的 Constraints 不会随着全屏和非全屏而改变
    private func makeStableConstraints(){
        
        topBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp_top)
            make.height.equalTo(kTopBarH)
        }
        
        exitFullScreenBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(topBarView.snp_left).offset(kEdgesSpace)
            make.width.equalTo(exitFullScreenBtn.snp_height)
        }
        
        moreBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-kEdgesSpace)
            make.width.equalTo(exitFullScreenBtn.snp_height)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(exitFullScreenBtn.snp_right)
            make.right.equalTo(moreBtn.snp_left)
            make.centerY.equalToSuperview()
        }
        
        bottomBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp_bottom)
            make.height.equalTo(kBottomBarH)
        }
        
        slider.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(playTimeLabel.snp_right).offset(kEdgesSpace)
            make.right.equalTo(durationLabel.snp_left).offset(-kEdgesSpace)
        }
        
        playTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(playBtn.snp_right)
            make.width.equalTo(playTimeLabel.bounds.size.width)
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(enterFullScreenButton.snp_left)
            make.size.equalTo(durationLabel.bounds.size)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(kEdgesSpace)
            make.width.equalTo(playBtn.snp_height)
        }
        
        pauseBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(playBtn)
        }
        
        enterFullScreenButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(enterFullScreenButton.snp_height)
        }
        
        centerPlayButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(kCenterBtnWH)
        }
        
        centerPauseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(centerPlayButton)
        }
        
        bufferingView.snp.makeConstraints { (make) in
            make.left.right.equalTo(slider)
            make.centerY.equalTo(slider).offset(0.5)
        }
        
        snapshotButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-kEdgesSpace)
            make.width.height.equalTo(kSnapShotBtnWH)
        }
        
        bottomBufferingProgressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.1)
            make.height.equalTo(kBottomProgressH)
        }
        
        bottomPlayProgressView.snp.makeConstraints { (make) in
            make.edges.equalTo(bottomBufferingProgressView)
        }
        
        placeholderImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    
    /// 当手机方向变化时进行相应的转换
    private func transformWithOrientation(orientation: UIDeviceOrientation){
        //如果传入的方向与当前一致，则返回
        if orientation == deviceOrientation {
            return
        }
        
        //如果方向不是以下三种，则返回
        if !(orientation == .portrait || orientation == .landscapeLeft || orientation == .landscapeRight){
            return
        }
        
        // 第一次初始化为unknown
        let isFirst = deviceOrientation == .unknown
        
        //如果是竖屏
        if orientation == .portrait{
            // TODO: 将手势调节音量等去掉
            snapshotButton.isHidden = true
            
            //隐藏playBtn
            playBtn.snp.remakeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(5)
                make.width.equalTo(0)
            }
            
            enterFullScreenButton.snp.remakeConstraints { (make) in
                make.right.top.bottom.equalToSuperview()
                make.width.equalTo(enterFullScreenButton.snp_height)
            }
            
            centerPlayButton.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.width.equalTo(kCenterBtnWH)
            }
            
            if !isFirst {
                // TODO: 不是第一次，也就是从横屏切换成竖屏，此时加入一些操作
                // TODO: 隐藏controlView
                // TODO: 将调节音量的手势去掉
                hideTopBar()
                doConstraintAnimation()
                delegate?.playerViewExitFullScreen(playerView: self)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(rotationAngle: 0)
            }
            
        } else { //横屏
            
            // TODO: 加入手势调节音量的操作
            
            var duration: CGFloat = 0.5
            
            // 如果当前不是横屏的话，需要进行相关变换
            if !deviceOrientation.isLandscape{
                duration = 0.3
                
                playBtn.snp.remakeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(kEdgesSpace)
                    make.width.equalTo(playBtn.snp_height)
                }
                
                enterFullScreenButton.snp.remakeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.right.equalToSuperview().offset(-kEdgesSpace)
                    make.width.equalTo(0)
                }
                
                centerPlayButton.snp.remakeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.height.width.equalTo(0)
                }
                
                doConstraintAnimation()
            }
            
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.transform = orientation == UIDeviceOrientation.landscapeLeft ? CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2)) : CGAffineTransform(rotationAngle: CGFloat(3 * Double.pi / 2))
            }
            
            if deviceOrientation != .unknown {
                // TODO: 执行代理方法
                delegate?.playerViewEnterFullScreen(playerView: self)
            }
        }
        deviceOrientation = orientation
    }
    
    
    // 过渡动画
    private func doConstraintAnimation(){
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - 事件监听函数
extension PLPlayerView{
    /// 监听播放按钮
    @objc func playBtnClick(){
        guard let player = player else {
            play()
            return
        }
        if player.status == .statusPaused{
            resume()
        }else{
            play()
        }
    }

    /// 监听暂停按钮
    @objc func pauseBtnClick(){
        pause()
    }

    /// 监听全屏按钮
    @objc func enterFullScreenBtnClick(){
        if UIDeviceOrientation.landscapeRight == UIDevice.current.orientation{
            transformWithOrientation(orientation: .landscapeRight)
        }else{
            transformWithOrientation(orientation: .landscapeLeft)
        }
    }

    /// 监听退出全屏按钮
    @objc func exitFullScreenBtnClick(){
        transformWithOrientation(orientation: .portrait)
    }

    /// 监听更多按钮
    @objc func moreBtnClick(){

    }

    /// 监听进度条值改变
    @objc func sliderValueChange(){
        // 快速定位到指定播放时间点
        player?.seek(to: CMTimeMake(value: Int64(slider.value * 1000), timescale: 1000))
    }

    /// 监听单击屏幕
    @objc func singleTapAction(){
        if isNeedSetPlayer || player == nil{
            play()  //或改成  setPlayer()
            return
        }

        //如果暂停，则单击屏幕播放
        if player!.status == .statusPaused{
            resume()
            return
        }

        if player!.status == .statusPlaying{
            if bottomBarView.frame.origin.y >= bounds.size.height{
                showBar()
            }else{
                hideBar()
            }
        }
    }

    /// 监听截屏按钮
    @objc private func snapShotBtnClick(){

    }

    @objc private func objcHideBar(){
        hideBar()
    }

    @objc private func objcShowBottomProgressView(){
        if player!.status == .statusPlaying || player!.status == .statusPaused || player!.status == .statusCaching{
            showBottomProgressView()
        }
    }

    @objc func recvDeviceOrientationChangeNotify(){
        
        let or = UIDevice.current.orientation
        if isFullScreen(){
            if or == .landscapeLeft || or == .landscapeRight{
                transformWithOrientation(orientation: or)
            }
        }        
    }
}


// MARK: - 封装设置和控制播放器的函数
extension PLPlayerView{

    private func setPlayer(){
        unSetPlayer()
        //addFullStreenNotify()
        placeholderImageView.isHidden = false

        let option = PLPlayerOption.default()
        option.setOptionValue(15, forKey: PLPlayerOptionKeyTimeoutIntervalForMediaPackets)

        /// 初始化 PLPlayer
        player = PLPlayer.init(url: playUrl, option: option)
        player?.delegate = self
        /// 进入后台是否继续播放
        player?.isBackgroundPlayEnable = true
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)//不知道干嘛

        /// 回调方法的调用队列
        player?.delegateQueue = DispatchQueue.main
        /// 设置内容缩放以适应固定方面。 余数是透明的（默认是填满整个画面）
        player?.playerView?.contentMode = UIView.ContentMode.scaleAspectFit
        /// 是否循环播放
        player?.loopPlay = true

        /// 获取视频输出视图并添加为到当前 UIView 对象的 Subview
        insertSubview((player?.playerView)!, at: 0)
        player?.playerView?.frame = bounds
        player?.playerView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }

    private func unSetPlayer(){
        stop()
        if player?.playerView?.subviews != nil{
            player?.playerView?.removeFromSuperview()
        }
        removeTimer()
    }

    func play(){
        if isNeedSetPlayer{
            setPlayer()
            isNeedSetPlayer = false
        }
        isStop = false

        delegate?.playerViewWillPlay(playerView: self)
        addFullStreenNotify()
        addTimer()

        resetButton(isPlaying: true)

        if !(player?.status == PLPlayerStatus.statusReady ||
            player?.status == PLPlayerStatus.statusPreparing ||
            player?.status == PLPlayerStatus.statusOpen ||
            player?.status == PLPlayerStatus.statusCaching ||
            player?.status == PLPlayerStatus.statusPlaying){
            player?.play()
        }
    }

    func stop(){
        player?.stop()
        removeFullStreenNotify()
        isStop = true
        resetUI()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func resume(){
        delegate?.playerViewWillPlay(playerView: self)
        player?.resume()
        resetButton(isPlaying: true)
    }

    func pause(){
        player?.pause()
        resetButton(isPlaying: false)
    }

    private func resetButton(isPlaying: Bool){
        centerPlayButton.isHidden = isPlaying
        centerPauseButton.isHidden = !isPlaying
        playBtn.isHidden = isPlaying
        pauseBtn.isHidden = !isPlaying
    }

    private func resetUI(){
        bufferingView.progress = 0
        slider.value = 0
        playTimeLabel.text = "00:00:00"
        durationLabel.text = "00:00:00"
        placeholderImageView.isHidden = false

        resetButton(isPlaying: false)
        hideFullLoading()

        hideTopBar()
        hideBottomBar()
        hideBottomProgressView()

        doConstraintAnimation()
    }
}


// MARK: - 实现代理方法 PLPlayerDelegate
extension PLPlayerView: PLPlayerDelegate{
    /// 告知代理对象 PLPlayer 即将开始进入后台播放任务
    func playerWillBeginBackgroundTask(_ player: PLPlayer) {
        pause()
    }

    /// 告知代理对象 PLPlayer 即将结束后台播放状态任务
    func playerWillEndBackgroundTask(_ player: PLPlayer) {
        resume()
    }

    /// 播放状态回调
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        // TODO: 不同的播放状态下可以设置不同的UI等等
        if isStop {
            stop()
            return
        }

        if state == PLPlayerStatus.statusPlaying ||
            state == PLPlayerStatus.statusPaused ||
            state == PLPlayerStatus.statusStopped ||
            state == PLPlayerStatus.statusError ||
            state == PLPlayerStatus.statusUnknow ||
            state == PLPlayerStatus.statusCompleted{

            hideFullLoading()

        }else if state == PLPlayerStatus.statusPreparing ||
            state == PLPlayerStatus.statusReady ||
            state == PLPlayerStatus.statusCaching ||
            state == PLPlayerStatus.stateAutoReconnecting{

            centerPauseButton.isHidden = true
            showFullLoading()

        }else if state == PLPlayerStatus.stateAutoReconnecting{
            centerPauseButton.isHidden = true
            showFullLoading()
            showTip(tip: "重新连接...")
        }

        //开始播放之后，如果 bar 是显示的，则 3 秒之后自动隐藏
        if state == PLPlayerStatus.statusPlaying{
            if bottomBarView.frame.origin.y >= bounds.size.height{
                Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(objcHideBar), userInfo: nil, repeats: false)
            }
        }
    }

    /// 播放错误回调
    func player(_ player: PLPlayer, stoppedWithError error: Error?) {
        // TODO: 错误：尝试重连，失败需给出信息
        showFailTip(tip: "加载失败")
        stop()
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
        //如果是视频，则隐藏占位图
        if firstRenderType == .video{
            placeholderImageView.isHidden = true
            //thumbImageView.isHidden = true
        }

        slider.maximumValue = Float(CMTimeGetSeconds(player.totalDuration))
        slider.minimumValue = 0

        let totalDuration = CMTimeGetSeconds(player.totalDuration)
        let duration = Int(totalDuration + 0.5)
        let hour = duration / 3600
        let min = (duration % 3600) / 60
        let sec = duration % 60
        durationLabel.text = String(format: "%02d:%02d:%02d", arguments: [hour, min, sec])
    }

    /// 点播已缓冲区域
    func player(_ player: PLPlayer, loadedTimeRange timeRange: CMTime) {
        let startSec = 0.0
        let durationSec = CMTimeGetSeconds(timeRange)
        let totalDuration = CMTimeGetSeconds(player.totalDuration)
        bufferingView.progress = Float((durationSec - startSec) / totalDuration)
        bottomBufferingProgressView.progress = bufferingView.progress
    }
}


// MARK: - 封装控制UI的函数
extension PLPlayerView{

    private func isFullScreen() -> Bool{
        return UIDeviceOrientation.portrait != deviceOrientation
    }

    /// 隐藏控制栏
    func hideBar(){
        guard let player = player else { return }
        guard player.status == .statusPlaying else { return }
        // 正在播放才能隐藏
        hideTopBar()
        hideBottomBar()
        centerPauseButton.isHidden = true
        doConstraintAnimation()
    }

    /// 显示控制栏
    func showBar(){
        showBottomBar()
        if isFullScreen(){
            showTopBar()
        }
        centerPauseButton.isHidden = false
        doConstraintAnimation()
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(objcHideBar), userInfo: nil, repeats: false)
    }

    /// 隐藏顶部控制栏
    func hideTopBar(){
        topBarView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp_top)
            make.height.equalTo(kTopBarH)
        }
    }

    /// 显示顶部控制栏
    func showTopBar(){
        topBarView.snp.remakeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kTopBarH);
        }
        snapshotButton.isHidden = false
    }

    /// 隐藏底部控制栏
    func hideBottomBar(){

        bottomBarView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp_bottom)
            make.height.equalTo(kBottomBarH)
        }

        snapshotButton.isHidden = true

        guard let player = player else { return }
        if player.status == .statusPlaying || player.status == .statusPaused || player.status == .statusCaching{
            showBottomProgressView()
        }
    }

    /// 显示底部控制栏
    func showBottomBar(){
        bottomBarView.snp.remakeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(kBottomBarH)
        }
        hideBottomProgressView()
    }

    func showBottomProgressView(){
        bottomPlayProgressView.isHidden = false
        bottomBufferingProgressView.isHidden = false
    }

    func hideBottomProgressView(){
        bottomPlayProgressView.isHidden = true
        bottomBufferingProgressView.isHidden = true
    }


    func addFullStreenNotify(){
        removeFullStreenNotify()
        NotificationCenter.default.addObserver(self, selector: #selector(recvDeviceOrientationChangeNotify), name: UIDevice.orientationDidChangeNotification, object: nil)
//        NotificationCenter().addObserver(self, selector: #selector(recvDeviceOrientationChangeNotify), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func removeFullStreenNotify(){
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        //NotificationCenter().removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}
