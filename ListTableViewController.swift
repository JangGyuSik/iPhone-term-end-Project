//
//  ListTableViewController.swift
//  JGS_IphoneApp_Project
//
//  Created by D7702_10 on 2017. 11. 14..
//  Copyright © 2017년 DoubleK. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController,XMLParserDelegate {
    
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var key = ""
    var servieKey = "nsGYsnRIMYDW2RwmA8hMBTGFXYN6LyB4rJC71IIGNVGIplpzE3iahHPLqCU4BnTjhOGT4b%2FgbTLg3vfGFtIffQ%3D%3D"
    var listEndPoint = "http://opendata.busan.go.kr/openapi/service/PublicToilet/getToiletInfoList"
    let detailEndPoint = "http://opendata.busan.go.kr/openapi/service/PublicToilet/getToiletInfoDetail"
    
    var totalCount = 0 //총 갯수를 저장하는 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산 공공 화장실"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.plist")
        
        //시작할때마다 TotalCount를 받아옴
//        getList(numOfRows: 0)
        
        if fileManager.fileExists(atPath: (url?.path)!) {
            //파일이 있으면 파일에서 읽어옴
            items = NSArray(contentsOf: url!) as! Array
            
            //파일에서 읽어본 갯수와 totalCount를 비교
            if (items.count != totalCount) {
                //파일에서 읽어본 갯수와 totalCount가 다르면(변화가 있으면) 다시 읽어와서 저장
                getList(numOfRows: totalCount)
                saveDetail(url: url!)
            }
        } else {
            //******* 파일이 없으면
            getList(numOfRows: totalCount)
            saveDetail(url: url!)
        }
        
        tableView.reloadData()
    }
    
    func getList(numOfRows:Int) { //numOfRows를 입력
        //let str = detailEndPoint + "?serviceKey=\(servieKey)&numsofRows=100"
        let str = listEndPoint + "?serviceKey=\(servieKey)&numOfRows=5" //\(numOfRows)
        
        print(str)
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success")
                    //print(item)
                    
                } else {
                    print("parse fail")
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func getDetail(seq: String) {
        let str = detailEndPoint + "?serviceKey=\(servieKey)&seq=\(seq)"
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success")
                    //print(items)
                    
                } else {
                    print("parse fail")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let seq = items[indexPath.row]
        cell.textLabel?.text = seq["toiletName"]
        cell.detailTextLabel?.text = seq["type"]
        
        return cell
    }
    
    //*******새로 추가된 함수 - 목록데이터를 가지고 상세데이터를 가져와서 저장하는 함수
    // Detail Data 가져오는 부분을 saveDetail 메소드로 extract
    func saveDetail(url:URL) {
        let tempItems = items  // tableView에서 재활용
        
        items = []
        
        for dic in tempItems {
            // 상세 목록 파싱
            getDetail(seq: dic["seq"]!)
        }
        
        //print("After getDetail = \(items)")
        
        let temp = items as NSArray  // NSArry는 화일로 저장하기 위함
        temp.write(to: url, atomically: true)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //key = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        key = elementName
        if key == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
//        item[key] = string
        
//         foundCharacters가 두번 호출
        if item[key] == nil {
            item[key] = string.trimmingCharacters(in: .whitespaces)
            //print("****** \(item[key])")
            
            
            //*******key가 totalCount 이면 totalCount 변수에 저장
            if key == "totalCount" {
                totalCount = Int(string.trimmingCharacters(in: .whitespaces))!
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    

    
    
    
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    
            if segue.identifier == "goTotalMap" {
                let totalMVC = segue.destination as!
                    TotalMapViewController
                totalMVC.tItems = items
                
            } else if segue.identifier == "goSingle" {
                let singleMVC = segue.destination as! SingleMapViewController
                let selectedIndex = tableView.indexPathForSelectedRow
                singleMVC.sItem = items[(selectedIndex?.row)!]
                
            }
         }
    
}

