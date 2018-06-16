//
//  MessageModel.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/06/16.
//  Copyright © 2018年 石島樹. All rights reserved.
//  チャットで使用するメッセージの種類

import Foundation
import CoreLocation
import MessageKit

public struct MessageModel: MessageType {
    
    public var sender: Sender
    public var messageId: String
    public var sentDate: Date
    public var data: MessageData
    
    private init(sender: Sender, messageId: String, sentDate: Date, data: MessageData) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.data = data
    }
    
    init(text :String, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, data: .text(text))
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, data: .attributedText(attributedText))
    }
    
    // 絵文字
    init(emoji: String, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, data: .emoji(emoji))
    }
    
    // 画像
    init(image: UIImage, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, data: .photo(image))
    }
    
    // 動画
    init(thumbnail: UIImage, videoUrl: URL, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, data: .video(file: videoUrl, thumbnail: thumbnail))
    }
    
    // 位置情報
    init(location: CLLocation, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, data: .location(location))
    }
}
