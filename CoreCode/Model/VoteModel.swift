//
//  VoteModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 12/01/22.
//

import Foundation
import SwiftyJSON

class VoteModel:NSCoder {
    
    var message = ""
    var review:Review!
    
    init(json:JSON){
        super.init()
        
        message = json["message"].stringValue
        review = Review(json: json)
    }
}

class Review:NSCoder {
    
    var _id = ""
    var reviewerId = ""
    var item = ""
    var restaurant = ""
    var desc = ""
    var rating = 0.0
    var upVote = 0
    var downVote = 0
    var createdAt = ""
    var __v = 0
    
    init(json:JSON){
        super.init()
        
        _id = json["review"]["_id"].stringValue
        reviewerId = json["review"]["reviewerId"].stringValue
        item = json["review"]["item"].stringValue
        restaurant = json["review"]["restaurant"].stringValue
        desc = json["review"]["description"].stringValue
        rating = json["review"]["rating"].doubleValue
        upVote = json["review"]["upVote"].intValue
        downVote = json["review"]["downVote"].intValue
        createdAt = json["review"]["createdAt"].stringValue
        __v = json["review"]["__v"].intValue
        
    }
}
