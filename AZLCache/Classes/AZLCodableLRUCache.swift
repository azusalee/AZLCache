//
//  AZLCodableLRUCache.swift
//  AZLCache
//
//  Created by lizihong on 2021/10/14.
//

import UIKit

public class AZLCodableLRUCache<T: Codable>: AZLLRUCache<T>, AZLCodableDiskCacheProtocol {
    public typealias CacheObject = AZLCodableLRUCache<T>
    
    /// 归档
    private enum CodingKeys: String, CodingKey {
        case keyValueDict
        case keyArray
    }
    
    public override init() {
        super.init()
    }
    
    /// Codable 的协议 由系统调用 解档
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
    
    /// Codable 的协议 由系统调用 归档
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        /// 双向链表无法存为json(由于互相引用)，转为数组和字典
        try container.encode(self.keyValueDict(), forKey: .keyValueDict)
        try container.encode(self.allKey(), forKey: .keyArray)
    }
    
}
