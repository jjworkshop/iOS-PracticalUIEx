//
//  EntryBase.swift
//  PracticalUIEx
//
//  Created by Mitsuhiro Shirai on 2019/03/04.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

/*
 このクラスのベースは見ての通り、UITableViewController となってる
 ただし、このViewControllerは、EntryViewControllerのEntryViewの中にあるContainerViewのコンテンツとなっている
 そのコンテンツのUIパーツへのアクセスするためのクラスとして利用している
 なので、このViewControllerはViewControllerそのものの機能としてはたいしたことをしていない
 位置づけとしては、EntryView と同じになる（どちらもUIパーツを内包しているという意味でね）
 
 何故このようにしているかというと
 UITableViewプロパティContentの設定を「Static Cells」にするには、そのUITableViewがUITableViewControllerに
 配置されていなければならない、だけどUITableViewControllerだと、UITableViewがフルスクリーンでレイアウトされるため
 画面の一部分をUITableViewにできない
 その解決策として、UIViewControllerの中にViewControllerを配置し、そのコンテンツとしてUITableViewを配置すれば
 Contentの設定を「Static Cells」にすることが可能になる
 なので、このような仕組みになってるのね
 
 この設定をstoryboardでやるには
 1, 配置したいUIViewControllerにViewControllerを設置
 2, UITableViewControllerをstoryboardに配置
 3, 1で作成したViewControllerと2のUITableViewControllerを接続（いつも通りCtrl+クリックね）
    [接続の指定は Triggered Segues の ViewDidLoad を Embed で UITableViewController に接続ね]
 4, 2で作ったUITableViewControllerのサブクラスを作成して、2のプロパティClassに指定
 5, 2のUITableViewControllerに必要なUIをオートレイアウトを利用して配置
 6, 4で作ったサブクラス（つまり今見ているこのクラスね）へ5で配置したUIを接続
 7, あとは、利用する UIViewControllerに、このクラスのインスタンスの参照コピーすれば、
    そのUIViewController（このサンプルの場合は EntryViewController）からUIにアクセスできるようになる
 
 ちょっと長けど、良く理解してね
 ソフトキー表示によるフィールドの自動移動は、この手法が一番楽で簡単だからね
 他にも、UIScrollViewを使う方法もあるけど（ネットを探すと）これは結構手間もかかるから勧めはしないよ
 
 */

class EntryBase: UITableViewController {

    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var switch1: UISwitch!
    
    @IBOutlet weak var segment2: UISegmentedControl!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var switch2: UISwitch!
    
    @IBOutlet weak var segment3: UISegmentedControl!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var switch3: UISwitch!
    
    @IBOutlet weak var segment4: UISegmentedControl!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var switch4: UISwitch!
    
    @IBOutlet weak var segment5: UISegmentedControl!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var switch5: UISwitch!
    
    @IBOutlet weak var segment6: UISegmentedControl!
    @IBOutlet weak var switch6: UISwitch!
    @IBOutlet weak var textView: UITextView!
    
    // ↑このように同じようなUIが繰り返される場合は配列に参照をコピーして処理しやすくする
    class UIHolder {
        var segment: UISegmentedControl
        var textField: UITextField
        var toggle : UISwitch       // switchは予約語だから変数としては使えないので toggle ね
        init(_ segment: UISegmentedControl, _ textField: UITextField, _ toggle : UISwitch) {
            self.segment = segment
            self.textField = textField
            self.toggle = toggle
        }
    }
    var uiHolder: [UIHolder]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIの参照を配列にコピー
        uiHolder = [UIHolder(segment1, textField1, switch1),
                    UIHolder(segment2, textField2, switch2),
                    UIHolder(segment3, textField3, switch3),
                    UIHolder(segment4, textField4, switch4),
                    UIHolder(segment5, textField5, switch5)]
        
        // メモに枠を作成
        // テキストビュー（メモ）に枠を作成
        textView.layer.borderWidth = 1.0    // 枠のサイズ
        textView.layer.borderColor = UIColor.hex(rgb: AppCom.rgb_boarder_line).cgColor // 枠の色
        textView.layer.cornerRadius = 6.0   // コーナーのラウンド（角丸サイズ）

    }

}
