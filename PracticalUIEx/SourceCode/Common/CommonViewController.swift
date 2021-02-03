//
//  CommonViewController.swift
//  UIViewControllerのサブクラス（共通部分のインプリメント）
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2018年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import SVGKit
import Alamofire

/*
 アプリの、ViewControllerので共通化する部分をサブクラス化してインプリメントしておく
 */

class CommonViewController: UIViewController {
    
    var arg: Any?
    
    let disposeBag = DisposeBag()
    
    private let iconSize: CGSize = CGSize(width: 20, height: 20)
    var leftButtonItem:UIBarButtonItem? = nil       // ナビゲーションバーの左ボタン
    var titleButtonItem:UIBarButtonItem!            // ナビゲーションバーのタイトル
    var rightButtonItem1:UIBarButtonItem? = nil     // ナビゲーションバーの右ボタン1
    var rightButtonItem2:UIBarButtonItem? = nil     // ナビゲーションバーの右ボタン2
    var rightButtonItem3:UIBarButtonItem? = nil     // ナビゲーションバーの右ボタン3
    private let barTitle = UILabel()
    private var titleWidth:CGFloat!
    
    // アクセサリキーボード
    private var keyboardHeader: UIView!
    var kbAccessory:UIView {
        get{
            return keyboardHeader
        }
    }

    // 左にボタン１つ、右に２つまでの場合
    func viewDidLoad(title:String?, L1:String?, R1:String?, R2:String?) {
        titleWidth = 160 + Com.windowSize().width - 320 // 160 は横 320サイズでの限界値（右にボタン2つまで）
        didLoad(title: title, L1: L1, R1: R1, R2: R2, R3: nil)
    }
    
    // 左にボタン１つ、右に３つまでの場合
    func viewDidLoad(title:String?, L1:String?, R1:String?, R2:String?, R3:String?) {
        titleWidth = 100 + Com.windowSize().width - 320 // 100 は横 320サイズでの限界値（右にボタン3つまで）
        didLoad(title: title, L1: L1, R1: R1, R2: R2, R3: R3)
    }
    
