//
//  DDGDataCache.swift
//  DDGDataCache_Swift
//
//  Created by dudongge on 2018/5/25.
//  Copyright © 2018年 dudongge. All rights reserved.
//

import UIKit
/**
 *  注意: 使用前请在'-Bridging-Header.h' 桥接文件中导入 #import<CommonCrypto/CommonCrypto.h>
    因为要用到MD5加密的东西
 */
let DDGCacheKeyPath = "DDGCacheKeyPath"
extension DDGDataCache
{
    /**
     写入/更新缓存(同步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
     - parameter jsonResponse: 要写入的数据(JSON)
     - parameter URL:          数据请求URL
     - parameter path:         一级文件夹路径path（必须设置）
     - parameter subPath:      二级文件夹路径subPath（可设置-可不设置）
     - returns: 是否写入成功
     */
    public class func saveJsonResponseToCacheFile(_ jsonResponse: AnyObject,
                                                  URL: String,
                                                  path: String,
                                                  subPath: String = "") -> Bool {
        
        let data = jsonToData(jsonResponse)
        let atPath =  cacheFilePathWithURL(URL,
                                           path: path,
                                           subPath: subPath)
        return FileManager.default.createFile(atPath:atPath,
                                              contents: data,
                                              attributes: nil)
    }
    
    /**
     写入/更新缓存(异步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
     - parameter jsonResponse: 要写入的数据(JSON)
     - parameter URL:          数据请求URL
     - parameter subPath:      二级文件夹路径subPath（可设置-可不设置）
     - parameter completed:    异步完成回调(主线程回调)
     */
    public class func save_asyncJsonResponseToCacheFile(_ jsonResponse: AnyObject,
                                                        URL: String,
                                                        path: String ,
                                                        subPath: String = "",
                                                        completed:@escaping (Bool) -> ()) {
        
        DispatchQueue.global().async{
            let result = saveJsonResponseToCacheFile(jsonResponse,
                                                     URL: URL,
                                                     path: path,
                                                     subPath: subPath)
            DispatchQueue.main.async(execute: {
                completed(result)
            })
        }
    }
    
    /**
     获取缓存的对象(同步)
     - parameter URL: 数据请求URL
     - parameter subPath:      二级文件夹路径subPath（可设置-可不设置）
     - returns: 缓存对象
     */
    public class func cacheJsonWithURL(_ URL: String,subPath:String = "") -> AnyObject? {
        if let keyPath = UserDefaults.standard.string(forKey: DDGCacheKeyPath) {
            let path: String = self.cacheFilePathWithURL(URL, path: keyPath,subPath: subPath)
            let fileManager: FileManager = FileManager.default
            if fileManager.fileExists(atPath: path, isDirectory: nil) == true {
                let data: Data = fileManager.contents(atPath: path)!
                return self.dataToJson(data)
            }
        }
        return nil
    }
    
    /**
     获取总缓存路径
     - returns: 缓存路径
     - parameter subPath:      二级文件夹路径subPath（可设置-可不设置）
     */
    public class func cachePath() -> String {
        if let keyPath = UserDefaults.standard.string(forKey: DDGCacheKeyPath) {
            let pathOfLibrary = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
            let path = pathOfLibrary.appendingPathComponent(keyPath)
            return path
        } else {
            return ""
        }
    }
    /**
     获取子缓存路径
     - returns: 子缓存路径
     */
    public class func cacheSubPath(_ subPath: String = "") -> String {
        let path = self.cachePath() + "/" + subPath
        return path
    }
    /**
     清除全部缓存
     */
    public class func clearAllCache() -> Bool{
        let fileManager: FileManager = FileManager.default
        let path: String = self.cachePath()
        if path.count == 0 {
            return false
        }
        do
        {
            try fileManager.removeItem(atPath: path)
            self.checkDirectory(self.cachePath())
            return true
        }
        catch let error as NSError
        {
            print("clearCache failed , error = \(error)")
            return false
        }
    }
    /**
     清除制定文件夹下全部缓存
     */
    public class func clearCacheWithUrl(_ url: String) -> Bool{
        let fileManager: FileManager = FileManager.default
        let path: String = self.cacheSubPath(url)

