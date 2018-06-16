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
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
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

extension ViewController: MessagesDataSource {
    func currentSender() -> Sender {
        <#code#>
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        <#code#>
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        <#code#>
    }
}

extension ViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        <#code#>
    }
}

extension ViewController: MessagesDisplayDelegate {
    
}

extension ViewController: MessageCellDelegate {
    
}

extension ViewController: MessageLabelDelegate {
    
}

extension ViewController: MessageInputBarDelegate {
    
}

