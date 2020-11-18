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
    @IBOutlet weak var detailContent: UILabel!
    
    var note: Note?
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailDate.text = note?.date
        detailLocation.text = note?.location
        detailContent.text = note?.content
        
        //path = "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322"
        
        detailImage.image = requestImage(from: note?.photo)
        
    }
    
    // Download Image
    func requestImage(from str: String?) -> UIImage? {
        guard let url = URL(string: str ?? "") else {
            print("Unable to create URL")
            return nil
        }
        var image:UIImage? = nil
        
        do {
            let data = try Data(contentsOf: url, options: [])
            image = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
        
        return image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
