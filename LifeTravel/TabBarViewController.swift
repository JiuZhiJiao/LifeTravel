//
//  TabBarViewController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import FirebaseAuth

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // set the navigation bar
        self.navigationController?.navigationBar.barTintColor = .systemBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont(name: "AppleSDGothicNeo-Bold", size: 28)!]
        self.navigationController?.navigationBar.tintColor = .white
        
    }
    
    @IBAction func logOutOfAccount(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
        navigationController?.popViewController(animated: true)
    }
    

}
