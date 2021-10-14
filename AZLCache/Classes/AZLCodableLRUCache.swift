//
//  AZLCodableLRUCache.swift
//  AZLCache
//
//  Created by lizihong on 2021/10/14.
//

import UIKit

public class AZLCodableLRUCache<T: Codable>: AZLLRUCache<T>, Codable, AZLDiskCacheProtocol {
    
    /// 归档
    private enum CodingKeys: String, CodingKey {
        case keyValueDict
        case keyArray
    }
    
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let keyValueDict = try container.decode([String: T].self, forKey: .keyValueDict)
        let keyArray = try container.decode([String].self, forKey: .keyArray)
        /// 根据Key的顺序，重新生成双向链表
        var preNode: AZLDoubleLinkListNode<T>?
        for key in keyArray {
            if let value = keyValueDict[key] {
                let node = AZLDoubleLinkListNode<T>()
                node.key = key
                node.value = value
                preNode?.nextNode = node
                node.preNode = preNode
                preNode = node
                self.cacheDict[key] = node
                if self.listHead == nil {
                    self.listHead = node
                }
            }
        }
        self.listTail = preNode
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        /// 双向链表无法存为json(由于互相引用)，转为数组和字典
        try container.encode(self.keyValueDict(), forKey: .keyValueDict)
        try container.encode(self.allKey(), forKey: .keyArray)
    }
    
    /// 缓存到硬盘
    public func saveCacheToDisk(path: String) {
        let data = try? JSONEncoder().encode(self)
        try? data?.write(to: URL.init(fileURLWithPath: path))
        
    }
    
    /// 从硬盘读取缓存
    public static func loadCacheFromDisk(path: String) -> AZLCodableLRUCache<T>? {
        if let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) {
            if let obj = try? JSONDecoder().decode(AZLCodableLRUCache<T>.self, from: data) {
                return obj
            }
        }
        return nil
    }
}
