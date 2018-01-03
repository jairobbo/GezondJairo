//
//  TimelineViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 18-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import SDWebImage

class TimelineVC: UIViewController {
    
    @IBOutlet weak var timelineTableView: UITableView!
    
    var posts: [GPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Timeline"
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self

        PostFirebase.observeTimelinePosts(eventType: .childAdded) { (optionalPost) in
            guard let post = optionalPost else { return }
            let indexPath = insertSortedByTimestamp(newElement: post, array: &self.posts)
            self.timelineTableView.insertRows(at: [indexPath], with: .fade)
        }
        
        PostFirebase.observeTimelinePosts(eventType: .childRemoved) { (optionalPost) in
            guard let post = optionalPost else { return }
            if let index = self.posts.index(where: { (aPost) -> Bool in
                aPost.imageURL.absoluteString == post.imageURL.absoluteString
            }) {
                self.posts.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.timelineTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        UserFirebase.observeInvitesAndFriends(directory: "friends", eventType: .childRemoved) { (user) in
            guard let user = user else { return }
            var indices: [Int] = []
            for (index, post) in self.posts.enumerated() {
                if post.userID == user.userID {
                    indices.append(index)
                }
            }
            var indexPaths: [IndexPath] = []
            for index in indices.reversed() {
                self.posts.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                indexPaths.append(indexPath)
            }
            self.timelineTableView.deleteRows(at: indexPaths, with: .fade)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TimelineVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        presentDetail(post: post)
    }
}

extension TimelineVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "timelineCell") as? PostTimelineCell else { return UITableViewCell() }
        return configureCell(cell: cell, indexPath: indexPath)
    }
}

extension TimelineVC {
    func configureCell(cell: PostTimelineCell, indexPath: IndexPath) -> PostTimelineCell {
        let post = posts[indexPath.row]
        cell.postImageView.sd_setImage(
            with: post.imageURL,
            placeholderImage: #imageLiteral(resourceName: "cook"),
            options: [],
            completed: nil)
        cell.postTextLabel.text = post.postText
        cell.selectionStyle = .none
        return cell
    }
    
    func presentDetail(post: GPost) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let postDetailVC = storyboard.instantiateViewController(withIdentifier: "PostDetailVC") as? PostDetailVC else { return }
        postDetailVC.post = post
        self.present(postDetailVC, animated: true, completion: nil)
    }
}

func insertSortedByTimestamp<T: HasTimestamp> (newElement: T, array: inout [T]) -> IndexPath {
    var insertIndex = array.count
    for (index, element) in array.enumerated().reversed() {
        if newElement.timestamp > element.timestamp {
            insertIndex = index
        }
    }
    array.insert(newElement, at: insertIndex)
    return IndexPath(row: insertIndex, section: 0)
}

protocol HasTimestamp {
    var timestamp: Double { get }
}
