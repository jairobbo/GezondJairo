//
//  ProfileViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 06-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserVC: UIViewController {
    
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    var userPosts = [GPost]()
    let cameraPicker = UIImagePickerController()
    var isFriendsProfile = false
    var userID = ""
    var currentUser: GUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "UserHeaderCollectionReusableView", bundle: nil)
        postsCollectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "userHeader")
        
        cameraPicker.sourceType = .camera
        cameraPicker.delegate = self
        
        navigationItem.largeTitleDisplayMode = .never

        if !isFriendsProfile {
            userID = Auth.auth().currentUser?.uid ?? ""
        }
        
        UserFirebase.get(userID: userID) { (user) in
            self.currentUser = user
            if let currentUser = self.currentUser {
                let firstName = currentUser.name.split(separator: " ").first ?? "noname"
                self.title = "\(firstName)'s pagina"
            }
            self.postsCollectionView.reloadSections(IndexSet(integer: 0))
            PostFirebase.observeUserPosts(userID: self.userID, eventType: .childAdded) { (post) in
                guard let userPost = post else { return }
                self.userPosts.insert(userPost, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.postsCollectionView.insertItems(at: [indexPath])
            }
            PostFirebase.observeUserPosts(userID: self.userID, eventType: .childRemoved, completion: { (post) in
                guard let userPost = post else { return }
                if let index = self.userPosts.index(where: { (aPost) -> Bool in
                    aPost.imageURL.absoluteString == userPost.imageURL.absoluteString
                }) {
                    self.userPosts.remove(at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.postsCollectionView.deleteItems(at: [indexPath])
                }
            })
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width/3, height: width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 74)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == userPosts.count {
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
}

extension UserVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return userPosts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if userPosts.count == 0 {
            return configureAddPostCell(indexPath: indexPath)
        } else {
            if indexPath.row == userPosts.count {
                return configureAddPostCell(indexPath: indexPath)
            } else {
                return configurePostCell(indexPath: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return configureHeader(indexPath: indexPath)
        } else {
            return UICollectionReusableView()
        }
    }
}

extension UserVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        guard let createPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createPost") as? CreateVC else { return }
        createPostVC.image = image
        createPostVC.userID = self.userID
        cameraPicker.pushViewController(createPostVC, animated: true)
    }
}

extension UserVC {
    
    //collectionView Cells
    
    func configureAddPostCell(indexPath: IndexPath) -> UICollectionViewCell {
        let newEntryCell = postsCollectionView.dequeueReusableCell(withReuseIdentifier: "newElementCell", for: indexPath)
        newEntryCell.contentView.alpha = isFriendsProfile ? 0 : 1
        newEntryCell.isUserInteractionEnabled = !isFriendsProfile
        return newEntryCell
    }
    
    func configurePostCell(indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = postsCollectionView.dequeueReusableCell(
            withReuseIdentifier: "emptyCell",
            for: indexPath)
        guard let postCell = postsCollectionView.dequeueReusableCell(
            withReuseIdentifier: "entryElementCell",
            for: indexPath) as? ProfileEntryCell else { return emptyCell }
        postCell.imageView.sd_setImage(
            with: userPosts[indexPath.row].imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        return postCell
    }
    
    func configureHeader(indexPath: IndexPath) -> UICollectionReusableView {
        let emptyCell = postsCollectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "userHeader",
            for: indexPath
        )
        guard let header = postsCollectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "userHeader",
            for: indexPath
            ) as? UserHeaderCollectionReusableView,
            let user = currentUser else { return emptyCell }
        header.nameLabel.text = user.name
        header.avatarImageView.sd_setImage(
            with: user.imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        return header
    }
}
