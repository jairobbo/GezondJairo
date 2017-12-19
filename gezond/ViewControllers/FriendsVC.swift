//
//  FriendsMainTableViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 12-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit

class FriendsVC: FriendsBaseTableViewController {

    var matrixModel: [[GUserLight]] = [[], []]
    var headerNames: [String] = ["Uitnodigingen", "Vrienden"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Vrienden"
        
        let foundFriendsTVC = SearchVC()
        navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController(searchResultsController: foundFriendsTVC)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        definesPresentationContext = true
        
        UserFirebase.observeInvitesAndFriends(directory: "friends", eventType: .childAdded) { (friend) in
            if let friend = friend {
                self.matrixModel[1].append(friend)
                let row = self.matrixModel[1].count - 1
                let indexPath = IndexPath(row: row, section: 1)
                self.tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
        
        UserFirebase.observeInvitesAndFriends(directory: "friends", eventType: .childRemoved) { (friend) in
            if let friend = friend {
                let optionalIndex = self.matrixModel[1].index(where: { (anotherFriend) -> Bool in
                    friend.userID == anotherFriend.userID
                })
                guard let index = optionalIndex else { return }
                self.matrixModel[1].remove(at: index)
                let indexPath = IndexPath(row: index, section: 1)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        UserFirebase.observeInvitesAndFriends(directory: "invites", eventType: .childAdded) { (friend) in
            if let friend = friend {
                self.matrixModel[0].append(friend)
                let row = self.matrixModel[0].count - 1
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
        
        UserFirebase.observeInvitesAndFriends(directory: "invites", eventType: .childRemoved) { (friend) in
            if let friend = friend {
                let optionalIndex = self.matrixModel[0].index(where: { (anotherFriend) -> Bool in
                    friend.userID == anotherFriend.userID
                })
                guard let index = optionalIndex else { return }
                self.matrixModel[0].remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension FriendsVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return headerNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matrixModel[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = matrixModel[indexPath.section][indexPath.row]
        return friendCellFromFriend(friend: friend)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerNames[section]
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            return UISwipeActionsConfiguration(actions: [createAcceptAction(indexPath: indexPath)])
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            return UISwipeActionsConfiguration(actions: [createDeclineAction(indexPath: indexPath)])
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let userID = matrixModel[indexPath.section][indexPath.row].userID
            guard let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC") as? UserVC else { return }
            userVC.userID = userID
            userVC.isFriendsProfile = true
            navigationController?.pushViewController(userVC, animated: true)
        }
    }
}

extension FriendsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
            searchText != "" else {
            return
        }
        UserFirebase.searchUsers(searchText: searchText) { (friends) in
            if let foundFriendsTVC = searchController.searchResultsController as? SearchVC {
                foundFriendsTVC.foundFriends = friends
                foundFriendsTVC.tableView.reloadData()
            }
        }
    }
}

extension FriendsVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension FriendsVC: UISearchControllerDelegate {
    
}

extension FriendsVC {
    
    func createAcceptAction(indexPath: IndexPath) -> UIContextualAction {
        let acceptAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            let user = self.matrixModel[indexPath.section][indexPath.row]
            UserFirebase.acceptInvite(inviteUser: user, completion: { (status) in
                DispatchQueue.main.async {
                    if status {
                        handler(true)
                    } else {
                        handler(false)
                    }
                }
            })
        }
        acceptAction.backgroundColor = UIColor.green
        acceptAction.image = #imageLiteral(resourceName: "check")
        return acceptAction
    }
    
    func createDeclineAction(indexPath: IndexPath) -> UIContextualAction {
        let declineAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            let user = self.matrixModel[indexPath.section][indexPath.row]
            UserFirebase.declineInvite(inviteUser: user, completion: { (status) in
                if status {
                    handler(true)
                } else {
                    handler(false)
                }
            })
        }
        declineAction.backgroundColor = UIColor.red
        declineAction.image = #imageLiteral(resourceName: "cross")
        return declineAction
    }
    
    
}


