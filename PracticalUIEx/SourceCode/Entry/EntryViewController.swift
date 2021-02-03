//
//  EntryViewController.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class EntryViewController: CommonViewController {

    private let TAG = "エントリ"
    
    private let presenter = EntryPresenter()
    private var mainView: EntryView!
    private var entryBase: EntryBase!

    override func viewDidLoad() {
        super.viewDidLoad(
            title: NSLocalizedString("Entry Sample", comment:"入力サンプル"),
            L1:AppCom.svg_back, R1:AppCom.svg_trash, R2:AppCom.svg_done)
        
        // UIViewController直下のUIViewの参照を取得（これはいままで通りね）
        mainView = self.view as? EntryView
        
        // EntryBase（UITableVIewControllerのサブクラス）の参照を取得
        entryBase = children[0] as? EntryBase
        
        // オブザーバー登録
        setupObservers()
        
        // データの初期値を設定
        setValueToScreen()
    }
    
    // オブザーバーの登録
    private func setupObservers() {
        
        /*
         このメソッドは長いけど、いつものやつの繰り返しだからね
         各UIを処理する定型パタンだよ
         差異はテーブルに配置したオブザーバルの対象（UI）は、いつもとはちょっと違う場所にあるくらいね
         */
        
        
        // ナビゲーションバーの戻るボタンタップ
        leftButtonItem?.rx.tap
            .subscribe(onNext: { [unowned self] in
                // 終了をチェック
                self.conformDismissal()
            })
            .disposed(by: disposeBag)
        
        // ナビゲーションバーのゴミ箱ボタンタップ
        rightButtonItem1?.rx.tap
            .subscribe(onNext: { [unowned self] in
                // データを削除をチェック
                self.conformDataRemove()
            })
            .disposed(by: disposeBag)
        
        // ナビゲーションバーのDONEボタンタップ
        rightButtonItem2?.rx.tap
            .subscribe(onNext: { [unowned self] in
                // データを保存
                self.presenter.saveData()
            })
            .disposed(by: disposeBag)
        
        // UITableVIewに配置したUIの通知処理（全て双方向バインド）
        
        // セルの同じUIの繰り返し部分
        for (index, cell) in entryBase.uiHolder.enumerated() {
            
            // セグメント選択
            cell.segment.tag = index
            cell.segment.rx.controlEvent(.valueChanged).asObservable()
                .map({ () -> Int in cell.segment.selectedSegmentIndex })
                .subscribe(onNext: { idx in
                    Com.XLOG("\(self.TAG): segment[\(index)] - [\(idx)]")
                    self.presenter.segment[index].value = idx
                    self.presenter.dirty.value = true
                })
                .disposed(by: disposeBag)
            presenter.segment[index].asObservable().bind(to: cell.segment.rx.selectedSegmentIndex).disposed(by: disposeBag)
            
            // TextField入力（入力の制限なし）
            cell.textField.tag = index
            cell.textField.rx.text
                .map { $0 ?? "" }
                .bind(to: presenter.text[index])
                .disposed(by: disposeBag)
            presenter.text[index].asObservable().bind(to: cell.textField.rx.text).disposed(by: disposeBag)
            // フィールドの入力完了を通知
            cell.textField.rx.controlEvent(UIControlEvents.editingChanged)
                .subscribe( onNext: { [weak self] in
                    if (cell.textField.markedTextRange == nil) {
                        // 入力が確定した
                        Com.XLOG("\(self!.TAG): text[\(index)] - [\(self?.presenter.text[index].value ?? "")]")
                        self?.presenter.dirty.value = true
                    }
                })
                .disposed(by: disposeBag)
            // フィールドにキーボードアクセサリを付ける
            cell.textField.inputAccessoryView = kbAccessory
            
            // Switch入力
            cell.toggle.rx.controlEvent(.valueChanged).asObservable()
                .map({ () -> Bool in cell.toggle.isOn })
                .subscribe(onNext: { on in
                    self.presenter.toggle[index].value = on
                    Com.XLOG("\(self.TAG): switch[\(index)] - [\(on)]")
                    self.presenter.dirty.value = true
                })
                .disposed(by: disposeBag)
            // 双方向バインド
            presenter.toggle[index].asObservable().bind(to: cell.toggle.rx.isOn).disposed(by: disposeBag)
        }
        
        // セル内に複数のUIがある部分
        
        // Segment6の選択
        entryBase.segment6.rx.controlEvent(.valueChanged).asObservable()
            .map({ () -> Int in self.entryBase.segment6.selectedSegmentIndex })
            .subscribe(onNext: { idx in
                Com.XLOG("\(self.TAG): segment[6] - [\(idx)]")
                self.presenter.segment6.value = idx
                self.presenter.dirty.value = true
            })
            .disposed(by: disposeBag)
        presenter.segment6.asObservable().bind(to: entryBase.segment6.rx.selectedSegmentIndex).disposed(by: disposeBag)
     
        // Switch6入力
        entryBase.switch6.rx.controlEvent(.valueChanged).asObservable()
            .map({ () -> Bool in self.entryBase.switch6.isOn })
            .subscribe(onNext: { on in
                self.presenter.toggle6.value = on
                Com.XLOG("\(self.TAG): switch[6] - [\(on)]")
                self.presenter.dirty.value = true
            })
            .disposed(by: disposeBag)
        presenter.toggle6.asObservable().bind(to: entryBase.switch6.rx.isOn).disposed(by: disposeBag)
        
        // TextView（メモ）入力（入力制限なし）
        entryBase.textView.rx.text
            .map { $0 ?? "" }
            .bind(to: presenter.memo)
            .disposed(by: disposeBag)
        presenter.memo.asObservable().bind(to: entryBase.textView.rx.text).disposed(by: disposeBag)
        // フィールドの入力完了を通知
        entryBase.textView.rx.didChange
            .subscribe( onNext: { [weak self] in
                if (self?.entryBase.textView.markedTextRange == nil) {
                    // 入力が確定した
                    Com.XLOG("\(self!.TAG): memo - [\(self?.presenter.memo.value ?? "")]")
                    self?.presenter.dirty.value = true
                }
            })
            .disposed(by: disposeBag)
        // メモにキーボードアクセサリを付ける
        entryBase.textView.inputAccessoryView = kbAccessory
        
        // 削除可能かどうかの通知
        presenter.canRemove.asObservable()
            .subscribe(onNext: { possible in
                Com.XLOG("\(self.TAG): 削除可能かどうか - [\(possible)]")
                // ナビゲーションのゴミ箱ボタンの有効/無効とカラーを設定
                self.rightButtonItem1!.isEnabled = possible
                self.rightButtonItem1!.tintColor = UIColor.hex(rgb:
                    possible ? AppCom.rgb_brn_icon_navi_red : AppCom.rgb_brn_icon_navi)
            })
            .disposed(by: disposeBag)
        
        // 何か入力の変更があった場合の通知
        // 上記のデータストリームにデータが流れたときに「presenter.dirty.value = true」としている部分をトリガーにして
        // このasObservableに通知される（まぁこれもほぼ定型処理ね）
        presenter.dirty.asObservable()
            .subscribe(onNext: { dirty in
                Com.XLOG("\(self.TAG): 入力状態がチェンジ - [\(dirty)]")
                // ナビゲーションのDONEボタンの有効/無効を設定
                self.rightButtonItem2!.isEnabled = dirty
            })
            .disposed(by: disposeBag)
        
        // ここから下はちょっとトリッキーね
        // スクロールを検知してかっちょいいUI（しかもデータが見やすい）を作る
        /*
            entryBase.view は、実際は UITableViewだけど、UIScrollViewのオブジェクトして扱っている
            こうゆうのをダウンキャストと言う
            何故これが出来るかというと、UITableView は UIScrollView を継承したクラスだからね
         */
        if let tableView = entryBase.view as? UIScrollView {
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

    // データの初期値を設定
    private func setValueToScreen() {
        // データを読み出し
        let data = presenter.data
        // データを設定
        // Observable にデータを設定することで、双方向バインドしているUIオブジェクトに値が設定される
        presenter.setData(data!)
    }
    
    // データの削除をダイアログで確認
    private func conformDataRemove() {
        if (presenter.canRemove.value) {
            let alertView = SCLAlertView()
            alertView.addButton(NSLocalizedString("Yes", comment:"はい")) {
                // データ削除
                self.presenter.removeData()
            }
            alertView.showInfo(NSLocalizedString("Confirm", comment:"確認"),
                               subTitle: NSLocalizedString("Do you remove this data?", comment:"データを削除しますか？"),
                               closeButtonTitle: NSLocalizedString("Cancel", comment:"キャンセル"))
        }
        else {
            // 前の画面に戻る
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 終了をダイアログで確認
    private func conformDismissal() {
        if (presenter.dirty.value) {
            let alertView = SCLAlertView()
            alertView.addButton(NSLocalizedString("Yes", comment:"はい")) {
                // 前の画面に戻る
                self.navigationController?.popViewController(animated: true)
            }
            alertView.showInfo(NSLocalizedString("Confirm", comment:"確認"),
                               subTitle: NSLocalizedString("Do you annul this data?", comment:"入力データを破棄しますか？"),
                               closeButtonTitle: NSLocalizedString("No", comment:"いいえ"))
        }
        else {
            // 前の画面に戻る
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
