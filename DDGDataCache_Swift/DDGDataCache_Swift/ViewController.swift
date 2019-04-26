//
//  ViewController.swift
//  DDGDataCache_Swift
//
//  Created by dudongge on 2018/5/25.
//  Copyright © 2018年 dudongge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tabelView = UITableView()
        tabelView.frame = CGRect(x: 10, y: 80, width:self.view.frame.size.width - 20 , height: self.view.frame.size.height - 280)
        tabelView.delegate = self
        tabelView.dataSource = self
        tabelView.backgroundColor = UIColor.yellow
        self.view.addSubview(tabelView)
        return tabelView
    }()
    var bottomLabel = UILabel()
    let dataSource = ["😜同步写入/更新缓存(只有主目录)",
                      "📷同步写入/更新缓存(有二级目录)",
                      "🐥异步写入/更新缓存（只有主目录）",
                      "🍌异步写入/更新缓存（有二级目录）",
                      "🐒获取全部缓存数据（主目录）",
                      "🌧获取指定缓存数据（二级目录）",
                      "🌞获取全部缓存大小",
                      "🌛获取指定缓存大小",
                      "🚚获取主缓存路径",
                      "🚄获取指定缓存路径",
                      "🍓清除全部缓存",
                      "🍎清除指定缓存"]
    //构建模拟数据
    /**
     *  模拟数据请求URL
     */
    let URLString = "https://github.com/dudongge"
    let URLString1 = "https://github.com/dudongge/DDGScreenShot"
    let URLString2 = "https://github.com/dudongge/DDGMeiTuan"
    let URLString3 = "https://github.com/dudongge/DGKVO"
    
    /**
     *  模拟服务器请求数据
     */
    let responseObject = [ "sex" : "男",
                           "city" : "上海",
                           "logintime" : "1445267749",
                           "name" : "东阁堂主",
                           "group" : "3",
                           "loginhit" : "4",
                           "id" : "234328",
                           "QQ" : "532835032" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.text = "DDGDataCache的用法介绍"
        titleLabel.textColor = UIColor.red
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 10, y: 50, width: self.view.frame.size.width - 20, height: 40)
        self.view.addSubview(titleLabel)
        
        
        self.tableView.reloadData()
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        bottomLabel.text = "打印控制台信息"
        bottomLabel.textColor = UIColor.red
        bottomLabel.textAlignment = .center
        bottomLabel.numberOfLines = 0
        bottomLabel.frame = CGRect(x: 10, y: self.tableView.frame.origin.y + self.tableView.frame.size.height , width: self.view.frame.size.width - 20, height: 200)
        self.view.addSubview(bottomLabel)
        bottomLabel.backgroundColor = UIColor.green
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //同步写入
            if DDGDataCache.saveJsonResponseToCacheFile(self.responseObject as AnyObject,
                                                        URL: self.URLString,
                                                        path: "appCache") {
                let logStr = "😆(同步写入主目录)保存/更新成功"
                self.showLogs(logStr)
            } else {
                let logStr = "😤(同步写入主目录)保存/更新失败"
                self.showLogs(logStr)
            }
        case 1:
            //同步写入--有二级目录
            if DDGDataCache.saveJsonResponseToCacheFile(self.responseObject as AnyObject,
                                                        URL: self.URLString1,
                                                        path: "appCache",
                                                        subPath: "userInfo") {
                let logStr = "😆(同步二级目录)保存/更新成功"
                self.showLogs(logStr)
            } else {
                let logStr = "😤(同步二级目录)保存/更新失败"
                self.showLogs(logStr)
            }
        case 2:
            DDGDataCache.save_asyncJsonResponseToCacheFile(self.responseObject as AnyObject,
                                                           URL: self.URLString2,
                                                           path: "appCache") { (succ) in
                                                            if  succ {
                                                                self.showLogs("😆(异步写入主目录)保存/更新成功")
                                                            } else {
                                                                self.showLogs("😤(异步写入主目录)保存/更新失败")
                                                            }
            }
        case 3:
            DDGDataCache.save_asyncJsonResponseToCacheFile(self.responseObject as AnyObject,
                                                           URL: self.URLString3,
                                                           path: "appCache",
                                                           subPath: "userInfo") { (succ) in
                                                            if  succ {
                                                                self.showLogs("😆(异步写入二级目录)保存/更新成功")
                                                            } else {
                                                                self.showLogs("😤(异步写入二级目录)保存/更新失败")
                                                            }
            }
        case 4:
            //获取全部缓存
            if let json = DDGDataCache.cacheJsonWithURL(URLString)  {
                self.showLogs(json.description)
                print(json.description ?? "")
            }
        case 5:
            //获取指定缓存数据
            if let json = DDGDataCache.cacheJsonWithURL(URLString,subPath: "userInfo")  {
                self.showLogs(json.description)
                print(json)
            }
        //print("缓存大小(M)=\(cacheSize)")
        case 6:
            //获取全部缓存大小
            let allSize =  DDGDataCache.cacheAllSize()
            let size =  String(format: "%.6f", allSize)
            self.showLogs("缓存大小(M)=\(size)")
            
        case 7:
            //获取指定缓存大小
            let allSize =  DDGDataCache.cacheSizeWithUrl("userInfo")
            self.showLogs("缓存大小(M)=\(allSize)")
        case 8:
            //获取总的缓存路径
            let cachePath = DDGDataCache.cachePath()
            self.showLogs("缓存路径=" + cachePath)
        case 9:
            //获取指定缓存路径
            let cacheSubpath = DDGDataCache.cacheSubPath("userInfo")
            self.showLogs("缓存路径=" + cacheSubpath)
            
        case 10:
            //清除全部缓存
            if DDGDataCache.clearAllCache() {
                self.showLogs("😆清除缓存成功")
            } else {
                self.showLogs("😤清除缓存失败")
            }
            
        case 11:
            //清除指定缓存
            if DDGDataCache.clearCacheWithUrl("userInfo") {
                self.showLogs("😆清除缓存成功")
            } else {
                self.showLogs("😤清除缓存失败")
            }
            print( #function)
        default:
            break
        }
    }
    func showLogs(_ log: String) {
        print(log)
        bottomLabel.text = log
    }
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DDGDataCacheId")
        cell.textLabel?.text = self.dataSource[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
}
extension ViewController {
    
}
