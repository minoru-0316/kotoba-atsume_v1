//
//  BookDetail.swift
//  kotoba-atsume
//
//  Created by Minoru Edo on 2020/09/18.
//  Copyright © 2020 Minoru Edo. All rights reserved.
//
//　参考 https://naoyalog.com/【ios】iosアプリ開発入門-画面遷移編１/
//      SecondViewController → BookDetail　に修正して進める。

import UIKit

class BookDetail: UIViewController {
    
    
    @IBOutlet weak var BookTitle: UILabel!
    @IBOutlet weak var authors: UILabel!
    @IBOutlet weak var publisher: UILabel!
    @IBOutlet weak var imageLinks: UILabel!
    @IBOutlet weak var industryIdentifer: UILabel!
    @IBOutlet weak var previewLink: UILabel!
    
    
    
    
    var titleText: String?
    var authorsText: [String]?
    var publisherText: String?
    var imageLink: URL?
    var industryIdentifiersText: [String]?
    var previewLinkURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("詳細画面が開いた")
        self.BookTitle.text = self.titleText
        
        self.publisher.text = self.publisherText
        if publisherText == nil {
            self.publisher.text = "情報がありません"
            self.publisher.textColor = UIColor.red
        }
        self.authors.text = self.authorsText!.joined(separator: "、")
        

    }
    
    
    @IBAction func registerToBookshelf(_ sender: Any) {
        print("本棚へ登録 ボタンが押された")
    }
    
    
    @IBAction func registerToConcern(_ sender: Any) {
        print("気になるへ登録 ボタンが押された")
    }
}
