//
//  ReviewModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 11/01/22.
//

import Foundation
import SwiftyJSON
import Alamofire

class ReviewModel: NSObject {
    
    var reviewsCount = 0
    var reviewDetails:Reviewdetail!
    
    init(json:JSON){
        super.init()
        
        reviewsCount = json["reviews_count"].intValue
        reviewDetails = Reviewdetail(json: json)
    }
}

class Reviewdetail: NSCoder {
    
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[ResultReview] = []
    
    init(json:JSON){
        super.init()
        page = json["review_details"]["page"].intValue
        limit = json["review_details"]["limit"].intValue
        totalDocs = json["review_details"]["totalDocs"].intValue
        totalPages = json["review_details"]["totalPages"].intValue
        pagingCounter = json["review_details"]["pagingCounter"].intValue
        for r in json["review_details"]["result"].arrayValue {
            result.append(ResultReview(json: r))
        }
    }
}

class ResultReview: NSObject {
    
    var _id = ""
    var reviewerId:[ReviewerId] = []
    var item = ""
    var restaurant = ""
    var desc = ""
    var rating = 0.0
    var upVote = 0
    var downVote = 0
    var createAt = ""
    var __v = 0
    var image:[String] = []
    var isUpVoted = false
    var isDownVoted = false
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        for review in json["reviewerId"].arrayValue {
            reviewerId.append(ReviewerId(json: review))
        }
        item = json["item"].stringValue
        restaurant = json["restaurant"].stringValue
        desc = json["description"].stringValue
        rating = json["rating"].doubleValue
        upVote = json["upVote"].intValue
        downVote = json["downVote"].intValue
        createAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
        for i in json["image"].arrayValue{
            image.append(i.stringValue)
        }
        isUpVoted = json["isUpVoted"].boolValue
        isDownVoted = json["isDownVoted"].boolValue
        
    }
}

class ReviewerId: NSCoder {
    
    var _id = ""
    var name = ""
    var email = ""
    var diet:[String] = []
    var profile = ""
    var role = ""
    var blacklist = false
    var language = ""
    var bytPoints = 0
    var avgSpend = 0
    var createdAt = ""
    var __v = 0
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        email = json["email"].stringValue
        for d in json["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        profile = json["profile"].stringValue
        role = json["role"].stringValue
        blacklist = json["blacklist"].boolValue
        language = json["language"].stringValue
        bytPoints = json["bytPoints"].intValue
        avgSpend = json["avgSpend"].intValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
}
