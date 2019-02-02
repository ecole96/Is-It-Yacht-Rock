//
//  Song.swift
//  IsItYacht
//
//  Created by Evan Cole on 9/15/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import Foundation

// class for song data (optionals are only for matched songs)
class Song {
    var title: String
    var artist: String
    var yachtski: Float?
    var jd: Float?
    var steve: Float?
    var hunter: Float?
    var dave: Float?
    var imageURL: String?
    var show: String?
    
    init(title: String,artist: String,yachtski: Float?, show: String?, jd: Float?,steve: Float?,hunter: Float?,dave: Float?, imageURL: String?) {
        self.title = title
        self.artist = artist
        self.yachtski = yachtski
        self.jd = jd
        self.steve = steve
        self.hunter = hunter
        self.dave = dave
        self.imageURL = imageURL
        self.show = show
    }
}
