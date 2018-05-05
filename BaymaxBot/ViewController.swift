//
//  ViewController.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/28.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {

    var messages: [JSQMessage]?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    var apiClient: ApiClient!
    var userId: UserId?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自身のsenderId, senderDisplayNameの設定
        self.senderId = "user1"
        self.senderDisplayName = "sample"
        
        // 吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        // アバターの設定 TODO：画像の用意
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "img_baymax"), diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "img_default"), diameter: 64)
        
        // メッセージデータの初期化
        self.messages = []
        
        self.apiClient = ApiClient()
        self.apiClient.replAiInitRequestRx().subscribe(onNext: { (userId) in
            self.userId = userId
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("Init Completed!!")
        })
        //self.apiClient.replAiInitRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // sendボタン押下
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // 新しいメッセージデータを追加
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages?.append(message!)
        
        // メッセージの送信完了
        self.finishReceivingMessage(animated: true)
        
        self.apiClient.weatherRequestRx(cityCode: "140010").subscribe(onNext: { (weatherModel) in
            self.receiveAutoMessage(text: (weatherModel.description?.text)!)
        }, onError: { (error) in
            print(error)
        }, onCompleted:{
            print("WeatherRequest Completed!!")
        })
    }
    
    // 添付ボタン押下
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    // アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages![indexPath.item]
    }
    
    // アイテムごとの背景を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = self.messages![indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // アイテムごとのアバターを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = self.messages![indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    // アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    // 返信メッセージを受信する
    func receiveAutoMessage(text: String) {
        let userInfo = text
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didFinishMessageTimer), userInfo: userInfo, repeats: false)
    }
    
    @objc func didFinishMessageTimer(sender: Timer) {
        let text = sender.userInfo as! String
        let message = JSQMessage(senderId: "user2", displayName: "sample2", text: text)
        self.messages?.append(message!)
        self.finishReceivingMessage(animated: true)
    }
    
}

