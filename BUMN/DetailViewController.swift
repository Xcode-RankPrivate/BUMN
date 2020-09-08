//
//  DetailViewController.swift
//  BUMN
//
//  Created by JAN FREDRICK on 08/09/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController : UIViewController {
    
    let fSW = UIScreen.main.bounds.width
    let fSH = UIScreen.main.bounds.height
    let nTopSpace : CGFloat = 20 // top (iphone X <) spacing
    let cTopSpace : CGFloat = 44 // top (iphone X >=) spacing
    let bSA : CGFloat = 34 // bottom safe area
    
    var fullView : UIView!
    var topView : UILabel!
    var scrollView : UIScrollView!
    
    var imageOfMovie : UIImage!
    var nameOfMovie : String!
    var ratingsRelease : String!
    var dictToShow : JSON!
    
    var videoContainer : UILabel!
    
    override func viewDidLoad() {
        
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
        topView.text = "Movie Detail"
        
        let backB = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        topView.addSubview(backB)
        
        backB.setImage(UIImage(named: "back"), for: .normal)
        backB.addTarget(self, action: #selector(go_back(sender:)), for: .touchUpInside)
        topView.isUserInteractionEnabled = true
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 50, width: fSW, height: fullView.frame.height - 50 - 50))
        fullView.addSubview(scrollView)
        
        let mImage = UIImageView(frame: CGRect(x: 0, y: 0, width: fSW, height: fSW * 0.6))
        scrollView.addSubview(mImage)
        
        mImage.contentMode = .scaleAspectFit
        mImage.image = imageOfMovie
        
        var nextY = mImage.frame.height
        
        let titleL = UILabel(frame: CGRect(x: 10, y: nextY, width: fSW - 20, height: 80))
        scrollView.addSubview(titleL)
        
        titleL.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleL.textAlignment = .center
        titleL.numberOfLines = 0
        titleL.adjustsFontSizeToFitWidth = true
        titleL.text = nameOfMovie
        
        nextY += 80
        
        let ratingsL = UILabel(frame: CGRect(x: 0, y: nextY, width: fSW, height: 20))
        scrollView.addSubview(ratingsL)
        
        ratingsL.textAlignment = .center
        ratingsL.text = ratingsRelease
        ratingsL.font = UIFont.systemFont(ofSize: 14)
        ratingsL.adjustsFontSizeToFitWidth = true
        
        nextY += 20
        
        let descView = UITextView(frame: CGRect(x: 10, y: nextY, width: fSW - 20, height: scrollView.frame.height/4))
        scrollView.addSubview(descView)
        
        descView.text = dictToShow["overview"].stringValue
        descView.isEditable = false
        descView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        nextY += descView.frame.height + 10
        
        videoContainer = UILabel(frame: CGRect(x: 10, y: nextY, width: fSW - 20, height: fSW * 0.6))
        scrollView.addSubview(videoContainer)
        
        videoContainer.backgroundColor = .systemBlue
        videoContainer.textColor = .white
        videoContainer.layer.cornerRadius = 5.0
        videoContainer.layer.masksToBounds = true
        videoContainer.numberOfLines = 0
        videoContainer.textAlignment = .center
        
        if dictToShow["video"].boolValue == true {
            videoContainer.text = "Video Preview Available\nNot Implemented.."
        }else{
            videoContainer.text = "Video Preview\nNot Available!\n\nIf content is Youtube,\nwould use UIWebview."
        }
        
        nextY += videoContainer.frame.height + 10
        
        scrollView.contentSize = CGSize(width: fSW, height: nextY)
        
        let reviewsB = UIButton(frame: CGRect(x: 0, y: fullView.frame.height - 50, width: fSW, height: 50))
        fullView.addSubview(reviewsB)
        
        reviewsB.backgroundColor = .systemRed
        reviewsB.setTitle("User Reviews", for: .normal)
        reviewsB.addTarget(self, action: #selector(showReviews), for: .touchUpInside)
        
    }
    
    @objc func showReviews() {
        showError(title: "Sorry Unimplemented", msg: "Show Reviews would be the same as the tableview at home screen. The only difference is that reviews can be long or can be short. I would use a UIButton on each tableviewcell and set height of cell to 50. When user taps on cell, a popup will show the whole content of the review.", end: "Ok, I Understand.")
    }
    
    @objc func go_back(sender: UIButton) {
        print("to return")
        self.dismiss(animated: true, completion: nil)
    }
    
    func showError(title: String, msg: String, end: String = "OK") {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: end, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
}