//
//  ListViewController.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/06.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class ListViewController: CommonViewController
    // ,UITableViewDelegate     // デリゲート処理が必要ならコメントアウト
{

    private let TAG = "リスト"
    
    private let presenter = ListPresenter()
    private var mainView: ListView!
    
    override func viewDidLoad() {
        super.viewDidLoad(
            title: NSLocalizedString("List Sample", comment:"一覧サンプル"),
            L1:AppCom.svg_back, R1:nil, R2:nil)
        
        // UIViewController直下のUIViewの参照を取得（これはいままで通りね）
        mainView = self.view as? ListView
        
        // UITableVIewのデリゲートを登録（デリゲート処理が必要ならコメントアウト）
        // mainView.tableView.delegate = self
        
        // オブザーバー登録
        setupObservers()
        
        // 初期データを表示（テストデータ）
        updateContent()
    }
    
    // オブザーバーの登録
    private func setupObservers() {
        
        // ナビゲーションバーの戻るボタンタップ
        leftButtonItem?.rx.tap
            .subscribe(onNext: { [unowned self] in
                // 前の画面に戻る
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // テーブルビューアイテムのバインド設定（subscribe）
        presenter.list.asObservable()
            .bind(to: mainView.tableView.rx.items(cellIdentifier: "ListCell")) { (row, id, cell) in
                // テーブルのセル情報を取得
                let cell = cell as! ListViewCell
                let item = self.presenter.getItem(id: id)
                // 左端のイメージを設定
                if let image = item?.imageName {
                    // イメージ有り
                    cell.cellImage.image = UIImage(named: image)
                    /*
                     以下の２つのPropertyは、画像のアスペクト比を保ったまま、画像をクリップさせている
                     UIImageView の contentMode の指定は幾つかあるから Googleで検索して調べてごらん
                     */
                    cell.cellImage.clipsToBounds = true
                    cell.cellImage.contentMode = .scaleAspectFill
                }
                else {
                    // イメージ無し
                    cell.cellImage.image = nil
                }
                // テキスト情報を設定
                cell.titleLabel.text = item?.title ?? "non title"
                cell.commentLabel.text = item?.comment
                // テーブルのセパレータを消す
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false
            }
            .disposed(by: disposeBag)
        
        // スクロールを検知してかっちょいいUI（しかもデータが見やすい）を作る
        // EntryViewControllerとおなじね
        if let tableView = mainView.tableView {
            tableView.rx.contentOffset
                .subscribe(onNext: { offset in
                    // Com.XLOG("\(self.TAG): Scroll位置 - [\(offset)]")
                    if (offset.y > self.mainView.lineOfLimit4image) {
                        // ヘッダイメージ非表示
                        self.mainView.hideHeaderImage()
                    }
                    else if (offset.y < -5) {   // 5ピクセル下にオーバースクロールしたら
                        // ヘッダイメージ表示
                        self.mainView.showHeaderImage()
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    // リストを更新（presenter.loadItemsはスレッド処理）
    private func updateContent() {
        mainView.showIndicator()
        presenter.loadItems(callback: { () -> Void in
            // コールバック処理（メインスレッドで戻されるのでUI処理をしてもOK）
            let count = self.presenter.list.value.count
            Com.XLOG("\(self.TAG) 件数: \(count)件")
            self.mainView.hideIndicator()
        })
    }
}
