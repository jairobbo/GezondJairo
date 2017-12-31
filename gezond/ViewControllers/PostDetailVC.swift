//
//  PostDetailVC.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 30-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class PostDetailVC: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var messageViewBottomCstr: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    var post: GPost?
    var comments: [GComment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        commentTextField.delegate = self
        
        sendButton.isEnabled = false
        
        CommentFirebase.observeComments(userID: post!.userID, imageURL: post!.imageURL.absoluteString, eventType: .childAdded) { (comment) in
            if let comment = comment {
                self.comments.append(comment)
                let indexPaths = [IndexPath(row: self.comments.count, section: 0)]
                self.detailTableView.insertRows(at: indexPaths, with: .fade)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendCommentButton(_ sender: Any) {
        guard let post = post,
            let user = Auth.auth().currentUser else { return }
        CommentFirebase.addComment(post: post, user: user, text: commentTextField.text ?? "")
        commentTextField.text = ""
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        sendButton.isEnabled = sender.text != ""
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect,
            let duration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double else { return }
        
        self.messageViewBottomCstr.constant = -keyboardRect.size.height
        UIView.animate(withDuration: duration, animations: {
            
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.detailTableView.scrollToRow(at: IndexPath(row: self.comments.count, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.messageViewBottomCstr.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension PostDetailVC: UITableViewDelegate {
    
}

extension PostDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return configureImageCell()
        } else {
            let alteredIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
            return configureCommentCell(indexPath: alteredIndexPath)
        }
    }
}

extension PostDetailVC {
    func configureImageCell() -> UITableViewCell {
        guard let cell = detailTableView.dequeueReusableCell(withIdentifier: "PostDetailCell") as? PostDetailCell,
            let post = post else { return UITableViewCell() }
        cell.postImageView.sd_setImage(
            with: post.imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        cell.postLabel.text = post.postText
        return cell
    }
    
    func configureCommentCell(indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = UITableViewCell()
        cell.imageView?.sd_setImage(
            with: comment.imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        cell.textLabel?.text = comment.text
        cell.selectionStyle = .none
        return cell
    }
}

extension PostDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
