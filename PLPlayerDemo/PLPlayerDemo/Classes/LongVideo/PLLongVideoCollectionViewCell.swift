//
//  PLLongVideoCollectionViewCell.swift
//  PLPlayerDemo
//
//  Created by 卢卓桓 on 2019/8/12.
//  Copyright © 2019 zhineng. All rights reserved.
//

import UIKit

let kHeaderViewH: CGFloat = 55
let kPlayerBgViewH: CGFloat = kScreenW * 9 / 16
private let kPlayerViewH: CGFloat = 200
private let kHeaderImageViewWH: CGFloat = 40

protocol PLLongVideoCollectionViewCellDelegate: class {
    func collectionViewWillPlay(cell: PLLongVideoCollectionViewCell)
    func collectionCellEnterFullScreen(cell: PLLongVideoCollectionViewCell)
    func collectionCellExitFullScreen(cell: PLLongVideoCollectionViewCell)
}

class PLLongVideoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - 自定义属性
    weak var delegate: PLLongVideoCollectionViewCellDelegate?
    
    // MARK: - 懒加载属性
    private lazy var playerBgView: UIView = {
        return UIView()
    }()
    
    private lazy var playerView: PLPlayerView = {
        let playerView = PLPlayerView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kPlayerViewH))
        playerView.delegate = self
        return playerView
    }()
    
    private lazy var headerImageView: UIImageView = {
        let headerImageView = UIImageView(image: UIImage(named: "qiniu"))
        headerImageView.layer.cornerRadius = 20
        headerImageView.contentMode = ContentMode.scaleAspectFill
        headerImageView.clipsToBounds = true
        return headerImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0.66, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "lzhseu"
        return label
    }()
    
    private lazy var detailDescLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "zhineng"
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.lightGray
        return bottomLine
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        stop()
        super.prepareForReuse()
    }
}


// MARK: - UI
extension PLLongVideoCollectionViewCell{
    
    private func setUI(){
        let superView = contentView
        superView.addSubview(playerBgView)
        playerBgView.addSubview(playerView)
        superView.addSubview(headerImageView)
        superView.addSubview(nameLabel)
        superView.addSubview(detailDescLabel)
        superView.addSubview(bottomLine)
        
        playerBgView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kPlayerBgViewH)
        }
        
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        headerImageView.snp.makeConstraints { (make) in
            make.top.equalTo(playerBgView.snp_bottom).offset(5)
            make.left.equalTo(superView).offset(10)
            make.bottom.equalTo(superView).offset(-10)
            make.width.height.equalTo(kHeaderImageViewWH)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(detailDescLabel)
            make.top.equalTo(headerImageView.snp_centerY).offset(2)
        }
        
        detailDescLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerImageView.snp_right).offset(10)
            make.bottom.equalTo(headerImageView.snp_centerY)
            make.right.equalToSuperview().offset(-10)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
    }
}


// MARK: - 实现代理方法 PLPlayerViewDelegate
extension PLLongVideoCollectionViewCell: PLPlayerViewDelegate{
    func playerViewEnterFullScreen(playerView: PLPlayerView) {
        guard let superView = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
        playerView.removeFromSuperview()
        superView.addSubview(playerView)
        playerView.snp.remakeConstraints { (make) in
            make.width.equalTo(superView.snp_height)
            make.height.equalTo(superView.snp_width)
            make.center.equalToSuperview()
        }
        superView.setNeedsUpdateConstraints()
        superView.updateConstraintsIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            superView.layoutIfNeeded()
        }
        delegate?.collectionCellEnterFullScreen(cell: self)
    }
    
    func playerViewExitFullScreen(playerView: PLPlayerView) {
        playerView.removeFromSuperview()
        playerBgView.addSubview(playerView)
        playerView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        delegate?.collectionCellExitFullScreen(cell: self)
    }
    
    func playerViewWillPlay(playerView: PLPlayerView) {
        delegate?.collectionViewWillPlay(cell: self)
    }
    
}

// MARK: - 播放器配置、控制相关
extension PLLongVideoCollectionViewCell{
    
    func play(){
        playerView.play()
    }
    
    func stop(){
        playerView.stop()
    }
    
    func configureVideo(enRender: Bool){
    }
}
