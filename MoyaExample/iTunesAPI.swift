//
//  iTunesAPI.swift
//  MoyaExample
//
//  Created by Seyfeddin Bassarac on 24/08/2017.
//  Copyright © 2017 ThreadCo. All rights reserved.
//

import Foundation
import Moya

enum ITunesAPI {
    case search(term: String)
    case login(email: String, password: String)
}
// AccessTokenAuthorizable protokolü token göndermek isteyip istemediğimizi belirleyen değeri içeriyor (shouldAuthorize)
extension ITunesAPI: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: "https://itunes.apple.com/")! }

    var path: String {
        switch self {
        case .search:
            return "search"
        case .login:
            return "login"
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .search(let term):
            return ["term" : term]
        case .login(let email, let password):
            return [:]
        }
    }

    var method: Moya.Method {
        switch self {
        case .search(let term):
            return .get
        case .login(let email, let password):
            return .post
        }
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.queryString
    }

    var sampleData: Data {
        return "".data(using: .utf8)!
    }

    var task: Task {
        return .request
    }

    var shouldAuthorize: Bool {
        switch self {
        case .login:
            return false
        default:
            return false
        }
    }

}
