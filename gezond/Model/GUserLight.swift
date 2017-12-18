//
//  GUserLight.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 18-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation

class GUserLight {
    var uid: String
    var name: String
    var imageURL: URL
    
    init?(userDictionary: [String: String]?) {
        guard let uid = userDictionary?["uid"],
            let name = userDictionary?["name"],
            let urlString = userDictionary?["imageURL"],
            let url = URL(string: urlString) else { return nil}
        self.uid = uid
        self.name = name
        self.imageURL = url
    }
}
