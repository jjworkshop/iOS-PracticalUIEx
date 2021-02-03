//
//  ListPresenter.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/06.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift


// テーブルに表示するデータクラス
/*
 データは SampleEtcのSample2と同じ
 ただこちらは検索やソート処理をしていないので少しシンプルになってる
 
 */
class ListDataItem {
    var id:Int
    var imageName:String!
    var title:String!
    var comment: String!
    init (id: Int, imageName: String, title: String, comment: String) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.comment = comment
    }
}

class ListPresenter {

    // テーブルデータ
    var data = Array<ListDataItem>()

    // UIに対応する Observable
    let list: Variable<[Int]> = Variable([])    // データの「id」を保管する

    // テーブルデータをIDで取得
    func getItem(id: Int) -> ListDataItem? {
        let result = data.filter{ $0.id == id }
        return result.count != 0 ? result[0] : nil
    }
    
    // テーブルのアイテム取得
    func loadItems(callback: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {

            // テストデータの設定
            self.loadAllData_for_debugging()
            
            // IDのみのテーブル作成
            // SampleEtcのSample2と違い、抽出やソートは無しね
            self.list.value = self.data.map{ $0.id }
            
            // 処理が完了したらコールバックする
            DispatchQueue.main.async {
                // 完了コールバックはメインスレッドで処理
                callback()
            }
            
        }
    }
    
    // テスト用のデータを設定している
    // これはサンプルのための仮のデータ処理で、通常このような処理は必要ない（上記★コメントを参照のこと）
    private func loadAllData_for_debugging() {
        data.removeAll()
        let titles =   ["1,おふらんすワイン","2,いたーーりあんワイン","3,チリワイン","4,山梨ワイン","5,やまぐちワイン","6,ほげほげ","7,ふがふが","8,ふにゃふにゃ"]
        let comments = ["コメントその１\n２行目はこのような感じ","コメント２-A","コメント３-AB","コメント４","コメント５-ABC","コメント６-ABCD","コメント７-ABCDE","コメント８-ABCDEF"]
        for i in 0..<8 {
            // id は 100〜採番している（特に意味はないけど、デバッグで row と区別するためね）
            data.append(ListDataItem(id: i+100, imageName: "sample2_\(String(format: "%02d", i+1))", title: titles[i], comment: comments[i]))
        }
    }

    
}
