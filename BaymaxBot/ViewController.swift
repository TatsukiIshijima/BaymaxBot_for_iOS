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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

        
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
}

extension ViewController: MessagesDisplayDelegate {
    
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
    }
}

