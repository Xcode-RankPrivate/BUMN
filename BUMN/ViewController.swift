//
//  ViewController.swift
//  BUMN
//
//  Created by JAN FREDRICK on 07/09/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JGProgressHUD

class ViewController: UIViewController {

    var genres : NSArray = []
    var moviesToShow : NSArray = []
    
    let api_key = "0cb44612369f23a470eb49084edad991"
    
    let hud = JGProgressHUD(style: .dark)
    
    let defaults = UserDefaults.standard
    
    let fSW = UIScreen.main.bounds.width
    let fSH = UIScreen.main.bounds.height
    let nTopSpace = 20 // top (iphone X <) spacing
    let cTopSpace = 44 // top (iphone X >=) spacing
    let bSA = 34 // bottom safe area
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getSetGenres()
        
        
        
    }
    
    func getMoviesBasedOnGenre(genreID: String, pageNum: String) {
        let getMoviesListAPI = "https://api.themoviedb.org/3/discover/movie?api_key=\(api_key)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(pageNum)&with_genres=\(genreID)"
        
        AF.request(getMoviesListAPI).responseJSON(completionHandler: { (response) in
            
            switch response.result {
            case .success:
                // get json
                let jsonData = JSON(response.data!)
                
                print(jsonData)
                break
            case .failure(let error):
                print("error -> \(error.localizedDescription)")
                break
            }
            
        })
    }
    
    func getSetGenres() {
        
        let getGenresAPI = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(api_key)&language=en-US"
        
        AF.request(getGenresAPI).responseJSON(completionHandler: { (response) in
            
            switch response.result {
            case .success:
                // get json
                let jsonData = JSON(response.data!)
                
                self.genres = jsonData["genres"].array! as NSArray
                
                print(jsonData)
                break
            case .failure(let error):
                // error
                print("error -> \(error.localizedDescription)")
                break
                
            }
            
        })
    }


}

