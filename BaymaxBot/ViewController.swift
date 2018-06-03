//
//  ViewController.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/28.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class ViewController: JSQMessagesViewController {

    var messages: [JSQMessage]?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    var apiClient: ApiClient!
    var userId: String?
    
    var refTV: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebase Databaseの設定
        refTV = Database.database().reference().child("TV")
        
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
        
        self.receiveAutoMessage(text: "こんにちは。わたしはベイマックス。あなたの健康を守ります。")
        
        // ReplAI APIの初期化
        /*
        self.apiClient = ApiClient()
        self.apiClient.replAiInitRequestRx().subscribe(onNext: { (userId) in
            self.userId = userId.userId
            self.apiClient.replAiTalkRequestRx(appUserId: userId.userId!, voiceText: "init", initFlag: true).subscribe(onNext: { (replModel) in
                self.receiveAutoMessage(text: (replModel.systemText?.expression)!)
            })
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("Init Completed!!")
        })
        */
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
        
        if text == "テレビをつけて" {
            // 同じデータを送信すると更新されないのでDBのデータを読み込み、反対のデータを送信する
            self.refTV.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let tvFlag: Bool = (snapshot.value as? Bool)!
                self.refTV.setValue(!tvFlag)
            })
            self.receiveAutoMessage(text: "はい、テレビをつけますね。")
        } else {
            self.receiveAutoMessage(text: "すみません、わかりません。")
        }
        
        
        /*
        // ReplAIの対話API実行
        guard let userId = self.userId else {
            return
        }
        self.apiClient.replAiTalkRequestRx(appUserId: userId, voiceText: text, initFlag: false).subscribe(onNext: { (replModel) in
            self.receiveAutoMessage(text: (replModel.systemText?.expression)!)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("ReplAITalkRequest Completed!!")
        })
         */
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

