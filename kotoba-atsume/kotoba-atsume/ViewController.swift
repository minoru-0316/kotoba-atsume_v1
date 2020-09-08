//
//  ViewController.swift
//  kotoba-atsume
//
//  Created by Minoru Edo on 2020/09/08.
//  Copyright © 2020 Minoru Edo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Search Barのdelegate通知先を設定
        searchText.delegate = self
        //入力のヒントとなる、プレースホルダーを設定
        searchText.placeholder = "検索キーワードを入力してください"
        
        //TableViewのdataSourceを設定
        tableView.dataSource = self
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //本のリスト（タプル配列）
    var searchBookList : [(title:String?, authors:[String?], publisher:String?, industryIdentifiers:[industryIdentifiersJson], imageLinks:ImageLinkJson, previewLink:URL)] = []
    
    //検索ボタンをクリック（タップ時）
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            print(searchWord)
            //検索ワードが入力されていたら、googleBooksAPIで書籍を検索
            searchBook(keyword: searchWord)
        }
    }
    
    // imageLinkのデータ構造
    struct  ImageLinkJson: Codable {
        let smallThumbnail: URL?
    }
    
    // isbnLinkのデータ構造
    struct  industryIdentifiersJson: Codable {
        let identifier: String?
    }
    
    //VolumeInfoJson内のデータ構造
    struct VolumeInfoJson: Codable {
        //本のタイトル
        let title: String?
        //著者
        let authors: [String]?
        //出版社
        let publisher: String?
        //画像リンク
        let imageLinks: ImageLinkJson?
        //JANコード(ISBN_10 ISBN_13)
        let industryIdentifiers: [industryIdentifiersJson]?
        //紹介ページへのリンク
        let previewLink: URL?
    }
    
    // JSONのItems内のデータ構造
       struct ItemsJson: Codable {
           let volumeInfo: VolumeInfoJson?
       }
       
       //JSONのデータ構造
       struct ResultJson: Codable {
           //複数要素
           let kind: String?
           let totalItems: Int?
           let items:[ItemsJson]?
       }
    
    //searchBookメソッド
    //第一引数: keyword 検索したいワード
    func searchBook(keyword : String) {
        //お菓子の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        //リクエストURLの組み立て
        guard let req_url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(keyword_encode)") else{
            return
        }
//        print(req_url)
        
        //リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        //データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil,
                                 delegateQueue: OperationQueue.main)
        
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            //セッションを終了
            session.finishTasksAndInvalidate()
            //do try catchエラーハンドリング
            do {
                //JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                //受け取ったJSONデータをバース（解析）して格納
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                //print("jsonを出力")
//                print(json)
                
                //本の情報が取得できているか確認
                if let itemsInfo = json.items {
                    
                    //検索結果を初期化する処理
                    self.searchBookList.removeAll()
                    
                    //取得している本の数だけ処理
                    for items in itemsInfo {
                        //本の情報をアンラップ
                        if
                            let title = items.volumeInfo?.title ,
                            let authors:[String?] = items.volumeInfo?.authors ,
                            let publisher:String? = items.volumeInfo?.publisher ,
                            let industryIdentifiers = items.volumeInfo?.industryIdentifiers ,
                            let imageLinks = items.volumeInfo?.imageLinks ,
                            let previewLink = items.volumeInfo?.previewLink
                        {
                            //１つの本をタプルでまとめて管理
                            let book = (title,
                                        authors,
                                        publisher,
                                        industryIdentifiers,
                                        imageLinks,
                                        previewLink
                            )
                            //本の配列へ追加
                            self.searchBookList.append(book)
//                            print(book)
                        }
                    }
                    
                    //Table View　を更新する
                    self.tableView.reloadData()
                    
                    if let bookdbg = self.searchBookList.first {
//                        print("------------------")
//                        print("bookList[0] = \(bookdbg)")
                    }
                }
            } catch {
                //エラー処理
                print("エラーが出ました")
            }
        })
        //ダウンロード開始
        task.resume()
    }
    
    
    //Cellの総数を返すdataSourceメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //本のリストの総数
        return searchBookList.count
    }
    
    //Cellに値を設定するdataSrouceメソッド（必須）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う、Cellオブジェクト（１行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        
        //本のタイトルを取得
        cell.textLabel?.text = searchBookList[indexPath.row].title
        //本の画像を取得
        if let imageData = try? Data(contentsOf: searchBookList[indexPath.row].imageLinks.smallThumbnail!) {
            //正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellに本の画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        //設定済みのCellオブジェクトを画面に反映
        return cell
    }
}

