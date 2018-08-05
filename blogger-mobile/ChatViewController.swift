//
//  ChatViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/22/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SocketIO
import SwiftSoup

class ChatViewController: JSQMessagesViewController {
    
    var user: User? = nil
    var friend: Friend? = nil
    var manager: SocketManager! = nil
    var socket: SocketIOClient! = nil
    var messages = [JSQMessage]()
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
    }()
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if (user != nil && friend != nil) {
            self.socket.emit("message", ["from": user!.username, "fromid": user!.user_id, "to": friend!.username, "toid": friend!.user_id, "content": text, "type": "text" ])
            if let message = JSQMessage(senderId: String(self.user!.user_id), displayName: self.user!.username, text: text) {
                self.messages.append(message)
                self.finishSendingMessage()
            }
            
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if let user = self.user {
            return messages[indexPath.item].senderId == senderId ? NSAttributedString(string: user.username) : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func parseImage(_ message: String) -> JSQPhotoMediaItem {
        do {
            let doc = try SwiftSoup.parse(message)
            for element in try doc.select("img").array() {
                let img_src = try element.attr("src")
                
                let pictureURL = URL(string: img_src)
                
                if let pictureData = NSData(contentsOf: pictureURL! as URL) {
                    let catPicture = UIImage(data: pictureData as Data)!
                    
                    if let mediaItem = JSQPhotoMediaItem(image: catPicture) {
                        return mediaItem;
                    }
                    
                    return JSQPhotoMediaItem();
                }
                
                return JSQPhotoMediaItem();
            }
        }
        catch {
            return JSQPhotoMediaItem()
        }
        
        return JSQPhotoMediaItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            senderId = String(user.user_id)
            senderDisplayName = user.username
            
            //now load previous messages
            if let friend = self.friend {
                self.socket.emit("history_request", ["to": friend.username, "toid": friend.user_id, "from": user.username, "fromid": user.user_id])
            }
            
            socket.on("message") { (message, ack) in
                print("RECEIVED MESSAGE!")
                let data = message[0] as! [String:Any]
                
                let fromid = data["fromid"] as! Int
                let from = data["from"] as! String
                let content = data["content"] as! String
                
                if let message = JSQMessage(senderId: String(fromid), displayName: from, text: content.stringByDecodingHTMLEntities) {
                    self.messages.append(message)
                }
                
                self.finishReceivingMessage(animated: true)
                
            }
            
            socket.on("chat_history") { (message, ack) in
                print("received chat_history event from server")
                
                let data = message[0] as! [String: Any]
                let message_to = data["to"] as! String
                
                print("received chat logs for user \(message_to)")
   
                for chat_log in data["chat_logs"] as! [[String: Any]] {
                    let from = chat_log["from"] as! Int
                    let message = chat_log["message"] as! String
                    var image: JSQPhotoMediaItem = JSQPhotoMediaItem()
                    var contains_image: Bool = false
                    
                    //we need to parse out images from these texts
                    if (message.range(of: "<img") != nil) {
                        //we have an image!
                        print("image found!")
                        
                        //use a regex to get the image out of the tag
                        image = self.parseImage(message)
                        
                        contains_image = true
                    }
                    
                    if from != user.user_id {
                        if (contains_image) {
                            if let message = JSQMessage(senderId: String(self.friend!.user_id), displayName: self.friend!.username, media: image) {
                                self.messages.append(message)
                            }
                        }
                        else {
                            if let message = JSQMessage(senderId: String(self.friend!.user_id), displayName: self.friend!.username, text: message.stringByDecodingHTMLEntities) {
                                self.messages.append(message)
                            }
                        }
                    }
                    else {
                        if (contains_image) {
                            if let message = JSQMessage(senderId: String(user.user_id), displayName: user.username, media: image) {
                                self.messages.append(message)
                            }
                        }
                        else {
                            if let message = JSQMessage(senderId: String(user.user_id), displayName: user.username, text: message.stringByDecodingHTMLEntities) {
                                self.messages.append(message)
                            }
                        }
                    }
                }
                
                self.finishReceivingMessage()
                
                print("finished appending messages to messages array.")
            }
        }
    }
}
