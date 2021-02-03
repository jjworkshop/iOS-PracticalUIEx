//
//  AppCommon.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2018年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import SCLAlertView
import RxSwift
import SCLAlertView

/*
 定数などはコード中に直接各のではなくて
 このようにアプリケーションのコモンデータとして定義する
 例えば、カラー設定等をここにまとめて書いておくと、あとで色を変更するときに一々各コードを参照する必要がない
 
 */

struct AppCom {
    
    
    // ユーザー設定値の各キー
    static public let USER_DEFKEY_SAVE_DATA = "SavwData"
    
    // SVGファイル
    static public let svg_back      = "back-button"
    static public let svg_done      = "done"
    static public let svg_frog      = "frog"
    static public let svg_list      = "list-square-rounded-interface-symbol"
    static public let svg_pencil    = "pencil-edit-button"
    static public let svg_trash     = "recycling-bin"
    
    // カラー設定
    static public let rgb_brn_icon_navi:    UInt32 = 0x848484   // ナビゲーションバーのアイコン
    static public let rgb_brn_icon_navi_red:UInt32 = 0xff6a04   // ナビゲーションバーのアイコン（レッド）
    static public let rgb_text_black:       UInt32 = 0x000000   // ブラックキスト
    static public let rgb_text_blue:        UInt32 = 0x0433FF   // ブルーテキスト
    static public let rgb_text_red:         UInt32 = 0xFF3500   // レッドテキスト
    static public let rgb_text_gray:        UInt32 = 0x2a2a2a   // グレーテキスト
    static public let rgb_text_lgray:       UInt32 = 0x848484   // ライトグレーテキスト
    static public let rgb_indicator:        UInt32 = 0x19cfc6   // インジケータカラー
    static public let rgb_boarder_line:     UInt32 = 0x3DCFD2   // ボーダーカラー
    static public let rgb_accessory_header: UInt32 = 0xa8a8a8   // アクセサリキーボードの背景
    
}
