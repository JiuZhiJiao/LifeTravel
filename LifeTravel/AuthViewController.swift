//
//  AuthViewController.swift
//  LifeTravel
//
//  Created by 苏桐 on 18/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        // set the navigation bar
        self.navigationController?.navigationBar.barTintColor = .systemBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont(name: "AppleSDGothicNeo-Bold", size: 28)!]
        self.navigationController?.navigationBar.tintColor = .white
        
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Register an account
    @IBAction func registerAccount(_ sender: Any) {
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        guard let email = emailTextField.text else {
            displayErrorMessage("Please enter an email address")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            }
        }
    }
    
    // Log in an account
    @IBAction func loginToAccount(_ sender: Any) {
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        guard let email = emailTextField.text else {
            displayErrorMessage("Please enter an email address")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            }
        }
    }
    
    // display message function
    func displayErrorMessage(_ errorMessage: String){
        let alertController = UIAlertController(title: "Error", message: errorMessage,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController,animated: true, completion: nil)
    }

}
