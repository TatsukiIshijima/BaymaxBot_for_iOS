//
//  ViewController.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/28.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import UIKit
import MessageKit
import ApiAI

class ViewController: MessagesViewController {
    
    //var apiClient: ApiClient!
    //var userId: String?
    let userSender = Sender(id: "000000", displayName: "ユーザー")
    let baymaxSender = Sender(id: "111111", displayName: "ベイマックス")
    let userAvator = Avatar(image: UIImage(named: "img_default"), initials: "ユーザー")
    let baymaxAvator = Avatar(image: UIImage(named: "img_baymax"), initials: "ベイマックス")
    var messageList: [MessageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* ReplAI APIの初期化
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
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.messageList.append(MessageModel.init(text: "こんにちは。わたしはベイマックス。あなたの健康を守ります。", sender: self.baymaxSender, messageId: UUID().uuidString, sentDate: Date()))
                self.messagesCollectionView.insertSections([self.messageList.count - 1])
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

// 送信元、メッセージ、日付などのデータ作成
extension ViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return self.userSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messageList[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messageList.count
    }
    
    // メッセージ下のテキスト
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.darkGray])
    }
}

extension ViewController: MessagesDisplayDelegate {
    
    // 背景色
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            return UIColor.lightGray
        }
        return dataSource.isFromCurrentSender(message: message) ? UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0) : UIColor.lightGray
    }
    
    // テキストカラー
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor.white
    }
    
    // アバターの設定
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.sender {
            case userSender:
                avatarView.set(avatar: userAvator)
                break
            case baymaxSender:
                avatarView.set(avatar: baymaxAvator)
                break
            default:
                break
        }
    }
    
    // メッセージ下のラベル位置調整
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError()
        }
        // 自分とそれ以外のユーザーでラベルの位置を調整
        return dataSource.isFromCurrentSender(message: message) ? .messageTrailing(.zero) : .messageLeading(.zero)
    }
}

extension ViewController: MessagesLayoutDelegate {
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 240
    }
}

extension ViewController: MessageCellDelegate {
    
}

extension ViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                let imageMessage = MessageModel(image: image, sender: currentSender(), messageId: UUID().uuidString, sentDate: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
            } else if let text = component as? String {
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                let message = MessageModel(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, sentDate: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
        
        /* Dialogflow */
        /*
         let request = ApiAI.shared().textRequest()
         if text != "" {
         request?.query = text
         } else {
         return
         }
         request?.setMappedCompletionBlockSuccess( { (request, response) in
         print("Success!")
         let response = response as? AIResponse
         if let textResponse = response?.result.fulfillment.messages {
         let textResponseArray = textResponse[0] as NSDictionary
         self.receiveAutoMessage(text: textResponseArray.value(forKey: "speech") as! String)
         }
         }, failure: { (request, error) in
         print(error)
         })
         ApiAI.shared().enqueue(request)
         */
        /* ----------- */
        
        /* ReplAIの対話API実行
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
}

