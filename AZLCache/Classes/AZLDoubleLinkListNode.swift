//
//  AZLDoubleLinkListNode.swift
//  AZLCache
//
//  Created by lizihong on 2021/10/13.
//

import Foundation

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
