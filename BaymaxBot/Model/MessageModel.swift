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

private struct LocationItemModel: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

private struct MediaItemModel: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

public struct MessageModel: MessageType {
    
    public var kind: MessageKind
    public var sender: Sender
    public var messageId: String
    public var sentDate: Date
    
    private init(sender: Sender, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
    init(text :String, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(text))
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .attributedText(attributedText))
    }
    
    // 絵文字
    init(emoji: String, sender: Sender, messageId: String, sentDate: Date) {
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .emoji(emoji))
    }
    
    // 画像
    init(image: UIImage, sender: Sender, messageId: String, sentDate: Date) {
        let mediaItem = MediaItemModel(image: image)
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .photo(mediaItem))
    }
    
    // 動画
    init(thumbnail: UIImage, videoUrl: URL, sender: Sender, messageId: String, sentDate: Date) {
        let mediaItem = MediaItemModel(image: thumbnail)
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .video(mediaItem))
    }
    
    // 位置情報
    init(location: CLLocation, sender: Sender, messageId: String, sentDate: Date) {
        let locationItem = LocationItemModel(location: location)
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .location(locationItem))
    }
}
