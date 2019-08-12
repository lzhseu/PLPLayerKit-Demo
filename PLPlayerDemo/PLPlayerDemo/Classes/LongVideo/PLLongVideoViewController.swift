//
//  PLLongVideoViewController.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/8.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit

private let kItemH: CGFloat = kHeaderViewH + kPlayerBgViewH
private let kFooterH: CGFloat = kItemH / 5
private let kPlayCellID = "kPlayCellID"

class PLLongVideoViewController: UIViewController {
    
    // MARK: - 自定义属性
    private var isFullScreen = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private var playingCell: PLLongVideoCollectionViewCell?
    
    // MARK: - 懒加载属性
    private lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: kScreenW, height: kItemH)
        //layout.footerReferenceSize = CGSize(width: kScreenW, height: kFooterH)
        
        let collectionView = UICollectionView(frame: self!.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PLLongVideoCollectionViewCell.self, forCellWithReuseIdentifier: kPlayCellID)
        
        return collectionView
    }()
    
    // MARK: - 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stop()    //视图消失时要停止播放
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ScreenOrientationTools.forceOrientationPortrait(view: view)
    }
    
    // MARK: - 属性重写
    override var prefersStatusBarHidden: Bool{
        return isFullScreen
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
}


// MARK: - UI
extension PLLongVideoViewController{
    private func setUI(){
        setNavigationBar()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setNavigationBar(){
        navigationItem.title = "长视频"
        
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
extension PLLongVideoViewController{
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
            let playController = PLPlayerViewController()
            playController.playUrl = URL(string: urlStr!)
            self.present(playController, animated: true, completion: nil)
            // TODO: 判断是不是正确的URL格式
            //以下假设正确
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(sureAction)
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - 播放器控制相关
extension PLLongVideoViewController{
    func stop(){
        let cells = collectionView.visibleCells
        for cell in cells{
            guard let cell = cell as? PLLongVideoCollectionViewCell else { continue }
            cell.stop()
        }
    }
}


// MARK: - 遵守 PLLongVideoCollectionViewCellDelegate
extension PLLongVideoViewController: PLLongVideoCollectionViewCellDelegate{
    func collectionViewWillPlay(cell: PLLongVideoCollectionViewCell) {
        // 第一次
        if playingCell == nil{
            playingCell = cell
            return
        }
        
        if playingCell == cell{
            return
        }
        
        let cellArr = collectionView.visibleCells
        // 一次只能播放一个
        for tempCell in cellArr{
            guard let tempCell = tempCell as? PLLongVideoCollectionViewCell else { return }
            if cell != tempCell {
                tempCell.stop()
            }
        }
        playingCell = cell
    }
    
    func collectionCellEnterFullScreen(cell: PLLongVideoCollectionViewCell) {
        isFullScreen = true
    }
    
    func collectionCellExitFullScreen(cell: PLLongVideoCollectionViewCell) {
        isFullScreen = false
    }
    
}


// MARK: - 遵循 collectionView 代理和数据源协议
extension PLLongVideoViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPlayCellID, for: indexPath) as! PLLongVideoCollectionViewCell
        
        //some operations...
        cell.delegate = self
        return cell
    }
    
}

