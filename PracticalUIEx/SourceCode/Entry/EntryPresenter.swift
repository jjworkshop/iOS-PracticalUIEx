//
//  EntryPresenter.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift

// 保存するデータクラス群（Arrayデータを含むデータを保存するときの参考に！）
// セルデータアイテム
// EntryDataに内包するデータも「Deserialize / Serialize」が必須になる
class CellItem:NSObject, NSCoding {
    var segment: Int!
    var text:String!
    var toggle: Bool!
    init (segment: Int, text: String, toggle: Bool) {
        self.segment = segment
        self.text = text
        self.toggle = toggle
    }
    // Deserialize
    required init(coder aDecoder: NSCoder) {
        self.segment = aDecoder.decodeObject(forKey: "segment") as? Int
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.toggle = aDecoder.decodeObject(forKey: "toggle") as? Bool
    }
    // Serialize
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.segment, forKey: "segment")
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.toggle, forKey: "toggle")
    }
}
// エントリーデータ
class EntryData: NSObject, NSCoding {
    var items: Array<CellItem>!     // ← セルデータアイテムのArray
    var segment6: Int!
    var toggle6: Bool!
    var memo:String!
    init (items: Array<CellItem>, segment6: Int, toggle6: Bool, memo: String) {
        self.items = items
        self.segment6 = segment6
        self.toggle6 = toggle6
        self.memo = memo
    }
    // Deserialize
    required init(coder aDecoder: NSCoder) {
        self.items = aDecoder.decodeObject(forKey: "items") as? Array<CellItem>
        self.segment6 = aDecoder.decodeObject(forKey: "segment6") as? Int
        self.toggle6 = aDecoder.decodeObject(forKey: "toggle6") as? Bool
        self.memo = aDecoder.decodeObject(forKey: "memo") as? String
    }
    // Serialize
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.items, forKey: "items")
        aCoder.encode(self.segment6, forKey: "segment6")
        aCoder.encode(self.toggle6, forKey: "toggle6")
        aCoder.encode(self.memo, forKey: "memo")
    }
}

// プレゼンターはここから
class EntryPresenter {

    // ユーザーデータ
    private let uds = UserDefaults.standard
    
    // 何か入力があった場合のObservable
    var dirty: Variable<Bool> = Variable(false)

    // 削除可能かどうかのObservable
    var canRemove: Variable<Bool> = Variable(false)

    // 以下入力データObservable
    // セルの同じUIの繰り返し部分
    var segment: [Variable<Int>] = [Variable(0), Variable(0), Variable(0), Variable(0), Variable(0)]
    var text: [Variable<String>] = [Variable(""), Variable(""), Variable(""), Variable(""), Variable("")]
    var toggle: [Variable<Bool>] = [Variable(false), Variable(false), Variable(false), Variable(false), Variable(false)]
    // セル内に複数のUIがある部分
    var segment6: Variable<Int> = Variable(0)
    var toggle6: Variable<Bool> = Variable(false)
    var memo: Variable<String> = Variable("")
    
    // データの読み出しと保存（SetterとGetterで実装）
    var data:EntryData? {
        /*
         ここでは「UserDefaults」をデータの保存場所として使っている
         */
        get{
            // データの読み出し
            guard
                let archive = uds.object(forKey: AppCom.USER_DEFKEY_SAVE_DATA) as? NSData,
                let data = NSKeyedUnarchiver.unarchiveObject(with: archive as Data) as? EntryData else {
                    canRemove.value = false  // 削除できない
                    // 保存データが無い場合は初期値
                    return EntryData(items: Array(), segment6: 0, toggle6: false, memo: "")
            }
            canRemove.value = true  // 削除可能
            return data
        }
        set(data){
            if let data = data {
                // データの書き出し
                let archive = NSKeyedArchiver.archivedData(withRootObject: data)
                uds.set(archive, forKey: AppCom.USER_DEFKEY_SAVE_DATA)
            }
            else {
                // データ削除
                if (uds.object(forKey: AppCom.USER_DEFKEY_SAVE_DATA) != nil) {
                    uds.removeObject(forKey: AppCom.USER_DEFKEY_SAVE_DATA)
                }
            }
        }
    }
    
    // データを設定
    // オブザーバルにデータを設定することで、双方向バインドによりUIに値が設定される
    func setData(_ data: EntryData) {
        for index in 0..<5 {
            if (data.items.count > index) {
                segment[index].value = data.items[index].segment
                text[index].value = data.items[index].text
                toggle[index].value = data.items[index].toggle
            }
            else {
                segment[index].value = 0
                text[index].value = ""
                toggle[index].value = false
            }
        }
        segment6.value = data.segment6
        toggle6.value = data.toggle6
        memo.value = data.memo
    }
    
    // データを保存
    func saveData() {
        var items: Array<CellItem> = Array()
        for index in 0..<5 {
            items.append(CellItem(segment: segment[index].value, text: text[index].value, toggle: toggle[index].value))
        }
        // dataのSetterが機能することにより、代入するだけでデータが保存される
        data = EntryData(items: items, segment6: segment6.value, toggle6: toggle6.value, memo: memo.value)
        // dirty を落とす
        dirty.value = false
        // 削除可能にする
        canRemove.value = true
    }

    // データを削除
    func removeData() {
        // dataのSetterが機能することにより、nilを代入するだけでデータが削除される
        data = nil
        
        // 削除後にUIフィールドを初期化したくない場合は以下の行をコメントにする
        // ↓
        setData(EntryData(items: Array(), segment6: 0, toggle6: false, memo: ""))
        // ↑
        // 初期化しなければ、そのままもう一度保存の操作が可能
        // どっちが良いかは、アプリ作成のポリシーかな
        
        // dirty を落とす
        dirty.value = false
        // 削除をできなくする
        canRemove.value = false
    }
}
