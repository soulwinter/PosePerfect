//
//  NetworkManager.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/6.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    
    private init() {}
    
    var authToken: String?
    
    struct ServerResponse<T: Decodable>: Decodable {
        let success: Bool
        let errMsg: String?
        let data: T?
    }
    
    func createURL(with path: String, queryItems: [String: String]) -> URL? {
        var urlComponents = URLComponents(string: Constants.domain + path)
        urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents?.url
    }
    
    func postRequest<T: Decodable>(url: URL?, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("Response Status Code: \(statusCode)")
                if statusCode == 200 {
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let serverResponse = try decoder.decode(ServerResponse<UserData>.self, from: data)
                            
                            if serverResponse.success {
                                // 如果 success 为 true, 那么 data 应该是有值的
                                if T.self == EmptyParams.self {
                                    // 如果返回值本来就是空
                                    completion(.success(EmptyParams() as! T))
                                } else if let userData = serverResponse.data as? T {
    
                                    completion(.success(userData))
                                } else {
                                    completion(.failure(NSError(domain: "数据解析错误 2", code: 0, userInfo: nil)))
                                }
                            } else {
                                // 如果 success 为 false，那么 errMsg 应该是有值的，所以返回错误内容
                                completion(.failure(NSError(domain: serverResponse.errMsg ?? "未知错误", code: statusCode, userInfo: nil)))
                            }
                            
                        } catch {
                            completion(.failure(NSError(domain: "数据解析错误 1", code: 0, userInfo: nil)))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "网络错误", code: statusCode, userInfo: nil)))
                }
                

            }
        }
        task.resume()
    }
    
    // Get the verification code method,
    // EmptyParams: no return data
    func getVerificationCode(phoneNumber: String, completion: @escaping (Result<EmptyParams, Error>) -> Void) {
        let url = createURL(with: "/user/code", queryItems: ["telephone": phoneNumber])
        postRequest(url: url, completion: completion)
    }
    
    
    

    
    struct UserData: Decodable {
        let id: Int
        let nickname: String
    }
    func loginWithCode(phoneNumber: String, code: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let url = createURL(with: "/user/loginWithCode", queryItems: ["telephone": phoneNumber, "code": code])
        postRequest(url: url, completion: completion)
    }
    
    
}

// For requests without parameters
struct EmptyParams: Decodable {}
