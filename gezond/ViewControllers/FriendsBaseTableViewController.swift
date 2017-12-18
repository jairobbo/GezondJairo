//
//  FriendsBaseTableViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 12-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import AlamofireImage

class FriendsBaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func foundFriendCellFromFriend(friend: GUser) -> UITableViewCell {
        let friendCell = UITableViewCell()
        friendCell.imageView?.af_setImageGezond(url: friend.imageURL)
        friendCell.textLabel?.text = friend.name
        friendCell.accessoryView = friend.isInvited ? UIImageView(image: #imageLiteral(resourceName: "invite+")) : nil
        friendCell.accessoryView = friend.isFriend ? UIImageView(image: #imageLiteral(resourceName: "friendsIcon")) : nil
        friendCell.selectionStyle = .none
        return friendCell
    }
    
    func friendCellFromFriend(friend: GUserLight) -> UITableViewCell {
        let friendCell = UITableViewCell()
        friendCell.imageView?.af_setImageGezond(url: friend.imageURL)
        friendCell.textLabel?.text = friend.name
        friendCell.selectionStyle = .none
        return friendCell
    }
}

extension UIImageView {
    
    public func af_setImageGezond(url: URL) {
        self.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "cook"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: false) { (response) in
        }
    }
}
