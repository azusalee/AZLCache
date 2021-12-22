//
//  AZLDoubleLinkListNode.swift
//  AZLCache
//
//  Created by lizihong on 2021/10/13.
//

import Foundation

/*
双向链表节点
使用时要注意前后节点互相引用，导致循环引用的问题(需要自己手动设置nil来解决)
*/ 
public class AZLDoubleLinkListNode<T: Any>: NSObject {
    /// key
    public var key: String?
    /// 缓存值
    public var value: T?
    /// 上一个节点
    public var preNode: AZLDoubleLinkListNode<T>?
    /// 下一个节点
    public var nextNode: AZLDoubleLinkListNode<T>?
}
