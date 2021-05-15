//
//  REST.swift
//  Carangas
//
//  Created by Douglas Frari on 5/10/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Alamofire
import Foundation

enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

enum RESTOperation {
    case save
    case update
    case delete
}

class REST {
    
    // URL + endpoint
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    // URL TABELA FIPE
    private static let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
    
    // session criada automaticamente e disponivel para reusar
    private static let session = URLSession(configuration: configuration)
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 10.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()

    class func delete(car: Car, onComplete: @escaping (Bool) -> Void ) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete) { error in
            handleCarError(carError: error)
        }
    }

    class func update(car: Car, onComplete: @escaping (Bool) -> Void ) {
        applyOperation(car: car, operation: .update, onComplete: onComplete) { error in
            handleCarError(carError: error)
        }
    }
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void ) {
        applyOperation(car: car, operation: .save, onComplete: onComplete) { error in
            handleCarError(carError: error)
        }
    }

    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {

        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }

        AF.request(url).responseJSON { response in
            if response.error == nil {
                switch response.result {
                case .success(_):
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    }
                    catch {
                        onError(.invalidJSON)
                    }
                case .failure(_):
                    onError(.responseStatusCode(code: 500))
                }
            } else {
                onError(.taskError(error: response.error!))
            }
        }
    }

    // o metodo pode retornar um array de nil se tiver algum erro
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void, onError: @escaping (CarError) -> Void) {

        guard let url = URL(string: urlFipe) else {
            onComplete(nil)
            return
        }

        AF.request(url).responseJSON { response in
            if response.error == nil {
                switch response.result {
                case .success(_):
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    }
                    catch {
                        onError(.invalidJSON)
                    }
                case .failure(_):
                    onError(.responseStatusCode(code: 500))
                }
            } else {
                onError(.taskError(error: response.error!))
            }
        }
    } // fim do loadBrands

    class func applyOperation(
        car: Car,
        operation: RESTOperation,
        onComplete: @escaping (Bool) -> Void,
        onError: @escaping (CarError) -> Void
    ){
        // o endpoint do servidor para update é: URL/id
        let urlString = REST.basePath + "/" + (car._id ?? "")
        var httpMethod: HTTPMethod = .get

        switch operation {
        case .delete:
            httpMethod = .delete
        case .save:
            httpMethod = .post
        case .update:
            httpMethod = .put
        }

        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        guard (try? JSONEncoder().encode(car)) != nil else {
            onComplete(false)
            return
        }

        AF.request(
            url,
            method: httpMethod,
            parameters: car,
            encoder: JSONParameterEncoder.default
        ).response { response in
            if response.error == nil {
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200 {
                        onComplete(true)
                    } else {
                        onComplete(false)
                    }
                case .failure(_):
                    onComplete(false)
                }
            } else {
                onComplete(false)
            }
        }
    }

    final class func handleCarError(carError: CarError) {
        var errorMessage: String = ""

        switch carError {
        case .noData:
            errorMessage = "noData"
        case .noResponse:
            errorMessage = "noResponse"
        case .url:
            errorMessage = "InvalidURL"
        case .invalidJSON:
            errorMessage = "InvalidJSON"
        case .taskError(let error):
            errorMessage = "\(error.localizedDescription)"
        case .responseStatusCode(let code):
            if code != 200 {
                errorMessage = "Server error: [Error code: \(code)]"
            }
        }

        print(errorMessage)
    }
}
