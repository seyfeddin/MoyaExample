//
//  ViewController.swift
//  MoyaExample
//
//  Created by Seyfeddin Bassarac on 24/08/2017.
//  Copyright © 2017 ThreadCo. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let provider = MoyaProvider<ITunesAPI>()

        provider.request(.search(term: "Aleyna Tilki")) { result in
            switch result {
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    // JSON burada, hazır!
                }
                catch MoyaError.statusCode(let errorResponse) {
                    // Status Code 4**/5** Hatalarını burada alıyoruz
                } catch {
                    // Diğer hataları burada alıyoruz

                }
            case .failure(let error):
                // İnternet bağlantısı yoktur, zaman aşımına uğrama hataları burada alınıyor

                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

