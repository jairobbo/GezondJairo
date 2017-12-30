//
//  FriendsBaseTableViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 12-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import SDWebImage

class FriendsBaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func foundFriendCellFromFriend(friend: GUser) -> UITableViewCell {
        let friendCell = UITableViewCell()
        friendCell.imageView?.sd_setImage(
            with: friend.imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        friendCell.textLabel?.text = friend.name
        friendCell.accessoryView = friend.isInvited ?
            UIImageView(image: #imageLiteral(resourceName: "invite+")) : friend.isFriend ?
                UIImageView(image: #imageLiteral(resourceName: "friendsIcon")) : nil
        friendCell.selectionStyle = .none
        return friendCell
    }
    
    func friendCellFromFriend(friend: GUserLight) -> UITableViewCell {
        let friendCell = UITableViewCell()
        friendCell.imageView?.sd_setImage(
            with: friend.imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        friendCell.textLabel?.text = friend.name
        friendCell.selectionStyle = .none
        return friendCell
    }
}