        do
        {
            try fileManager.removeItem(atPath: path)
            self.checkDirectory(self.cacheSubPath(url))
            return true
        }
        catch let error as NSError
        {
            print("clearCache failed , error = \(error)")
            return false
        }
    }
    /**
     获取缓存大小
     - returns: 缓存大小(单位:M)
     */
    public class func cacheAllSize()-> Float {
        
        let cachePath = self.cachePath()
        do
        {
            let fileArr = try FileManager.default.contentsOfDirectory(atPath: cachePath)
            var size:Float = 0
            for file in fileArr{
                let path = cachePath + "/\(file)"
                let floder = try! FileManager.default.attributesOfItem(atPath: path)
                for (abc, bcd) in floder {
                    if abc == FileAttributeKey.size {
                        size += (bcd as AnyObject).floatValue
                    }
                }
            }
            let total = size / 1024.0 / 1024.0
            return total
        }
        catch
        {
            return 0;
        }
    }
    /**
     获取单个文件夹下缓存大小
     - returns: 子缓存大小(单位:M)
     */
    public class func cacheSizeWithUrl(_ Url: String)-> Float {
        
        let cachePath = self.cacheSubPath(Url)
        do
        {
            let fileArr = try FileManager.default.contentsOfDirectory(atPath: cachePath)
            var size:Float = 0
            for file in fileArr{
                let path = cachePath + "/\(file)"
                let floder = try! FileManager.default.attributesOfItem(atPath: path)
                for (abc, bcd) in floder {
                    if abc == FileAttributeKey.size {
                        size += (bcd as AnyObject).floatValue
                    }
                }
            }
            let total = size / 1024.0 / 1024.0
            return total
        }
        catch
        {
            return 0;
        }
    }
}

open class DDGDataCache {
    //MARK: - private
    fileprivate class func jsonToData(_ jsonResponse: AnyObject) -> Data? {
        do{
            let data = try JSONSerialization.data(withJSONObject: jsonResponse, options: JSONSerialization.WritingOptions.prettyPrinted)
            return data;
            
        }catch
        {
            return nil
        }
    }
    
    fileprivate class func dataToJson(_ data: Data) -> AnyObject? {
        
        do{
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            return json as AnyObject?
            
        }
        catch
        {
            return nil
        }
    }
    
    fileprivate class func cacheFilePathWithURL(_ URL: String,
                                                path: String ,
                                                subPath:String = "") -> String {
        
        var newPath: String = ""
        if subPath.count == 0 {
            //保存最新的一级目录
            UserDefaults.standard.set(path, forKey: DDGCacheKeyPath)
            UserDefaults.standard.synchronize()
            newPath = self.cachePath()
        } else {
            newPath = self.cacheSubPath(subPath)
        }
        self.checkDirectory(newPath)
        //check路径
        let cacheFileNameString: String = "URL:\(URL) AppVersion:\(self.appVersionString())"
        let cacheFileName: String = self.md5StringFromString(cacheFileNameString)
        newPath = newPath + "/" + cacheFileName
        return newPath
    }
    
    fileprivate class func checkDirectory(_ path: String) {
        let fileManager: FileManager = FileManager.default
        
        var isDir = ObjCBool(false) //isDir判断是否为文件夹
        
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            
            self.createBaseDirectoryAtPath(path)
            
        } else {
            if !isDir.boolValue {
                
                do
                {
                    try fileManager.removeItem(atPath: path)
                    self.createBaseDirectoryAtPath(path)
                }
                catch let error as NSError
                {
                    print("create cache directory failed, error = %@", error)
                }
            }
        }
    }
    
    fileprivate class func createBaseDirectoryAtPath(_ path: String) {
        do
        {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            print("path ="+path)
            self.addDoNotBackupAttribute(path)
        }
        catch let error as NSError
        {
            print("create cache directory failed, error = %@", error)
        }
    }
    
    fileprivate class func addDoNotBackupAttribute(_ path: String) {
        let url: URL = URL(fileURLWithPath: path)
        do
        {
            try  (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        }
        catch let error as NSError
        {
            print("error to set do not backup attribute, error = %@", error)
        }
    }
    
    fileprivate class func md5StringFromString(_ string: String) -> String {
        let str = string.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        
        CC_MD5(str!, strLen, result);
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        return String(format: hash as String)
    }
    
    fileprivate class func appVersionString() -> String {
        
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
}



