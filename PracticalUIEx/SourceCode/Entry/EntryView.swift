//
//  EntryView.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

class EntryView: CommonView {
    
    @IBOutlet weak var imageFrameTop: NSLayoutConstraint!
    @IBOutlet weak var imageFrameHeight: NSLayoutConstraint!
    
    // イメージを隠す境界（これ以上Scrollするとイメージは消える）
    var lineOfLimit4image:CGFloat = 60.0
    
    // ヘッダイメージの表示状態
    private var originImageFrameHeight: CGFloat = 0.0
    private var isShowedHeaderImage = true
    
    // レイアウト完了処理
    override func firstlayoutSubviews() {
        // イメージの高さを保存しておく
        originImageFrameHeight = imageFrameHeight.constant
    }
    
    // ヘッダイメージの表示（アニメーション付き）
    func showHeaderImage() {
        if (!isShowedHeaderImage) {
            Com.XLOG("showHeaderImage")
            self.imageFrameTop.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                self.isShowedHeaderImage = true
            })
        }
    }
    
    // ヘッダイメージの非表示（アニメーション付き）
    func hideHeaderImage() {
        if (isShowedHeaderImage) {
            Com.XLOG("hideHeaderImage")
            self.imageFrameTop.constant = -originImageFrameHeight
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                self.isShowedHeaderImage = false
            })
        }
    }
    
}
