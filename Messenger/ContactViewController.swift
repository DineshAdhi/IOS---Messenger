//
//  ContactViewController.swift
//  Messenger
//
//  Created by Dinesh Adhithya on 5/4/17.
//  Copyright © 2017 Dinesh Adhithya. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class Users
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

class ContactViewContvarler: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var userTableView: UITableView!
    
    var users : [Users] = []
    var currentUser: [Users] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // UI Elements
        let font = UIFont(name: "Avenir Next", size: 16)
        self.userTableView.dataSource = self;
        self.userTableView.delegate = self;
        self.userTableView.width = self.view.frame.size.width
        print(self.userTableView.width)
        print(self.view.frame.size.width)
        
        //Navigation Bar Styling
        self.title = "Contacts"
        let backButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:font!], for:UIControlState.normal)
        self.navigationItem.leftBarButtonItem = backButton
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        
        
        //User Data generation
        let userRef = FIRDatabase.database().reference().child("/IOSUsers");
        userRef.observe(.childAdded, with: { (snapshot) in
            
            let data = snapshot.value as? Dictionary<String,Any>
            let email = data?["email"] as? String ?? ""
            let username = data?["username"] as? String ?? ""
            let userId = data?["userId"] as? String ?? ""
            let imageURL:String = (data?["imageURL"] as? String)!
            
            print(email)
            
            if userId != FIRAuth.auth()?.currentUser?.uid
            {
                self.users.append(Users(username: username, lastMessage: "Hi", uid: userId, email: email, imageURL:imageURL))
                self.userTableView.reloadData()
            }
            else
            {
                self.currentUser.append(Users(username: username, lastMessage: "Hi", uid: userId, email: email, imageURL:imageURL))
                
                    //Current User Online Control
                    let online = FIRDatabase.database().reference().child("/.info/connected")
                    let userRef = FIRDatabase.database().reference().child("/presence/"+userId)
                
                    online.observe(.value, with: { (snapshot) in
                        if((snapshot.value) != nil)
                        {
                            userRef.onDisconnectSetValue(false)
                            userRef.setValue(true);
                        }
                    })
            }
        })
    }
    
    func backButtonTapped() {
        do{
            try FIRAuth.auth()?.signOut()
            FIRDatabase.database().reference().child("/presence/" + self.currentUser[0].uid).setValue(false)
            dismiss(animated: true, completion: nil)
        }
        catch{
            print("There was an error while logging out")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = Bundle.main.loadNibNamed("UserTableViewCell", owner: self, options: nil)?.first as! UserTableViewCell
        cell.userImageView.sd_setImage(with: URL(string: users[indexPath.row].imageURL)) { (image, error, cache, url) in
            if error == nil
            {
                print("Image Loaded Successfully")
            }
            else
            {
                print(error?.localizedDescription as String!)
            }
        }
        cell.userImageView.contentMode = .scaleAspectFit
        cell.userImageView.cornerRadius = 100;
        cell.usernameLabel.text = users[indexPath.row].username
        cell.chatId = currentUser[0].uid + users[indexPath.row].uid
        cell.senderId = currentUser[0].uid;
        cell.recieverId = users[indexPath.row].uid

        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatController.senderId = FIRAuth.auth()?.currentUser?.uid;
        chatController.senderDisplayName = FIRAuth.auth()?.currentUser?.displayName;
        chatController.opponentUID = users[(userTableView.indexPathForSelectedRow?.row)!].uid;
        chatController.opponentUsername = users[(userTableView.indexPathForSelectedRow?.row)!].username;
        chatController.senderImageUrlString = currentUser[0].imageURL
        print(currentUser[0].imageURL)
        chatController.recieverImageUrlString = self.users[(self.userTableView.indexPathForSelectedRow?.row)!].imageURL;
        print(chatController.recieverImageUrlString)
        self.navigationController?.pushViewController(chatController, animated: true)
    }

}
