//
//  ListView.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/06.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

class ListView: CommonView {

    /*
     このクラスは EntryViewクラスとだいたい同じね（ヘッダイメージの開閉のみ処理）
     違うのは、こちらは UITableView を直接 View に内包している
     EntryView では、ContainerView に UITableView を入れて View に内包させている
     前者は、UITableViewのContentプロパティが「Dynamic Propertys」になっていて、動的にセルを作成している
     後者は、UITableViewのContentプロパティが「Static Cells」になっていて、予めstoryboardでセル内にUIオブジェクトを作成している
     「Static Cells」については、EntryBase.swift のコメントも読んでね！
     */
    
    @IBOutlet weak var imageFrameTop: NSLayoutConstraint!
    @IBOutlet weak var imageFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    // イメージを隠す境界（これ以上Scrollするとイメージは消える）
    var lineOfLimit4image:CGFloat = 60.0
    
    // ヘッダイメージの表示状態
    private var originImageFrameHeight: CGFloat = 0.0
    private var isShowedHeaderImage = true

    // レイアウト完了処理
    override func firstlayoutSubviews() {
        // イメージの高さを保存しておく
        originImageFrameHeight = imageFrameHeight.constant
        
        // テーブルビューにカスタムセルを登録
        tableView.register(UINib(nibName: "ListViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        // テーブルビューのセパレータを消す
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        // テーブルビューセルの高さ
        tableView.rowHeight = 72
        
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
