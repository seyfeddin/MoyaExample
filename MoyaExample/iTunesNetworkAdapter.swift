//
//  iTunesNetworkAdapter.swift
//  MoyaExample
//
//  Created by Seyfeddin Bassarac on 25/08/2017.
//  Copyright © 2017 ThreadCo. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

/* Appin herhangi bir yerinden kolayca request atabilmek için jenerik bir metod oluşturdum. Hem hataları filtrelemek, hem de JSON parse edebilme işlemlerini tekrar tekrar yapmamış oluyorum bu şekilde. Malumunuz, en iyi kod olmayan koddur :)
 */

final class ITunesNetworkAdapter {
    
    @discardableResult static public func request(
        target: ITunesAPI,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (_ message : String, _ statusCode: Int) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
        ) -> Cancellable {

        // Attığımız istekleri ve cURL outputunu almak için NetworkLogger Plugin oluşturuyoruz
        let networkLoggerPlugin = NetworkLoggerPlugin(cURL: true)

        // Plugin arrayi
        var pluginsArray:[PluginType] = [networkLoggerPlugin]

        /* Header'da Bearer: {token} göndermek için bir access token plugin oluşturabiliriz. 
         Diğer Auth yöntemleri için başka pluginler de var, kendimiz de yapabiliriz. Hangi requestte token gödnerileceğini de iTunesAPI'de shouldAuthorize'da belirliyoruz. 
         */
        let tokenPlugin = AccessTokenPlugin(token: "ashfjaksfbalkshf")
        pluginsArray.append(tokenPlugin)

        // Plugin arrayini requesti atan MoyaProvider'ı initialize ederken paslıyoruz
        let provider = MoyaProvider<ITunesAPI>(plugins: pluginsArray)

        return provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    // Hata yakalayamazsam başarıyla oluşan JSON'ı success callback metoduna paslıyorum, iyi günlerde kullan view controller.
                    successCallback(json)
                }
                catch MoyaError.statusCode(let errorResponse) {
                    // Status Code hatası yakalarsam errorCallback'e statusCode ile beraber paslıyorum, requesti atan ekran hata mesajını UI'da gösterebilir istediği gibi
                        errorCallback(errorResponse.description, errorResponse.statusCode)
                } catch MoyaError.underlying(let nsError) {
                    // Başka hata yakalarsam errorCallback'e statusCode ile beraber paslıyorum.
                    let error = nsError as NSError
                    errorCallback(error.localizedDescription, 0)
                } catch {
                    // Buraya hiç düşmüyor aslında ama Swift ErrorType'ın cilvesi yüzünden burada.
                    errorCallback("error", 0)

                }
            case let .failure(error):
                // İnternet bağlantı hatası, timeout gibi hataları da request tam gitmedi ki dönesin diyerek ayrı bir failure block'una paslıyorum. Burada da internet bağlantın yok diye ayrı bir UI çıkartabiliyoruz, ya da offline moda geçebiliyoruz (bazı applerde)
                failureCallback(error)
            }
        }
    }
}
