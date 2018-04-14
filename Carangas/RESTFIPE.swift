//
//  RESTFIPE.swift
//  Carangas
//
//  Created by Usuário Convidado on 14/04/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

enum BrandErro {
    case url
    case noResponse
    case noData
    case invalodJSON
    case taskErro(erro: NSError)
    case responseStatusCode(cod: Int)
}



class RESTFIPE {
    private static let basePath = "http://fipeapi.appspot.com/api/1/carros/marcas.json"
    private static let configuration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        //liberando dados 3G
        config.allowsCellularAccess = true
        
        //Liberando json
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        // quanto tempo o app vai aguardar a requisição/ chamada
        config.timeoutIntervalForRequest = 40.0
        
        // limite de conexões por sessão
        config.httpMaximumConnectionsPerHost = 4
        
        return config
    }()
    private static let session = URLSession(configuration: configuration)
    
    
    // @escaping segura a variavel até que toda a função termine
    class func loadBrands(onComplete: @escaping ([FIPE]) -> Void, onError: @escaping (BrandErro) -> Void){
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                onError(.taskErro(erro: error! as NSError))
            } else {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                
                if response.statusCode == 200{
                    
                    guard let data = data else {
                        onError(.noData)
                        return
                    }
                    do {
                        let cars = try JSONDecoder().decode([FIPE].self, from: data)
                        onComplete(cars)
                    } catch {
                        onError(.invalodJSON)
                    }
                    
                    
                    
                } else {
                    onError(.responseStatusCode(cod: response.statusCode))
                }
                
            }
        }
        dataTask.resume()
    }
    
    
    
    
}
