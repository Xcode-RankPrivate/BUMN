//
//  ReviewsViewController.swift
//  BUMN
//
//  Created by JAN FREDRICK on 24/01/21.
//  Copyright © 2021 JFSK. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReviewsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var reviewsArrayToShow : [JSON] = []
    
    let fSW = UIScreen.main.bounds.width
    let fSH = UIScreen.main.bounds.height
    let nTopSpace : CGFloat = 20 // top (iphone X <) spacing
    let cTopSpace : CGFloat = 44 // top (iphone X >=) spacing
    let bSA : CGFloat = 34 // bottom safe area
    
    var fullView : UIView!
    var topView : UILabel!
    var reviewsListTV : UITableView!
    
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
        topView.text = "Movie Reviews"
        
        let backB = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        topView.addSubview(backB)
        
        backB.setImage(UIImage(named: "back"), for: .normal)
        backB.addTarget(self, action: #selector(go_back(sender:)), for: .touchUpInside)
        topView.isUserInteractionEnabled = true
        
        let finalY : CGFloat = 50 + 20
        
        reviewsListTV = UITableView(frame: CGRect(x: 20, y: finalY, width: fSW - 40, height: fullView.frame.height - finalY))
        fullView.addSubview(reviewsListTV)
        
        reviewsListTV.delegate = self
        reviewsListTV.dataSource = self
        reviewsListTV.register(RLCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    @objc func go_back(sender: UIButton) {
        print("to return")
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArrayToShow.count
    }
    
    let avatarAPI = "https://secure.gravatar.com/avatar"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RLCell
        
        cell.selectionStyle = .none
        
        cell.dict = reviewsArrayToShow[indexPath.row]
        
        downloadImage(from: URL(string: "\(avatarAPI)\(cell.dict["author_details"]["avatar_path"].stringValue)")!, iV: cell.imageV)
        
        cell.nameL.text = cell.dict["author"].stringValue + "\n(Tap to read review)"
        
        if cell.dict["author_details"]["rating"].stringValue != "" {
            cell.releaseDateL.text = "Ratings : \(cell.dict["author_details"]["rating"].stringValue)"//" Released on : \(cell.dict["updated_at"].stringValue)"
        }else{
            cell.releaseDateL.text = "No Ratings"
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! RLCell
        
        let alertVC = UIAlertController(title: "\(cell.dict["author"]) says :", message: "\(cell.dict["content"])", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Oh, I See", style: .default, handler: nil))
        present(alertVC, animated: false, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func downloadImage(from url: URL, iV: UIImageView) {
        
        print("Download Started")
        
        getData(from: url) { (data, response, error) in
            if error == nil {
                print("should show image")
                DispatchQueue.main.async {
                    iV.image = UIImage(data: data!)
                }
            }else{
                print("image error -> \(error!.localizedDescription) : \(url)")
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}

class RLCell : UITableViewCell {
    
    var dict : JSON!
    var imageV : UIImageView!
    var nameL, releaseDateL : UILabel!
    
    var fWidth = UIScreen.main.bounds.width - 40
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageV = UIImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
        contentView.addSubview(imageV)
        
        imageV.layer.cornerRadius = 40.0
        imageV.contentMode = .scaleAspectFit
        imageV.layer.masksToBounds = true
        
        nameL = UILabel(frame: CGRect(x: 100, y: 10, width: fWidth - 150, height: 40))
        contentView.addSubview(nameL)
        
        nameL.numberOfLines = 0
        nameL.font = UIFont.systemFont(ofSize: 20)
        nameL.adjustsFontSizeToFitWidth = true
        
        releaseDateL = UILabel(frame: CGRect(x: 100, y: 50, width: fWidth - 150, height: 40))
        contentView.addSubview(releaseDateL)
        
        releaseDateL.textAlignment = .right
        releaseDateL.font = UIFont.systemFont(ofSize: 18)
        releaseDateL.adjustsFontSizeToFitWidth = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