    // viewDidLoad 完了時の処理
    private func didLoad(title:String?, L1:String?, R1:String?, R2:String?, R3:String?) {
        super.viewDidLoad()

        var leftButtons = Array<Any>()
        var rightButtons = Array<Any>()
        let caption = title != nil ? title : ""
        
        // タイトルのフォントサイズ計算（文字数により可変：何故かLabelの可変フォント設定が効かないので）
        let fontSize: CGFloat = calcTitleFontSize(caption)
        
        // タイトル作成
        barTitle.text = caption
        barTitle.frame = CGRect(x:0, y:0, width:titleWidth, height:44)
        barTitle.font = UIFont.systemFont(ofSize: fontSize)
        barTitle.textColor = UIColor.hex(rgb: AppCom.rgb_text_gray)
        barTitle.numberOfLines = 0
        barTitle.adjustsFontSizeToFitWidth = true
        barTitle.lineBreakMode = .byTruncatingTail          // 末尾に ...
        barTitle.textAlignment = .left  // 左詰
        let titleButtonItem = UIBarButtonItem(customView: barTitle)
        leftButtons.append(titleButtonItem)
        
        // ナビゲーションバーのボタンの作成
        if (L1 != nil) {
            let leftButtonImage = SVGKImage(named: L1)
            leftButtonImage?.size = iconSize
            leftButtonItem = UIBarButtonItem()
            leftButtonItem!.image = leftButtonImage?.uiImage
            leftButtonItem!.style = UIBarButtonItem.Style.plain
            leftButtonItem!.tintColor = UIColor.hex(rgb: AppCom.rgb_brn_icon_navi)
            leftButtons.insert(leftButtonItem!, at: 0)
        }
        if (R3 != nil) {
            let rightButtonImage3 = SVGKImage(named: R3)
            rightButtonImage3?.size = iconSize
            rightButtonItem3 = UIBarButtonItem()
            rightButtonItem3!.image = rightButtonImage3?.uiImage
            rightButtonItem3!.style = UIBarButtonItem.Style.plain
            rightButtonItem3!.tintColor = UIColor.hex(rgb: AppCom.rgb_brn_icon_navi)
            rightButtons.append(rightButtonItem3!)
        }
        if (R2 != nil) {
            let rightButtonImage2 = SVGKImage(named: R2)
            rightButtonImage2?.size = iconSize
            rightButtonItem2 = UIBarButtonItem()
            rightButtonItem2!.image = rightButtonImage2?.uiImage
            rightButtonItem2!.style = UIBarButtonItem.Style.plain
            rightButtonItem2!.tintColor = UIColor.hex(rgb: AppCom.rgb_brn_icon_navi)
            rightButtons.append(rightButtonItem2!)
        }
        if (R1 != nil) {
            let rightButtonImage1 = SVGKImage(named: R1)
            rightButtonImage1?.size = iconSize
            rightButtonItem1 = UIBarButtonItem()
            rightButtonItem1!.image = rightButtonImage1?.uiImage
            rightButtonItem1!.style = UIBarButtonItem.Style.plain
            rightButtonItem1!.tintColor = UIColor.hex(rgb: AppCom.rgb_brn_icon_navi)
            rightButtons.append(rightButtonItem1!)
        }
        
        // ナビゲーションバーにボタンパーツ配置
        self.navigationItem.title = nil
        self.navigationItem.setLeftBarButtonItems(leftButtons as? [UIBarButtonItem], animated: true)
        self.navigationItem.setRightBarButtonItems(rightButtons as? [UIBarButtonItem], animated: true)
        
        // アクセサリキーボードにCloseボタンを付けて用意しておく
        keyboardHeader = UIView(frame: CGRect(x:0, y:0, width:Com.windowSize().width, height:40))
        keyboardHeader.backgroundColor = UIColor.hex(rgb: AppCom.rgb_accessory_header)
        let keyboardCloseButton = UIButton()
        keyboardCloseButton.setTitle(NSLocalizedString("↓ Close", comment:"↓ 閉じる"), for: .normal)
        keyboardCloseButton.contentHorizontalAlignment = .right
        keyboardCloseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        keyboardCloseButton.frame = CGRect(x:keyboardHeader.frame.size.width - 208, y:0, width:200, height:40)
        keyboardCloseButton.tintColor = UIColor.white
        keyboardHeader.addSubview(keyboardCloseButton)
        
        // アクセサリキーボードのCloseボタン押下処理
        keyboardCloseButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.closeSoftKyeboard()
            })
            .disposed(by: disposeBag)

        /*
         アクセサリキーボードをフィールドに付けるには、ViewControllerから以下のようにする
         ↓
         anyField.inputAccessoryView = kbAccessory
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // タイトルのフォントサイズを決定
    private func calcTitleFontSize(_ title: String?) -> CGFloat {
        var fontSize: CGFloat = 16.0
        if let caption = title {
            while (true) {
                let size = caption.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize)])
                if (size.width > titleWidth && fontSize > 12.0)    {
                    fontSize -= 0.5
                }
                else {
                    break
                }
            }
        }
        return fontSize
    }
    
    // タイトル変更
    func setCaption(_ title: String?) {
        let fontSize: CGFloat = calcTitleFontSize(title)
        barTitle.font = UIFont.systemFont(ofSize: fontSize)
        barTitle.text = title ?? ""
    }
    
    // ボタンのイメージを変更
    func changeButtonImage(_ buttonItem: UIBarButtonItem?, svgName: String) {
        let svgImage = SVGKImage(named: svgName)
        svgImage?.size = iconSize
        buttonItem?.image = svgImage?.uiImage
    }
    
    // 戻る
    open func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - オフラインチェック
    
    func checkOffline() {
        let net = NetworkReachabilityManager()
        net?.startListening()
        if  net?.isReachable ?? false {
            if ((net?.isReachableOnEthernetOrWiFi) != nil) {
                //do some
                Com.XLOG("ONLINE: Ethernet or WiFi")
            }else if(net?.isReachableOnWWAN)! {
                //do some
                Com.XLOG("ONLINE: WWAN")
            }
        } else {
            //オフライン
            Com.shortMessage(NSLocalizedString("It is offline.", comment:"オフラインです"))
        }
    }
    
    // MARK: - キーボード関連
    
    // キーボードを閉じる
    func closeSoftKyeboard() {
        if let responder = Com.findFirstResponder(self.view) {
            responder.resignFirstResponder()
        }
    }

}
