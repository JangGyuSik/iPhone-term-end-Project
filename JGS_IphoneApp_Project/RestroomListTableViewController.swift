//
//  RestroomListTableViewController.swift
//  JGS_IphoneApp_Project
//
//  Created by D7702_10 on 2017. 11. 14..
//  Copyright © 2017년 DoubleK. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, XMLParserDelegate {
    
    let listEndPoint = "http://opendata.busan.go.kr/openapi/service/PublicToilet/getToiletInfoList"
    let detailEndPoint = "http://opendata.busan.go.kr/openapi/service/PublicToilet/getToiletInfoDetail"
    let serviceKey = "nsGYsnRIMYDW2RwmA8hMBTGFXYN6LyB4rJC71IIGNVGIplpzE3iahHPLqCU4BnTjhOGT4b%2FgbTLg3vfGFtIffQ%3D%3D"
    var item:[String:String] = [:] //ket:velue
    var items:[[String:String]] = []
    var key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("로딩중")
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.plist")
        
        if fileManager.fileExists(atPath: url!.path){
            items = NSArray(contentsOf: url!) as! Array //파일이 있을경우 파일 읽어오기
        } else { //파일이 없을경우
            getList()
            let tempList = items //목록
            items = []
            for tempItem in tempList{
                getDetail(seq: tempItem["seq"]!)
            }
            print(items)
            let temp = items as NSArray
            temp.write(to: url!, atomically: true)
        }
        
        tableView.reloadData()
        print("완료")
    }
    
    func getList(){
        let str = listEndPoint + "?servicekey=\(serviceKey)&numOfRows=100"
        if let url = URL(string: str){
            //parser
            if let parser = XMLParser(contentsOf: url){
                parser.delegate = self
                let isSuccess = parser.parse()
                if isSuccess{
                    print("성공")
                } else {
                    print("실패")
                }
            }
        }
    }
    
    func getDetail(seq:String){
        let str = detailEndPoint + "?servicekey=\(serviceKey)&seq=\(seq)"
        if let url = URL(string: str){
            //parser
            if let parser = XMLParser(contentsOf: url){
                parser.delegate = self
                let isSuccess = parser.parse()
                if isSuccess{
                    print("성공")
                } else {
                    print("실패")
                }
            }
        }
    }
    
    
    //메소드 추가
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        key = elementName // key를 저장
        if key == "item" { // item이 시작될때 새로운 딕셔너리 생성
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("key: \(key) value : \(string)")
        if item[key] == nil {
            item[key] = string.trimmingCharacters(in: .whitespaces) // 딕셔너리에 저장, 공백 처리
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item"{ //끝날때 item일 경우 item을 배열(items)안에 저장
            items.append(item)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dic = items[indexPath.row]
        cell.textLabel?.text = dic["instName"]
        
        return cell
    }
}
