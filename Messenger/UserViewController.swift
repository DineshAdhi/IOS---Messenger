//
//  UserViewController.swift
//  Messenger
//
//  Created by Dinesh Adhithya on 5/13/17.
//  Copyright © 2017 Dinesh Adhithya. All rights reserved.
//

import UIKit

class Contacts
{
    let username:String
    let lastMessage: String
    let uid: String
    let email: String
    var imageURL:String;
    
    
    init(username: String, lastMessage: String, uid: String, email:String, imageURL:String) {
        self.username = username
        self.lastMessage = lastMessage
        self.uid = uid
        self.email = email
        self.imageURL = imageURL;
    }
}

class UserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


}
