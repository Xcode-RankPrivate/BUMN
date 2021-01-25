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
import SkeletonView

let api_key = "0cb44612369f23a470eb49084edad991"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var genres : NSArray = []
    var moviesToShow : NSMutableArray = []
    
    var genreButtons : NSArray = []
    
    let hud = JGProgressHUD(style: .dark)
    
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
        movieListTV.register(MLCell.self, forCellReuseIdentifier: "cell")
        
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
        
        let getMoviesListAPI = "https://api.themoviedb.org/3/discover/movie?api_key=\(api_key)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=true&page=\(pageNum)&with_genres=\(genreID)"
        print(getMoviesListAPI)
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
    
    var dictToSend : JSON!
    var imageToSend : UIImage!
    var nameToSend : String!
    var ratingsToSend : String!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! MLCell
        
        dictToSend = cell.dict
        imageToSend = cell.imageV.image
        nameToSend = cell.titleL.text
        ratingsToSend = cell.releaseDateL.text
        
        performSegue(withIdentifier: "to_detail", sender: self)
        
    }
    
    let imageAPI = "https://image.tmdb.org/t/p/w500"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MLCell
        
        cell.selectionStyle = .none
        
        cell.dict = JSON(moviesToShow[indexPath.row])
        
        downloadImage(from: URL(string: "\(imageAPI)\(cell.dict["poster_path"].stringValue)")!, iV: cell.imageV)
        
        if cell.dict["title"].stringValue == cell.dict["original_title"].stringValue {
            cell.titleL.text = cell.dict["title"].stringValue
        }else{
            cell.titleL.text = cell.dict["title"].stringValue + " (\(cell.dict["original_title"].stringValue))"
        }
        
        cell.releaseDateL.text = "Ratings : \(cell.dict["vote_average"].stringValue.prefix(3)) Released on : \(cell.dict["release_date"].stringValue)"
        
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    let userDefaults = UserDefaults.standard
    
    func downloadImage(from url: URL, iV: UIImageView) {
        
        if userDefaults.object(forKey: "\(url.absoluteString)") != nil {
            iV.image = UIImage(data: userDefaults.object(forKey: "\(url.absoluteString)") as! Data)
            print("from userdefaults")
            return
        }
        
        print("Download Started")
        
        getData(from: url) { (data, response, error) in
            if error == nil {
                print("should show image")
                DispatchQueue.main.async {
                    self.userDefaults.set(data, forKey: "\(url.absoluteString)")
                    iV.image = UIImage(data: data!)
                }
            }else{
                print("image error -> \(error!.localizedDescription) : \(url)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_detail" {
            let nvc = segue.destination as! DetailViewController
            nvc.dictToShow = dictToSend
            nvc.imageOfMovie = imageToSend
            nvc.nameOfMovie = nameToSend
            nvc.ratingsRelease = ratingsToSend
        }
        
    }

}

class GButton : UIButton {
    var gID : String!
}

class MLCell : UITableViewCell {
    
    var dict : JSON!
    var imageV : UIImageView!
    var titleL, releaseDateL : UILabel!
    
    var fWidth = UIScreen.main.bounds.width - 40
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageV = UIImageView(frame: CGRect(x: 10, y: 10, width: 120, height: 80))
        contentView.addSubview(imageV)
        
        imageV.contentMode = .scaleAspectFill
        imageV.layer.masksToBounds = true
        
        titleL = UILabel(frame: CGRect(x: 140, y: 10, width: fWidth - 150, height: 60))
        contentView.addSubview(titleL)
        
        titleL.numberOfLines = 0
        titleL.font = UIFont.systemFont(ofSize: 15)
        titleL.adjustsFontSizeToFitWidth = true
        
        releaseDateL = UILabel(frame: CGRect(x: 140, y: 70, width: fWidth - 150, height: 20))
        contentView.addSubview(releaseDateL)
        
        releaseDateL.textAlignment = .right
        releaseDateL.font = UIFont.systemFont(ofSize: 14)
        releaseDateL.adjustsFontSizeToFitWidth = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
