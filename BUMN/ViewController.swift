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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var genres : NSArray = []
    var moviesToShow : NSMutableArray = []
    
    var genreButtons : NSArray = []
    
    let api_key = "0cb44612369f23a470eb49084edad991"
    
    let hud = JGProgressHUD(style: .dark)
    
    let defaults = UserDefaults.standard
    
    let fSW = UIScreen.main.bounds.width
    let fSH = UIScreen.main.bounds.height
    let nTopSpace : CGFloat = 20 // top (iphone X <) spacing
    let cTopSpace : CGFloat = 44 // top (iphone X >=) spacing
    let bSA : CGFloat = 34 // bottom safe area
    
    var fullView : UIView!
    var topView : UILabel!
    var genreSV : UIScrollView!
    var movieListTV : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        if fSH >= 812 {
            fullView = UIView(frame: CGRect(x: 0, y: cTopSpace, width: fSW, height: fSH - cTopSpace - bSA))
        }else{
            fullView = UIView(frame: CGRect(x: 0, y: nTopSpace, width: fSW, height: fSH - nTopSpace))
        }
        view.addSubview(fullView)
        
        topView = UILabel(frame: CGRect(x: 0, y: 0, width: fSW, height: 50))
        fullView.addSubview(topView)
        
        topView.backgroundColor = .systemBlue
        topView.textAlignment = .center
        topView.textColor = .white
        topView.text = "Select Movie Genre"
        
        genreSV = UIScrollView(frame: CGRect(x: 20, y: 50 + 20, width: fSW - 40, height: 40))
        fullView.addSubview(genreSV)
        
        getSetGenres()
        
        let finalY : CGFloat = 50 + 20 + 40 + 20
        
        movieListTV = UITableView(frame: CGRect(x: 20, y: finalY, width: fSW - 40, height: fullView.frame.height - finalY))
        fullView.addSubview(movieListTV)
        
        movieListTV.delegate = self
        movieListTV.dataSource = self
        
    }
    
    var no_moviesLeft = false
    
    func getMoviesBasedOnGenre(genreID: String, pageNum: Int) {
        
        if no_moviesLeft == true {
            return
        }
        
        if pageNum == 1 {
            hud.textLabel.text = "retreiving movies.."
            hud.show(in: view)
        }
        
        let getMoviesListAPI = "https://api.themoviedb.org/3/discover/movie?api_key=\(api_key)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(pageNum)&with_genres=\(genreID)"
        
        AF.request(getMoviesListAPI).responseJSON(completionHandler: { (response) in
            
            self.hud.dismiss()
            self.is_fetchingMovies = false
            
            switch response.result {
            case .success:
                // get json
                let jsonData = JSON(response.data!)
                
                if jsonData["results"].arrayValue.count == 0 {
                    //some sort of error appears, best solution to set no_moviesLeft = true
                    self.no_moviesLeft = true
                }else{
                    self.moviesToShow.addObjects(from: jsonData["results"].arrayValue)
                    self.movieListTV.reloadData()
                    
                    //no more movies to fetch, should stop fetching
                    if jsonData["page"].intValue >= jsonData["total_pages"].intValue {
                        self.no_moviesLeft = true
                    }
                    
                }
                
                print(jsonData)
                print("Total movies present = \(self.moviesToShow.count)")
                break
            case .failure(let error):
                print("error -> \(error.localizedDescription)")
                break
            }
            
        })
    }
    
    func getSetGenres() {
        
        hud.textLabel.text = "retreiving genres.."
        hud.show(in: view)
        
        let getGenresAPI = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(api_key)&language=en-US"
        
        AF.request(getGenresAPI).responseJSON(completionHandler: { (response) in
            
            self.hud.dismiss()
            
            switch response.result {
            case .success:
                // get json
                
                let jsonData = JSON(response.data!)
                
                self.genres = jsonData["genres"].array! as NSArray
                
                self.setupGenres(array: self.genres)
                
                print(jsonData)
                break
            case .failure(let error):
                // error
                print("error -> \(error.localizedDescription)")
                self.showError(title: "Genre List", msg: error.localizedDescription)
                break
                
            }
            
        })
    }
    
    func setupGenres(array: NSArray) {
        
        for subview in genreSV.subviews {
            subview.removeFromSuperview()
        }
        
        let cellWidth : CGFloat = 90
        let cellHeight : CGFloat = 40
        var originX : CGFloat = 0
        let cellSpacing : CGFloat = 10
        
        for i in 0..<array.count {
            
            let dict = JSON(array[i])
            
            let gB = GButton(frame: CGRect(x: originX, y: 0, width: cellWidth, height: cellHeight))
            genreSV.addSubview(gB)
            
            gB.backgroundColor = .systemBlue
            gB.setTitle(dict["name"].stringValue, for: .normal)
            gB.titleLabel?.adjustsFontSizeToFitWidth = true
            gB.titleLabel?.numberOfLines = 0
            gB.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            gB.gID = dict["id"].stringValue
            gB.addTarget(self, action: #selector(retreiveMovies(sender:)), for: .touchUpInside)
            
            originX += cellWidth + cellSpacing
        }
        
        genreSV.contentSize = CGSize(width: originX - cellSpacing, height: cellHeight)
        
    }
    
    var pageNumNow = 1
    var genreIDNow = ""
    
    @objc func retreiveMovies(sender: GButton) {
        pageNumNow = 1
        genreIDNow = sender.gID
        
        moviesToShow.removeAllObjects()
        
        //just start getting movies from page 1
        no_moviesLeft = false
        
        getMoviesBasedOnGenre(genreID: sender.gID, pageNum: pageNumNow)
    }
    
    func showError(title: String, msg: String, end: String = "OK") {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: end, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }

    ///MARK - TABLE VIEW DELEGATES
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesToShow.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MLCell()
        
        cell.selectionStyle = .none
        
        cell.dict = moviesToShow[indexPath.row] as? NSDictionary
        
        
        
        return cell
    }
    
    var is_fetchingMovies = false
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= (pageNumNow * 20) - 5 && is_fetchingMovies == false  {
            print("please wait..1")
            is_fetchingMovies = true
            pageNumNow += 1
            
            getMoviesBasedOnGenre(genreID: genreIDNow, pageNum: pageNumNow)
            
        }else if indexPath.row == moviesToShow.count - 1 {
            print("please wait..2")
        }
        
    }

}

class GButton : UIButton {
    var gID : String!
}

class MLCell : UITableViewCell {
    
    var dict : NSDictionary!
    
    var releaseDateL : UILabel!
    
    let fSW = UIScreen.main.bounds.width
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView!.frame = CGRect(x: 10, y: 10, width: 120, height: 80)
        
        imageView?.contentMode = .scaleAspectFill
        
        textLabel!.frame = CGRect(x: 140, y: 10, width: fSW - 150, height: 60)
        
        textLabel?.numberOfLines = 0
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        releaseDateL = UILabel(frame: CGRect(x: 140, y: 70, width: fSW - 150, height: 20))
        contentView.addSubview(releaseDateL)
        
        releaseDateL.textAlignment = .right
        releaseDateL.font = UIFont.systemFont(ofSize: 14)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
