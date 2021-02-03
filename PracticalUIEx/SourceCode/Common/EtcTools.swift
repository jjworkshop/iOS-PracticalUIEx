//
//  EtcTools.swift
//  共通メソッド群
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

/*
    頻繁につかう処理などをここに記述してある
    そのまま自分のprojectにファイル毎コピーすれば使える
 
    SampleEtc と少し違ってるのは、各メソッドは Com というスタティックなクラスに内包させている
 
 */

struct Com {

    // デバッグプリント
    // 使用例：XLOG(String(format: "abc - %d", 10))
    static func XLOG(_ obj: Any?,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        #if DEBUG
        // デバッグモードのみ出力
        let pathItem = String(file).components(separatedBy: "/")
        let fname = pathItem[pathItem.count-1].components(separatedBy: ".")[0]
        if let obj = obj {
            print("D:[\(fname):\(function) #\(line)] : \(obj)")
        } else {
            print("D:[\(fname):\(function) #\(line)]")
        }
        #endif
    }

    // スレッドチェック
    // UIの更新はメインスレッドでしか許されない
    // RXや通信ライブラリのコールバック処理で、どのスレッドで処理されているか解らない時はこれでチェック
    static func checkThread() {
        if (Thread.isMainThread) {
            XLOG("ここはメインスレッド内")
        }
        else {
            XLOG("ここはワーカースレッド内")
        }
    }

    // ファーストレスポンダーを探す
    // 入力フィールド等で現在フォーカスのあるオブジェクトね
    static func findFirstResponder(_ view: UIView!) -> UIView? {
        if (view.isFirstResponder) {
            return view
        }
        for subView in view.subviews {
            if (subView.isFirstResponder) {
                return subView
            }
            let responder = findFirstResponder(subView)
            if (responder != nil) {
                return responder;
            }
        }
        return nil;
    }
    
    // 現在一番上の（画面に表示している）ViewControllerを探す
    static func getTopViewController() -> UIViewController?  {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            return topViewControlelr
        } else {
            return nil
        }
    }
    
    // トースト表示
    // トーストは自動で消える画面下部に表示するメッセージ
    static func shortMessage(_ message: String) {
        if let controller = getTopViewController() {
            Toast.show(message: message, controller: controller)
        }
    }

    // デバイスのサイズ
    static func windowSize()  -> CGSize {
        // 画面がローテーションする場合は注意
        return UIScreen.main.bounds.size
    }
    
    // ナビゲーションバーの高さを取得（システムのデフォルトは 44）
    static func navigationBarHeight(_ viewController: UIViewController?) -> CGFloat {
        if (viewController == nil) {
            return 44
        }
        return viewController!.navigationController?.navigationBar.frame.size.height ?? 44
    }
    
    // 日本語環境か？
    static let isJapanese: Bool = {
        guard let prefLang = Locale.preferredLanguages.first else {
            return false
        }
        return prefLang.hasPrefix("ja")
    }()
    
}
