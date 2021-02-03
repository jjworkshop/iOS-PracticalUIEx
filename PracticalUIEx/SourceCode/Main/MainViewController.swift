//
//  MainViewController.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class MainViewController: CommonViewController {

    private let presenter = MainPresenter()
    private var mainView: MainView!
    
    override func viewDidLoad() {
        super.viewDidLoad(
            title: NSLocalizedString("TITLE in English!!", comment:"日本語のタイトル！！"),
            L1:AppCom.svg_frog, R1:AppCom.svg_list, R2:AppCom.svg_pencil)
        
        /*
            最初は全て英語表記をメインに作成する
            そんで、文字列を使う場合にこのように記述しておくと、後で英語文字列に対応する日本語文字列を別ファイルで設定できる
            ↓
            NSLocalizedString("TITLE in English!!", comment:"日本語のタイトル！！")
         */
        
        /*
            多言語化はこのあたりを参考にするとOK
            ただ、このあたりの情報は結構変わったりするので、実際に作業するときに調べるのがベターかもね。
            いまのところ、このXCODEバージョン 10.1 だと、以下のサイトの説明でほぼそのまま多言語化にできる。
            ↓
            https://i-app-tec.com/ios/localization.html
         
            練習するなら、「PracticalUIEx_only_en.zip」は多言語化する前のこのprojectなので
            そちらを回答してから自分で多言語化してみると良いかもね（慣れちゃえばこのプロジェクト程度なら３０分位で終わる）
            このprojectは既に多言語化済よ
            「LaunchScreen.storyboard」は日本語を含まないので多言語化はしてないよ
            あと、アプリ名の日本語化もやってないけど必要なら上記サイトを参考にしてね
         
            SourceCode内の、NSLocalizedString をファイルから探して「Localizable.strings」に設定しなければならないんだけど
            （Localizable.stringsの中身をみたらすぐわかるよ）
            今回は数が少ないから手動で探して設定したけど、ツールを使えばもう少し簡単にできる、でもツールの使い方が面倒…
         
         */
        
        /*
            シュミレーターを日本語環境で動かす方法
            面倒だけど、シュミレーターの設定で言語を切り替えれば日本語になる
            でも、面倒なので、XCODEから日本語化で動かす設定を以下に書いておく
         
            1, 左上にあるシュミレーターを選択するプルダウンの左をクリックして「New Scheme...」を選択
            2, 開いたダイアログに左上でプロジェクト名をプルダウンから選択（このプロジェクトの場合は「PracticalUIEx」ね、Posのプロジェクトもあるんで間違えないように！）
            3, そのダイアログで、Schemeの name を「PracticalUIEx(JP)」とか日本語がわかるような名前にする
            4, 1と同じプルダウンから「Edit Scheme...」を選択
            5, 開いたダイアログの左上のプルダウンから「PracticalUIEx(JP)」を選択
            6, 右の「Ran」を選択して、Arguments のタブを選択
            7, Arguments Passed On Launch の「+」ボタンを押して以下の２つをコピー＆ペーストで追加
         
            -AppleLanguages (ja)
            -AppleLocale ja_JP
         
            これで、シュミレーターを起動するときに、「PracticalUIEx(JP)」を選択すると日本語環境で動くようになる。
            英語環境で動かしたければ「PracticalUIEx」を選択してシュミレーターを起動する。
            便利じゃろ！！
         
         */
        
        /*
            アプリアイコンについて
            アプリのアイコンとして必要なサイズは全部で８サイズ必要ね
            _ImageWork パスの app_icons にSampleを用意しておいたから作るときに参考にすべし！
            アイコンの設定は、 Assets.xcassets の AppIcon にイメージを正しい位置にドロップするのよ
            サイズによりドロップする場所が違うから注意ね
         */
        
        
        mainView = self.view as? MainView
        
        // オブザーバー登録
        setupObservers()
    }

    // オブザーバーの登録
    private func setupObservers() {
        
        // ナビゲーションバーのカエルボタンタップ
        leftButtonItem?.rx.tap
            .subscribe(onNext: { _ in
                let alertView = SCLAlertView()
                alertView.addButton(NSLocalizedString("Sure!", comment:"もちろん！")) {
                    Com.shortMessage(NSLocalizedString("Gently from behind me♡", comment:"やさしく後ろからね♡"))
                }
                alertView.showInfo(NSLocalizedString("Confirm", comment:"確認"),
                                   subTitle: NSLocalizedString("Are you eat me?", comment:"僕をたべちゃうの？"),
                                   closeButtonTitle: NSLocalizedString("No", comment:"いいえ"))
            })
            .disposed(by: disposeBag)
        
        // ナビゲーションバーのリストボタンタップ
        rightButtonItem1?.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.performSegue(withIdentifier: "ListSegue", sender: nil)
            })
            .disposed(by: disposeBag)
        
        // ナビゲーションバーのペンシルボタンタップ
        rightButtonItem2?.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.performSegue(withIdentifier: "EntrySegue", sender: nil)
            })
            .disposed(by: disposeBag)
    }
    
}

