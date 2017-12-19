//
//  FoundFriendsTableViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 12-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit

class SearchVC: FriendsBaseTableViewController {

    var foundFriends: [GUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundFriends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let foundFriend = foundFriends[indexPath.row]
        return foundFriendCellFromFriend(friend: foundFriend)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let uninviteAction = createUninviteAction(indexPath: indexPath)
        let uninviteConfig = UISwipeActionsConfiguration(actions: [uninviteAction])
        return uninviteConfig
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let inviteAction = createInviteAction(indexPath: indexPath)
        let inviteConfig = UISwipeActionsConfiguration(actions: [inviteAction])
        return inviteConfig
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !foundFriends[indexPath.row].isFriend
    }
    
}

extension SearchVC {
    
    func createInviteAction(indexPath: IndexPath) -> UIContextualAction {
        let inviteAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            switch self.foundFriends[indexPath.row].isInvited {
            case false:
                UserFirebase.invite(userID: self.foundFriends[indexPath.row].userID, completion: { status in
                    if status {
                        self.foundFriends[indexPath.row].isInvited = true
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.accessoryView = UIImageView(image: #imageLiteral(resourceName: "invite+"))
                        handler(true)
                    } else {
                        handler(false)
                    }
                })
            case true:
                handler(false)
            }
        }
        inviteAction.backgroundColor = UIColor.green
        inviteAction.image = #imageLiteral(resourceName: "invite+")
        return inviteAction
    }
    
    func createUninviteAction(indexPath: IndexPath) -> UIContextualAction {
        let uninviteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, handler) in
            UserFirebase.uninvite(userID: self.foundFriends[indexPath.row].userID, completion: { (status) in
                if status {
                    self.foundFriends[indexPath.row].isInvited = false
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.accessoryView = nil
                    handler(true)
                } else {
                    handler(false)
                }
            })
        }
        uninviteAction.backgroundColor = UIColor.red
        uninviteAction.image = #imageLiteral(resourceName: "invite-")
        return uninviteAction
    }
}

