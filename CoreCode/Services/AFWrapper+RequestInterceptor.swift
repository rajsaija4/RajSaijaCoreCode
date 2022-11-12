//
//  AFWrapper+RequestInterceptor.swift
//  AFWrapper_5.0
//
//  companyName on 02/06/21.
//

import Alamofire
extension AFWrapper: RequestInterceptor {

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        guard let token = defaults.object(forKey: kAuthToken) else {
            completion(.success(urlRequest))
            return
        }
        let bearerToken = "Bearer \(token)"
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        print("\nadapted; token added to the header field is: \(bearerToken)\n")
        completion(.success(request))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }
        print("\nretried; retry count: \(request.retryCount)\n")
        completion(.retry)
    }
}


