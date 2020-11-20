//
//  DetailViewController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailLocation: UILabel!
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var note: Note?
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set storyboard
        detailDate.text = note?.date
        detailLocation.text = note?.location
        detailText.text = note?.content
        
        // The path is the default path if there has no photo in selected note
        path = "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322"
        
        if note?.photo?.isEmpty == true {
            setImage(str: path!)
        } else {
            setImage(str: (note?.photo)!)
        }
        
        // observe keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // observe keyboard rise up
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 150)
            }
        }
    }
    
    // observe keyboard go down
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // hide keyboard when click blank area
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.detailText.resignFirstResponder()
        self.view.endEditing(false)
    }
    
    // Download Image by using DispathQueue
    func setImage(str: String) {
        let url = URL(string: str)!
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.detailImage.image = image
                }
            }
        }
        task.resume()
    }
    
    // share image and content of a note
    @IBAction func share(_ sender: Any) {
        var activityVC: UIActivityViewController
        if self.note?.photo?.isEmpty == true {
            activityVC = UIActivityViewController(activityItems: [detailText.text!], applicationActivities: nil)
        } else {
            activityVC = UIActivityViewController(activityItems: [detailImage.image!,detailText.text!], applicationActivities: nil)
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // edit selected note
    @IBAction func edit(_ sender: Any) {
        if editButton.currentTitle == "Edit" {
            // change button states
            editButton.setTitle("Save", for: .normal)
            shareButton.backgroundColor = .systemGray
            shareButton.isUserInteractionEnabled = false
            shareButton.alpha = 0.4
            
            // text field can be editted
            self.detailText.isEditable = true
            self.detailText.becomeFirstResponder()
        } else {
            // update data
            note?.content = detailText.text
            
            // change button states
            editButton.setTitle("Edit", for: .normal)
            shareButton.backgroundColor = .systemBlue
            shareButton.isUserInteractionEnabled = true
            shareButton.alpha = 1
            
            // text fiedl cannot be editted
            self.detailText.isEditable = false
        }
        
    }

}
