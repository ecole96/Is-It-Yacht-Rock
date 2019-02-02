//
//  ResultViewController.swift
//  Yacht or Nyacht
//
//  Created by Evan Cole on 9/5/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import UIKit
import CoreData

// class for results page
class ResultViewController: UIViewController {
    
    var song: Song!
    
    @IBOutlet weak var coverArt: UIImageView!
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var yachtOrNyacht: UILabel!
    @IBOutlet weak var yachtskiLabel: UILabel!
    @IBOutlet weak var details: UITextView!
    
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var hunterLabel: UILabel!
    @IBOutlet weak var jdLabel: UILabel!
    @IBOutlet weak var steveLabel: UILabel!
    @IBOutlet weak var daveLabel: UILabel!
    
    override func viewDidLoad() {
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        var resultText = "Unknown"
        var yachtskiScoreText = "Yachtski Score: N/A"
        var showText = "N/A"
        var jdText = "N/A"
        var hunterText = "N/A"
        var steveText = "N/A"
        var daveText = "N/A"
        
        if song.yachtski != nil {
            if song.yachtski! >= 50 {
                resultText = "YACHT"
            }
            else {
                resultText = "NYACHT"
            }
            
            showText = song.show!
            jdText = String(format:"%.2f",song.jd!)
            hunterText = String(format:"%.2f",song.hunter!)
            steveText = String(format:"%.2f",song.steve!)
            daveText = String(format:"%.2f",song.dave!)
            
            yachtskiScoreText = "Yachtski Score: " + String(format: "%.2f",song.yachtski!) + "/100"
        }
        
        if song.imageURL != nil {
            coverArt.sd_setImage(with: URL(string: song.imageURL!), placeholderImage: #imageLiteral(resourceName: "coverart-placeholder"))
        }
        else {
            let img = #imageLiteral(resourceName: "coverart-placeholder")
            coverArt.image = img
        }
        
        self.songLabel.text = song.title
        //songLabel.sizeToFit()
        self.artistLabel.text = song.artist
        self.yachtOrNyacht.text = resultText
        self.yachtOrNyacht.textColor = scoreLabelColor(score: song.yachtski)
        self.yachtskiLabel.text = yachtskiScoreText
        self.showLabel.text = showText
        self.hunterLabel.text = hunterText
        self.hunterLabel.textColor = scoreLabelColor(score: song.hunter)
        self.jdLabel.text = jdText
        self.jdLabel.textColor = scoreLabelColor(score:song.jd)
        self.steveLabel.text = steveText
        self.steveLabel.textColor = scoreLabelColor(score:song.steve)
        self.daveLabel.text = daveText
        self.daveLabel.textColor = scoreLabelColor(score:song.dave)
        
        self.details.text = getDetails()
        details.layer.cornerRadius = 20
        details.layer.borderColor = UIColor.white.cgColor
        details.layer.borderWidth = 2.0
    }
    
    func getDetails() -> String {
        // judge song based on yachtski score - this is the text in the details box
        let thresholds = [(85,"essential yacht rock."), (65, "certified yacht rock."), (50,"yacht rock, but not strongly so."), (45, "almost yacht rock, but something's holding it back to keep it nyacht.")]
        var text = "This song is "
        if song.yachtski != nil {
            for (tier, description) in thresholds {
                if song.yachtski! >= Float(tier) {
                    text += description
                    return text
                }
            }
            text += "definitively nyacht rock." }
        else {
            text += "not in the Yacht or Nyacht database." }
        return text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Results"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

@IBDesignable
class RoundUIView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}
