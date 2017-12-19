//
//  CreatePostViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 08-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import Firebase

class CreateVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var image: UIImage = UIImage()
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        PostFirebase.create(image: image, text: textView.text, userID: userID) { (error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
