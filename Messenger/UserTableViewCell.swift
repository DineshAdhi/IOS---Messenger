//
//  UserTableViewCell.swift
//  Messenger
//
//  Created by Dinesh Adhithya on 5/5/17.
//  Copyright © 2017 Dinesh Adhithya. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewCell: UITableViewCell {


    @IBOutlet weak var onlineIndicator: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var chatMessageTextLabel: UILabel!
    var chatId:String = ""
    var senderId:String = ""
    var recieverId:String = ""
    
    override func didMoveToWindow() {
        self.userImageView.cornerRadius = userImageView.frame.size.width/2;
        self.userImageView.clipsToBounds = true
        chatMessageTextLabel.text = ""
        
                
        //OnlineIndicator Control
        onlineIndicator.cornerRadius = onlineIndicator.frame.width/2;
        onlineIndicator.clipsToBounds = true;
        
        FIRDatabase.database().reference().child("/presence/"+recieverId).observe(.value, with: { (snapshot) in
            print("\nOnline Value Changed")
            if let data:Bool = snapshot.value as? Bool
            {
                self.onlineIndicator.isHidden = !data;
                print("Changed the image state")
                print(self.onlineIndicator.isHidden)
            }
         
        })

        
        
        //ChatDialog control
        FIRDatabase.database().reference().child("IOSDialogs/" + chatId).observe(.value, with: { (snapshot) in
            if let data:NSDictionary = snapshot.value as? NSDictionary{
                let message = data["message"] as? String
                let senderId = data["senderId"] as? String
                self.chatMessageTextLabel.text = message
                
                if(senderId != self.senderId)
                {
                    let font = UIFont(name: "Avenir-Medium", size: 13)
                    self.chatMessageTextLabel.textColor = UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1)
                    self.chatMessageTextLabel.font = font;
                }
                else
                {
                    let font = UIFont(name: "Avenir", size: 13)
                    self.chatMessageTextLabel.textColor = UIColor.black
                    self.chatMessageTextLabel.font = font;
                }
            }
            
        })

    }
    
        
}
