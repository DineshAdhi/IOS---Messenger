//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Dinesh Adhithya on 5/5/17.
//  Copyright © 2017 Dinesh Adhithya. All rights reserved.
//

import UIKit
import Firebase
import Material
import FirebaseStorage
import JTMaterialSpinner
import MobileCoreServices

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate{

    @IBOutlet weak var emailTextField: ErrorTextField!
    @IBOutlet weak var passwordTextField: ErrorTextField!
    @IBOutlet weak var usernameTextField: ErrorTextField!
    @IBOutlet weak var registeredUserModal: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    var currentUserImageURL:String = ""
    
    let EXISTING_MAIL_ERROR = "The email address is already in use by another account."
    
    var spinnerView = JTMaterialSpinner()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registeredUserModal.isHidden = true
        
        let emailView = UIImageView()
        let passwordView = UIImageView()
        let usernameView = UIImageView()
        
        emailView.image = Icon.email
        passwordView.image = Icon.check
        usernameView.image = Icon.star
        
        
        emailTextField.placeholder = "Email"
        emailTextField.leftView = emailView
        
        passwordTextField.placeholder = "Password"
        passwordTextField.leftView = passwordView
        
        usernameTextField.placeholder = "Username"
        usernameTextField.leftView = usernameView

        // Do any additional setup after loading the view.
        
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (self.view.frame.width/2) - 25, y: (self.view.frame.height/2) + 75, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor = Color.lightBlue.accent1.cgColor
    }

    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userRegister(_ sender: Any) {

        if usernameTextField.text != ""
        {
            toggleButtons()
            spinnerView.beginRefreshing()
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error == nil
                {
                    self.spinnerView.endRefreshing();
                    self.uploadImageToFirebase(user: user!)
                    
                    
                    let changeRequest = (FIRAuth.auth()?.currentUser?.profileChangeRequest())!
                    changeRequest.displayName = self.usernameTextField.text;
                    changeRequest.commitChanges(completion: { (error) in
                        if(error == nil)
                        {
                            print("Commit Chantes Successful");
                        }
                        else
                        {
                            print("Error while Commiting")
                            print(error?.localizedDescription as String!)
                        }
                    })
                    
                    do
                    {
                        try FIRAuth.auth()?.signOut()
                    }
                    catch{
                        print("Signout Error")
                    }
                    
                    self.registeredUserModal.isHidden = false;
                    
                }
                else
                {
                    
                    self.spinnerView.endRefreshing();
                    print(error?.localizedDescription ?? "Default")
                    
                    if(error?.localizedDescription == self.EXISTING_MAIL_ERROR)
                    {
                        self.emailTextField.detail = "The Email you've entered already exists";
                        self.emailTextField.isErrorRevealed = true;
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    self.toggleButtons()
                }
            })
        }
        else
        {
            usernameTextField.detail = "You must enter your username";
            usernameTextField.isErrorRevealed = true;
        }
    }
    
    func toggleButtons()
    {
        emailTextField.isHidden = !emailTextField.isHidden
        passwordTextField.isHidden = !passwordTextField.isHidden
        usernameTextField.isHidden = !usernameTextField.isHidden
    }
    
    @IBAction func registeredUserSignIn(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
   
    
    @IBAction func uploadImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String!]
        picker.delegate = self;
        picker.allowsEditing = true;
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        userImageView.image = image;
    }
    
    
    func uploadImageToFirebase(user:FIRUser){
    
        let imageData = UIImageJPEGRepresentation(userImageView.image!, 0.3)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        FIRStorage.storage().reference().child("/images/"+user.uid+".jpeg").put(imageData!, metadata: metaData) { (metaData, error) in
            if(error == nil)
            {
                print("Upload Successful");
                self.uploadDatatoFirebase(user: user, imageURL: (metaData?.downloadURL())!)
            }
        }
    }
    
    func uploadDatatoFirebase(user:FIRUser, imageURL:URL)
    {
        if self.usernameTextField.text != "" && self.emailTextField.text != "" && self.passwordTextField.text != ""
        {
            let data:Dictionary<String, Any> = ["username": self.usernameTextField.text!,"email": self.emailTextField.text! , "password": self.passwordTextField.text!, "userId":user.uid, "imageURL" : imageURL.absoluteString] as [String : Any];
            
            FIRDatabase.database().reference().child("/IOSUsers").child(user.uid).setValue(data)
            FIRDatabase.database().reference().child("/presence/" + user.uid).setValue(false)
        }
    }




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
