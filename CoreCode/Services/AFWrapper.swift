//
//  AFWrapper.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class AFWrapper: NSObject {
    static let shared: AFWrapper = {
        return AFWrapper()
    }()
    let retryLimit = 3
    
    func requestGETURL(_ strURL: String, params: [String : Any]? = nil, headers: [String : String]? = nil, interceptor: RequestInterceptor? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {

        print("\(Constants.URLS.BASE_URL)\(strURL)")

        var headers: HTTPHeaders = HTTPHeaders([:])
        if defaults.object(forKey: kAuthToken) != nil {
            headers = [
                "Authorization": "Bearer \(defaults.object(forKey: kAuthToken) as! String)",
            ]
        }

        AF.request(Constants.URLS.BASE_URL + strURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers, interceptor: interceptor ?? self).validate(statusCode: 200..<600).responseString(completionHandler: { (responseString: DataResponse) in
            debugPrint(responseString)
        }).responseData(completionHandler: {response in
            switch response.result{
            case .success(let res):
                success(JSON(res))
            case .failure(let error):
                failure(error)
            }
        })
    }
    
    func requestPOSTURL(_ strURL: String, params: [String : Any]?, headers: [String : String]? = nil, interceptor: RequestInterceptor? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {

        print("\(Constants.URLS.BASE_URL)\(strURL) request: \(params!)")
        
        var headers: HTTPHeaders = HTTPHeaders([:])
        if defaults.object(forKey: kAuthToken) != nil {
            headers = [
                "Authorization": "Bearer \(defaults.object(forKey: kAuthToken) as! String)",
            ]
        }

        AF.request(Constants.URLS.BASE_URL + strURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers, interceptor: interceptor ?? self).validate(statusCode: 200..<600).responseString(completionHandler: { (responseString: DataResponse) in
            debugPrint(responseString)
        }).responseData(completionHandler: {response in
            switch response.result{
            case .success(let res):
                success(JSON(res))
            case .failure(let error):
                failure(error)
            }
        })
    }
        
    func postWithUploadMultipleFiles(_ files: [Document], strURL: String, params: [String : Any]?, headers: [String : String]? = nil, interceptor: RequestInterceptor? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {

        print("\(Constants.URLS.BASE_URL)\(strURL) request: \(params!)")

        var headers: HTTPHeaders = HTTPHeaders([:])
        if defaults.object(forKey: kAuthToken) != nil {
            headers = [
                "Authorization": "Bearer \(defaults.object(forKey: kAuthToken) as! String)",
            ]
        }

        AF.upload(multipartFormData: { (multipartFormData: MultipartFormData) in
            for file in files {
                multipartFormData.append(file.data, withName: file.uploadParameterKey, fileName: file.fileName, mimeType: file.mimeType)
            }
            if let params = params {
                for (key, value) in params {
                    multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, to: Constants.URLS.BASE_URL + strURL, method: .post, headers: headers, interceptor: interceptor ?? self).uploadProgress { progress in
            debugPrint("Upload Progress: \(progress.fractionCompleted)")
        }.validate(statusCode: 200..<600).responseString(completionHandler: { (responseString: DataResponse) in
            debugPrint(responseString)
        })
        .responseJSON { response in
            debugPrint("response.response\n\(String(describing: response.response))")
        }
        .responseData(completionHandler: { response in
            switch response.result{
            case .success(let res):
                success(JSON(res))
            case .failure(let error):
                debugPrint(error)
                failure(error)
            }
        })
    }
    
    func requestDELETEURL(_ strURL: String, params: [String : Any]? = nil, headers: [String : String]? = nil, interceptor: RequestInterceptor? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {

        print("\(Constants.URLS.BASE_URL)\(strURL)")

        var headers: HTTPHeaders = HTTPHeaders([:])
        if defaults.object(forKey: kAuthToken) != nil {
            headers = [
                "Authorization": "Bearer \(defaults.object(forKey: kAuthToken) as! String)",
            ]
        }

        AF.request(Constants.URLS.BASE_URL + strURL, method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers, interceptor: interceptor ?? self).validate(statusCode: 200..<600).responseString(completionHandler: { (responseString: DataResponse) in
            debugPrint(responseString)
        }).responseData(completionHandler: {response in
            switch response.result{
            case .success(let res):
                success(JSON(res))
            case .failure(let error):
                failure(error)
            }
        })
    }
    
    func requestPATCHURL(_ strURL: String, params: [String : Any]? = nil, headers: [String : String]? = nil, interceptor: RequestInterceptor? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {

        print("\(Constants.URLS.BASE_URL)\(strURL) request: \(params!)")
        
        var headers: HTTPHeaders = HTTPHeaders([:])
        if defaults.object(forKey: kAuthToken) != nil {
            headers = [
                "Authorization": "Bearer \(defaults.object(forKey: kAuthToken) as! String)",
            ]
        }

        AF.request(Constants.URLS.BASE_URL + strURL, method: .patch, parameters: params, encoding: URLEncoding.default, headers: headers, interceptor: interceptor ?? self).validate(statusCode: 200..<600).responseString(completionHandler: { (responseString: DataResponse) in
            debugPrint(responseString)
        }).responseData(completionHandler: {response in
            switch response.result{
            case .success(let res):
                success(JSON(res))
            case .failure(let error):
                failure(error)
            }
        })
    }
    
    func requestPUTURL(_ strURL: String, params: [String : Any]? = nil, headers: [String : String]? = nil, interceptor: RequestInterceptor? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        print("\(Constants.URLS.BASE_URL)\(strURL) request: \(params!)")
        
        var headers: HTTPHeaders = HTTPHeaders([:])
        if defaults.object(forKey: kAuthToken) != nil {
            headers = [
                "Authorization": "Bearer \(defaults.object(forKey: kAuthToken) as! String)",
            ]
        }

        AF.request(Constants.URLS.BASE_URL + strURL, method: .put, parameters: params, encoding: URLEncoding.default, headers: headers, interceptor: interceptor ?? self).validate(statusCode: 200..<600).responseString(completionHandler: { (responseString: DataResponse) in
            debugPrint(responseString)
        }).responseData(completionHandler: {response in
            switch response.result{
            case .success(let res):
                success(JSON(res))
            case .failure(let error):
                failure(error)
            }
        })
    }
}
