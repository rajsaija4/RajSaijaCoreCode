//
//  NewsObject.swift
//  projectName
//
//  companyName on 04/02/22.
//

import Foundation

class NewsObject: NSObject, Codable {
    var objMetaDetail = MetaDetail.init([:])
    var arrNews: [NewsList] = []
    
    init(_ dictionary: [String: Any]) {
        if let objMeta = dictionary["meta"] as? Dictionary<String, Any> {
            self.objMetaDetail = MetaDetail.init(objMeta)
        }
        
        if let arrList = dictionary["data"] as? [Dictionary<String, Any>] {
            for i in 0..<arrList.count  {
                let objDetail = NewsList.init(arrList[i])
                self.arrNews.append(objDetail)
            }
        }
    }
}

class MetaDetail: NSObject, Codable {
    var found: Double = 0.0
    var returned: Int = 0
    var limit: Int = 0
    var page: Int = 0
    
    init(_ dictionary: [String: Any]) {
        self.found = dictionary["found"] as? Double ?? 0.0
        self.returned = dictionary["returned"] as? Int ?? 0
        self.limit = dictionary["limit"] as? Int ?? 0
        self.page = dictionary["page"] as? Int ?? 0
    }
}

//MARK: - NEWS LIST
class NewsList: NSObject, Codable {
    var uuid: String = ""
    var title: String = ""
    var description_news: String = ""
    var keywords: String = ""
    var snippet: String = ""
    var url: String = ""
    var image_url: String = ""
    var language: String = ""
    var published_at: String = ""
    var source: String = ""
    var relevance_score: Double = 0.0
    
    var arrEntities: [NewsEntitiesObject] = []
    var arrSimilar: [NewsSimilarObject] = []
    
    init(_ dictionary: [String: Any]) {
        self.uuid = dictionary["uuid"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.description_news = dictionary["description"] as? String ?? ""
        self.keywords = dictionary["keywords"] as? String ?? ""
        self.snippet = dictionary["snippet"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
        self.image_url = dictionary["image_url"] as? String ?? ""
        self.language = dictionary["language"] as? String ?? ""
        self.published_at = dictionary["published_at"] as? String ?? ""
        self.source = dictionary["source"] as? String ?? ""
        self.relevance_score = dictionary["relevance_score"] as? Double ?? 0.0
        
        if let entities = dictionary["entities"] as? [Dictionary<String, Any>] {
            for i in 0..<entities.count  {
                let objData = NewsEntitiesObject.init(entities[i])
                self.arrEntities.append(objData)
            }
        }
        
        if let similar = dictionary["similar"] as? [Dictionary<String, Any>] {
            for i in 0..<similar.count  {
                let objData = NewsSimilarObject.init(similar[i])
                self.arrSimilar.append(objData)
            }
        }
    }
}

class NewsEntitiesObject: NSObject, Codable {
    var symbol: String = ""
    var name: String = ""
    var exchange: String = ""
    var exchange_long: String = ""
    var country: String = ""
    var type: String = ""
    var industry: String = ""
    var match_score: Double = 0.0
    var sentiment_score: Double = 0.0
    
    var arrHighlight: [HighlightObject] = []
    
    init(_ dictionary: [String: Any]) {
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.exchange = dictionary["exchange"] as? String ?? ""
        self.exchange_long = dictionary["exchange_long"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.industry = dictionary["industry"] as? String ?? ""
        self.match_score = dictionary["match_score"] as? Double ?? 0.0
        self.sentiment_score = dictionary["sentiment_score"] as? Double ?? 0.0
        
        if let highlight = dictionary["highlights"] as? [Dictionary<String, Any>] {
            for i in 0..<highlight.count  {
                let objData = HighlightObject.init(highlight[i])
                self.arrHighlight.append(objData)
            }
        }
    }
}

class HighlightObject: NSObject, Codable {
    var highlight: String = ""
    var sentiment: Double = 0.0
    var highlighted_in: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.highlight = dictionary["highlight"] as? String ?? ""
        self.sentiment = dictionary["sentiment"] as? Double ?? 0.0
        self.highlighted_in = dictionary["highlighted_in"] as? String ?? ""
    }
}

class NewsSimilarObject: NSObject, Codable {
    var id: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
    }
}
