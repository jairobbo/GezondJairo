//
//  TimelineViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 18-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit

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
            self.posts.insert(post, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
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
        cell.postImageView.af_setImageGezond(url: post.imageURL)
        cell.postTextLabel.text = post.postText
        cell.selectionStyle = .none
        return cell
    }
}
