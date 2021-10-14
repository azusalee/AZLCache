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
    static func loadCacheFromDisk(path: String) -> CacheObject
}
