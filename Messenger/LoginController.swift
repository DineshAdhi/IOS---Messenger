//
//  LoginController.swift
//  Messenger
//
//  Created by Dinesh Adhithya on 5/4/17.
//  Copyright © 2017 Dinesh Adhithya. All rights reserved.
//

import UIKit
import Material
import Firebase
import JTMaterialSpinner

class LoginController: UIViewController{
    

    @IBOutlet weak var materailSpinnerView: JTMaterialSpinner!
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var emailField: ErrorTextField!
    @IBOutlet weak var passwordField: ErrorTextField!
    
    let PASSWORD_ERROR = "The password is invalid or the user does not have a password."
    let UNKNOWN_USER = "There is no user record corresponding to this identifier. The user may have been deleted."
    let NETWORK_ERR = "Network error (such as timeout, interrupted connection or unreachable host) has occurred."
    
    override func viewDidLoad() {

        super.loadView()
        
        let emailView = UIImageView()
        emailView.image = Icon.email
        emailField.leftView = emailView;
        
        let passwordView = UIImageView()
        passwordView.image = Icon.cm.check
        passwordField.leftView = passwordView
        
        emailField.placeholder = "Email"
        emailField.isClearIconButtonEnabled = true
        
        passwordField.placeholder = "Password"
        passwordField.isClearIconButtonEnabled = true
        
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (windowWidth()/2) - 25 , y: (windowHeight()/2)-25, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor = Color.lightBlue.accent1.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser != nil)
        {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }

    @IBAction func signinbutton(_ sender: Any) {
        if (passwordField.text != nil && emailField.text != nil)
        {
            toggleTextFields()
            spinnerView.beginRefreshing();
            FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!
                , completion: { (user, error) in
                    if error == nil
                    {
                        self.toggleTextFields()
                        self.spinnerView.endRefreshing();
                        print("User Signed in")
                        self.emailField.text = "";
                        self.passwordField.text = "";
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                    else
                    {
                        self.toggleTextFields()
                        self.spinnerView.endRefreshing();
                        print(error?.localizedDescription ?? "Default Value")
                        if error?.localizedDescription == self.PASSWORD_ERROR
                        {
                            self.passwordField.detail = "Invalid Password"
                            self.passwordField.isErrorRevealed = true;
                        }
                        if error?.localizedDescription == self.UNKNOWN_USER
                        {
                            self.emailField.detail = "The Email id is not registered"
                            self.emailField.isErrorRevealed = true;
                        }
                        if(error?.localizedDescription == self.NETWORK_ERR)
                        {
                            let alertController = UIAlertController(title: "No internet Connection", message: "Can't Connect to Server, Please connect to the internet and try again", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
            })
        }
    }
    
    
    
    @IBAction func registerButton(_ sender: Any) {
        performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    
    func toggleTextFields()
    {
        emailField.isHidden = !emailField.isHidden
        passwordField.isHidden = !passwordField.isHidden
        passwordField.isErrorRevealed = false;
        emailField.isErrorRevealed = false;
    }
    
    func windowHeight() -> CGFloat{
        return UIScreen.main.bounds.height
    }
    
    func windowWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    
}



