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
import RxSwift

class ViewController: MessagesViewController {
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let userSender = Sender(id: "000000", displayName: "ユーザー")
    let baymaxSender = Sender(id: "111111", displayName: "ベイマックス")
    let userAvator = Avatar(image: UIImage(named: "img_default"), initials: "ユーザー")
    let baymaxAvator = Avatar(image: UIImage(named: "img_baymax"), initials: "ベイマックス")
    let defaultBlue = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
    var messageList: [MessageModel] = []
    
    let sendImageEventSubject = PublishSubject<UIImage>()
    var sendImageEvent: Observable<UIImage> { return sendImageEventSubject }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        receivedImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sendImageEventSubject.dispose()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 入力バー作成
    func makeInputBar() {
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.layer.borderWidth = 0
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let items = [
            makeInputBarButton(named: "ic_camera")
                .onTextViewDidChange { button, textView in
                    button.isEnabled = textView.text.isEmpty
                }.onTouchUpInside { _ in
                    print("Tapped Camera")
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        print("Use Camera")
                        // カメラ起動
                        imagePickerController.sourceType = .camera
                        self.present(imagePickerController, animated: true, completion: nil)
                    }
                },
            makeInputBarButton(named: "ic_image")
                .onTouchUpInside { _ in
                    print("Tapped Image")
                    // カメラロール起動
                    imagePickerController.sourceType = .photoLibrary
                    self.present(imagePickerController, animated: true, completion: nil)
                },
            makeInputBarButton(named: "ic_voice")
                .onTouchUpInside { _ in
                    print("Tapped Voice")
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
            }
    }
    
    // 返信
    func replyMessage(replyText: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let replyMessage = MessageModel(text: replyText, sender: self.baymaxSender, messageId: UUID().uuidString, sentDate: Date())
            self.messageList.append(replyMessage)
            self.messagesCollectionView.insertSections([self.messageList.count - 1])
            self.messagesCollectionView.scrollToBottom()
        })
    }
    
    // Dialogflowによる返信
    func replyMessageByDialogflow(inputText: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            // Dialogflow
            let request = ApiAI.shared().textRequest()
            if !inputText.isEmpty {
                request?.query = inputText
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
    }
    
    // 画像送信
    func sendImage(image: UIImage) {
        let messageImage = MessageModel(image: image, sender: self.currentSender(), messageId: UUID().uuidString, sentDate: Date())
        self.messageList.append(messageImage)
        self.messagesCollectionView.insertSections([self.messageList.count - 1])
        self.messagesCollectionView.scrollToBottom()
        self.sendImageEventSubject.onNext(image)
    }
    
    // 画像受信
    func receivedImage() {
        // 閾値を設定
        let options = VisionLabelDetectorOptions(confidenceThreshold: 0.5)
        let vision = Vision.vision()
        let labelDetector = vision.labelDetector(options: options)
        // 画像認識結果をテキストで返す
        self.sendImageEventSubject.subscribe(onNext: { image in
            let visionImage = VisionImage(image: image)
            labelDetector.detect(in: visionImage) { features, error in
                guard error == nil, let features = features, !features.isEmpty else {
                    return
                }
                for feature in features {
                    let labelText = feature.label
                    let entityId = feature.entityID
                    let confidence = feature.confidence
                    print("Label : \(labelText)   Entity ID : \(entityId)  Confidence : \(confidence)")
                    if confidence >= 0.75 {
                        self.replyMessage(replyText: "これは '\(labelText)' ですね。")
                        break
                    } else {
                        self.replyMessage(replyText: "すみません。ちょっとよくわかりませんでした…")
                        break
                    }
                }
            }
        }, onError: { error in
            print("ReceivedImage Error: \(error)")
        }, onCompleted: {
            
        })
    }
}

// 送信元、メッセージ、日付などのデータ作成
extension ViewController: MessagesDataSource {
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messageList.count
    }
    
    func currentSender() -> Sender {
        return self.userSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messageList[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messageList.count
    }
    
    // メッセージ上のテキスト
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // メッセージ下のテキスト
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
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
    
    // 吹き出しをつける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

extension ViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 10
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ViewController: MessageCellDelegate {
    
}

extension ViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        print("didPressSendButton : \(text)")
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let message = MessageModel(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, sentDate: Date())
        messageList.append(message)
        messagesCollectionView.insertSections([messageList.count - 1])
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
        
        self.replyMessageByDialogflow(inputText: text)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // キャンセル時
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Choose image cancel.")
        self.dismiss(animated: true)
    }
    
    // 写真選択時 or 写真撮影時
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Choose image from Garally.")
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard let image = pickedImage else { return }
        self.sendImage(image: image)
        self.dismiss(animated: true)
    }
}

