//
//  AZLDiskCacheProtocol.swift
//  AZLCache
//
//  Created by lizihong on 2021/10/14.
//

import Foundation

/// 磁盘缓存协议
public protocol AZLDiskCacheProtocol {
    /// 缓存对象类型
    associatedtype CacheObject
    
    /// 缓存到硬盘
    func saveCacheToDisk(path: String)
    
    /// 从硬盘读取缓存
    static func loadCacheFromDisk(path: String) -> CacheObject?
}

/// 符合codable的磁盘缓存协议
public protocol AZLCodableDiskCacheProtocol: AZLDiskCacheProtocol, Codable where CacheObject: Codable {
    
}

/// 默认符合codable磁盘写入读取方法
public extension AZLCodableDiskCacheProtocol {
    /// 缓存到硬盘
    func saveCacheToDisk(path: String) {
        // 转成data数据，再写入磁盘
        let data = try? JSONEncoder().encode(self)
        try? data?.write(to: URL.init(fileURLWithPath: path), options: [.atomic])
    }
    
    /// 从硬盘读取缓存
    static func loadCacheFromDisk(path: String) -> CacheObject? {
        // 读取磁盘data数据
        if let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) {
            // 把数据转成对象
            if let obj = try? JSONDecoder().decode(CacheObject.self, from: data) {
                return obj
            }
        }
        return nil
    }
}
