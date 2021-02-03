//
//  CommonView.swift
//  UIViewのサブクラス（共通部分のインプリメント）
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2018年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift

/*
 ViewControllerのトップViewで共通化する部分をサブクラス化してインプリメントしておく 
 */

class CommonView: UIView {

    internal var isFirst = true
    let indicator = UIActivityIndicatorView(style: .whiteLarge)
    private var indicatorCounter = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if (!isFirst) {return}    // 最初だけ
        isFirst = false
        
        // レイアウト確定後の最初の処理
        firstlayoutSubviews()
        
        // インジケーター
        indicator.color = UIColor.hex(rgb: AppCom.rgb_indicator)
        indicator.center = CGPoint(x: self.center.x, y: self.bounds.size.height / 3)
        self.addSubview(indicator)        
    }

    // サブクラスでオーバーライドする
    open func setup() {}

    // サブクラスでオーバーライドする
    open func firstlayoutSubviews() {}

    // インジケーター（ActivityIndicator）の表示管理
    // どの画面でもクルクルインジケーターが必要なときに利用できるようにしている
    func showIndicator() {
        if (indicatorCounter == 0) {
            indicator.startAnimating()
        }
        indicatorCounter += 1
    }
    func hideIndicator() {
        indicatorCounter -= 1
        if (indicatorCounter <= 0) {
            indicatorCounter = 0
            indicator.stopAnimating()
        }
    }
}
