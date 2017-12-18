//
//  ProfileViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 06-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

class UserViewController: UIViewController {
    
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    var userPosts = [Post]()
    let cameraPicker = UIImagePickerController()
    var isFriendsProfile = false
    var uid = ""
    var currentUser: GUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        cameraPicker.sourceType = .camera
        cameraPicker.delegate = self
        
        navigationItem.largeTitleDisplayMode = .never

        if !isFriendsProfile {
            uid = Auth.auth().currentUser?.uid ?? ""
        }
        
        GezondUser.get(uid: uid) { (user) in
            self.currentUser = user
            GezondPost.get(uid: self.uid) { (posts) in
                self.userPosts = posts
                self.postsCollectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

extension UserViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension UserViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
        if userPosts.count == 0 {
            let newEntryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "newElementCell", for: indexPath)
            newEntryCell.alpha = isFriendsProfile ? 0 : 1
            newEntryCell.isUserInteractionEnabled = !isFriendsProfile
            return newEntryCell
        } else {
            switch indexPath.row {
            case 0..<userPosts.count:
                guard let entryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "entryElementCell", for: indexPath) as? ProfileEntryCell else { return emptyCell }
                entryCell.imageView.af_setImage(withURL: userPosts[indexPath.row].imageURL)
                return entryCell
            case userPosts.count:
                let newEntryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "newElementCell", for: indexPath)
                return newEntryCell
            default:
                return emptyCell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profileHeader", for: indexPath) as? ProfileHeaderReusableView,
                let user = currentUser else { return emptyCell }
            header.nameLabel.text = user.name
            header.profileImageView.af_setImage(withURL: user.imageURL)
            return header
        default:
            return emptyCell
        }
    }
}

extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        guard let createPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createPost") as? CreatePostViewController else { return }
        createPostVC.image = image
        cameraPicker.pushViewController(createPostVC, animated: true)
    }
}
