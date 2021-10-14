//
//  AZLLRUCache.swift
//  AZLCache
//
//  Created by lizihong on 2021/10/13.
//

import Foundation

public class AZLLRUCache<T: Any>: NSObject {
    /// 缓存字典
    internal var cacheDict: [String: AZLDoubleLinkListNode<T>] = [:]
    /// 链头
    internal var listHead: AZLDoubleLinkListNode<T>?
    /// 链尾
    internal var listTail: AZLDoubleLinkListNode<T>?
    
    /// 是否自动清理缓存(如果设置为false，maxCacheCount会没有作用，需要外部自己掌控清理时机)
    public var isAutoClear: Bool = true
    /// 最大缓存数量
    public var maxCacheCount: Int = 500
    
    deinit {
        /// 清除全部缓存(双向链表会互相引用，arc清理不了，要手动清理引用)
        self.clearAllCache()
    }
    
    /// 移到链头
    private func moveToHead(node: AZLDoubleLinkListNode<T>) {
        if node == self.listHead {
            // 自己就是头部，不用处理
            return
        }
        let prev = node.preNode
        let next = node.nextNode
        
        prev?.nextNode = next
        next?.preNode = prev
        
        /// 当前为末尾节点且前一个节点不为空，把前一个节点设为末尾节点
        if node == self.listTail && prev != nil {
            self.listTail = prev
        }
        
        if self.listHead != nil {
            node.nextNode = self.listHead
            self.listHead?.preNode = node
        } else {
            node.nextNode = nil
        }
        node.preNode = nil
        /// 把当前节点设为头部
        self.listHead = node
    }
    
    /// 存值
    public func storeCache(key: String, value: T) {
        if let cacheValue = self.cacheDict[key] {
            self.moveToHead(node: cacheValue)
            cacheValue.value = value
        } else {
            /// 原来没有该节点，新建节点
            let cacheValue = AZLDoubleLinkListNode<T>()
            cacheValue.key = key
            cacheValue.value = value
            cacheValue.nextNode = self.listHead
            self.listHead?.preNode = cacheValue
            
            self.listHead = cacheValue
            self.cacheDict[key] = cacheValue
            if self.listTail == nil {
                self.listTail = cacheValue
            }
            if self.isAutoClear && cacheDict.count >= self.maxCacheCount {
                self.autoClearCache()
            }
        }
    }
    
    /// 获取第一个值
    public func firstCache() -> T? {
        return self.listHead?.value
    }
    
    /// 获取最后一个值
    public func lastCache() -> T? {
        return self.listTail?.value
    }
    
    /// 第一个key
    public func firstKey() -> String? {
        return self.listHead?.key
    }
    
    /// 最后一个key
    public func lastKey() -> String? {
        return self.listTail?.key
    }
    
    /// 取值
    public func getCache(key: String, needMoveHead: Bool = true) -> T? {
        if let cacheValue = self.cacheDict[key] {
            if needMoveHead {
                self.moveToHead(node: cacheValue)
            }
            return cacheValue.value
        }
        return nil
    }
    
    /// 移除指定值
    public func removeCache(key: String) {
        if let node = self.cacheDict[key] {
            let prev = node.preNode
            let next = node.nextNode
            
            prev?.nextNode = next
            next?.preNode = prev
            
            if node == self.listHead {
                self.listHead = next
            }
            if node == self.listTail {
                self.listTail = prev
            }
            node.preNode = nil
            node.nextNode = nil
            self.cacheDict.removeValue(forKey: key)
        }
    }
    
    /// 当缓存数量达到指定值，清除一部分缓存
    private func autoClearCache() {
        var clearCount = Int(Double(self.maxCacheCount)*0.5)
        var tailNode = self.listTail
        while clearCount > 0 && tailNode != nil {
            tailNode?.nextNode = nil
            self.cacheDict.removeValue(forKey: tailNode?.key ?? "")
            let prev = tailNode?.preNode
            tailNode?.preNode = nil
            tailNode = prev
            clearCount -= 1
        }
        tailNode?.nextNode = nil
        self.listTail = tailNode
    }
    
    /// 清空全部缓存
    public func clearAllCache() {
        /// 清除双向链表
        var node = self.listHead
        while node != nil {
            node?.preNode = nil
            let nextNode = node?.nextNode
            node?.nextNode = nil
            node = nextNode
        }
        self.cacheDict.removeAll()
        self.listHead = nil
        self.listTail = nil
        
    }
    
    /// 全部缓存(全部value)
    public func allCache() -> [T] {
        var node = self.listHead
        var array: [T] = []
        while node != nil {
            if let value = node?.value {
                array.append(value)
            }
            node = node?.nextNode
        }
        return array
    }
    
    /// 全部Key
    public func allKey() -> [String] {
        var node = self.listHead
        var array: [String] = []
        while node != nil {
            if let key = node?.key {
                array.append(key)
            }
            node = node?.nextNode
        }
        return array
    }
    
    /// 全部keyValue
    public func keyValueDict() -> [String: T] {
        var keyValueDict: [String: T] = [:]
        for (key, cache) in self.cacheDict {
            keyValueDict[key] = cache.value
        }
        return keyValueDict
    }
    
    /// 数量
    public func count() -> Int {
        return self.cacheDict.count
    }
    
}
