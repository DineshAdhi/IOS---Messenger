//
//  ChatViewController.swift
//  Messenger
//
//  Created by Dinesh Adhithya on 5/10/17.
//  Copyright © 2017 Dinesh Adhithya. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import PINRemoteImage


class ChatViewController: JSQMessagesViewController {
    
    var ChatLogs : [JSQMessage] = [];
    var opponentUID : String = "";
    var opponentUsername : String = "";
    var senderChatID : String = "";
    var receiverChatID : String = "";
    var senderImageUrlString: String = "";
    var recieverImageUrlString: String = "";

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = opponentUsername;
       
        automaticallyScrollsToMostRecentMessage = true
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    
        senderChatID = self.senderId + opponentUID;
        receiverChatID = self.opponentUID + self.senderId;
        
        FIRDatabase.database().reference().child("/IOSMessages/" + senderChatID).observe(.childAdded, with:
            { (snapshot) in
                
                let data = snapshot.value as! NSDictionary
                let message = data["message"] as! String
                let senderId = data["senderId"] as! String
                
                print()
                
                self.ChatLogs.append(JSQMessage(senderId: senderId, displayName: self.opponentUsername, text: message))
                
                self.collectionView.reloadData()
        })
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChatLogs.count;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return ChatLogs[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let font = UIFont(name: "Avenir Next", size: 16)
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView.font = font;
        if(ChatLogs[indexPath.row].senderId != self.senderId)
        {
            cell.textView.textColor = UIColor.black;
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let BubbleFactory = JSQMessagesBubbleImageFactory()
        
        if ChatLogs[indexPath.row].senderId == self.senderId
        {
            return BubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        }
        else
        {
            return BubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 0.3))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil;
    }
    
    

    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let data = [
            "message" : text,
            "senderId" : senderId
        ]
        FIRDatabase.database().reference().child("IOSMessages").child(senderChatID).childByAutoId().setValue(data)
        FIRDatabase.database().reference().child("IOSMessages").child(receiverChatID).childByAutoId().setValue(data)
        FIRDatabase.database().reference().child("IOSDialogs").child(senderChatID).setValue(data)
        FIRDatabase.database().reference().child("IOSDialogs").child(receiverChatID).setValue(data)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    
}
