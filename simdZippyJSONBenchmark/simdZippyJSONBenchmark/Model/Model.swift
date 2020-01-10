//
//  Model.swift
//  CloneWeChat
//
//  Created by g on 2019/12/24.
//  Copyright © 2019 g. All rights reserved.
//

import Foundation
import UIKit
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)


/// 用户信息
public class User: Codable {
    let profileImage: String?
    let avatar: String?
    let nick, username: String?

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile-image"
        case avatar, nick, username
    }
   
}
    
public class Tweet: Codable {
    public let content: String?
    public let images: [Image]?
    public let sender: Sender?
    public let comments: [Comment]?
    public let error, unknownError: String?
    
    public var modelHeight: CGFloat = 0
    public var content_is_extend: Bool = false
    
    init(content: String? = nil,
          images: [Image]? = nil,
          sender: Sender? = nil,
        comments: [Comment]? = nil
    ) {
         self.content = content
         self.images = images
         self.sender = sender
         self.comments = comments
         self.error = nil
         self.unknownError = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case content, images, sender, comments, error
        case unknownError = "unknown error"
    }
    public func valid() -> Bool {
//            guard let _ = sender , content?.isEmpty == false , images?.isEmpty == false else { return false }
        guard let _ = sender , content?.isEmpty == false  else { return false }

        return true
    }
    public func setModelHeight(_ height:CGFloat) {
       modelHeight = height
    }
}

/// 评论
public class Comment: Codable {
    public let content: String?
    public let sender: Sender?
}

/// 发送者
public struct Sender: Codable {
    public let username, nick: String?
    public let avatar: String?
}

/// 图片
public struct Image: Codable {
    public let url: String?
}

public typealias Tweets = [Tweet]

