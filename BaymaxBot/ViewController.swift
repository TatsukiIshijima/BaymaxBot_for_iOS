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
import Firebase
import UserNotifications

class ViewController: MessagesViewController, UNUserNotificationCenterDelegate {
    
    //var apiClient: ApiClient!
    //var userId: String?
    let userSender = Sender(id: "000000", displayName: "ユーザー")
    let baymaxSender = Sender(id: "111111", displayName: "ベイマックス")
    let userAvator = Avatar(image: UIImage(named: "img_default"), initials: "ユーザー")
    let baymaxAvator = Avatar(image: UIImage(named: "img_baymax"), initials: "ベイマックス")
    let defaultBlue = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
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
        
        // フォアグラウンドでの通知表示のため
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        self.navigationItem.title = "ベイマックス"
        let settingButton = UIBarButtonItem(title: "設定", style: .plain, target: self, action: #selector(tapSettingButton))
        self.navigationItem.setRightBarButton(settingButton, animated: true)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        makeInputBar()
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
    
    // フォアグラウンドで通知を受信時に呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        print(content.userInfo)
        completionHandler([.alert, .sound])
    }
    
    @objc func tapSettingButton() {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
    }
    
    // 入力バー作成
    func makeInputBar() {
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.layer.borderWidth = 0
        let items = [
            makeInputBarButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
            },
            makeInputBarButton(named: "ic_image").onSelected {
                $0.tintColor = self.defaultBlue
            },
            makeInputBarButton(named: "ic_voice").onSelected {
                $0.tintColor = self.defaultBlue
            },
            messageInputBar.sendButton
                .configure {
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: true)
                    $0.title = "送信"
                    $0.messageInputBar?.inputTextView.placeholderLabel.text = "Aa"
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .white
                }.onEnabled {
                    $0.backgroundColor = self.defaultBlue
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
                }
        ]
        items.forEach { $0.tintColor = .lightGray }
        
        // We can change the container insets if we want
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        // Since we moved the send button to the bottom stack lets set the right stack width to 0
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: true)
        
        // Finally set the items
        messageInputBar.setStackViewItems(items, forStack: .bottom, animated: true)
    }
    
    // 入力バー内のボタン作成
    func makeInputBarButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure{
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = self.defaultBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item tapped")
                // TODO:画像や音声認識の結果をmessageListに追加したらreload()すれば送信したこととなる？
            }
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
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: defaultBlue])
                let message = MessageModel(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, sentDate: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
        
        // 返信
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            // Dialogflow
            let request = ApiAI.shared().textRequest()
            if text != "" {
                request?.query = text
            }
            request?.setMappedCompletionBlockSuccess({ (request, response) in
                print("Success!")
                let response = response as? AIResponse
                if let textResponse = response?.result.fulfillment.messages {
                    let textResponseArray = textResponse[0] as NSDictionary
                    let replyMessage = MessageModel(text: textResponseArray.value(forKey: "speech") as! String, sender: self.baymaxSender, messageId: UUID().uuidString, sentDate: Date())
                    self.messageList.append(replyMessage)
                    self.messagesCollectionView.insertSections([self.messageList.count - 1])
                    self.messagesCollectionView.scrollToBottom()
                }
            }, failure: { (request, error) in
                print("Failure...")
            })
            ApiAI.shared().enqueue(request)
        })
        
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

