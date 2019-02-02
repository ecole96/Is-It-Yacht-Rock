//
//  IsItYacht.swift
//  IsItYacht
//
//  Created by Evan Cole on 9/7/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import Foundation
import UIKit

// helper function for simplifyTitle - only want alphanumeric characters in the title
func removeSpecialCharsFromString(text: String) -> String {
    let okayChars : Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890()[]-".characters)
    return String(text.characters.filter {okayChars.contains($0) })
}

// ACRCloud often spits out extra data in song titles, enclosed in brackets and the like - ex: [Single Version] and/or (feat. X)
// removes bracket/parentheses tags for better matching to songs in the database
func simplifyTitle(string: String) -> String {
    let simplifiedTitle = removeSpecialCharsFromString(text: string).replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression).replacingOccurrences(of: "\\s?\\[[\\w\\s]*\\]", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    return simplifiedTitle
}

// trim whitespace for search function (removes leading/trailing whitespace, removes all but one space between words)
func trimWhitespace(string: String) -> String {
    let sp = string.components(separatedBy: " ")
    var words: [String] = []
    for item in sp {
        if item != "" {
            words.append(item)
        }
    }
    let trimmedString = words.joined(separator: " ")
    return trimmedString
}

// calculate color of Yachtski label (higher = greener, lower = redder)
func scoreLabelColor(score: Float?) -> UIColor {
    var color: UIColor
    if score != nil {
        var r = 255 as Float
        var g = 0 as Float
        let b = 0 as Float
        if score! <= 50 {
            g = score!*(255/50)
        }
        else {
            r = 255 - ((score! - 50) * (255/50))
            g = 255
        }
        color =  UIColor(red:CGFloat(r/255),green:CGFloat(g/255),blue:CGFloat(b),alpha:1.0)
    }
    else {
        color = UIColor.white
    }
    return color
}

// move from one of the three preliminary screens (record, history, search) to results
func transitionToResults(vc: AnyObject, song: Song) {
    if vc is RecordingViewController || vc is HistoryViewController || vc is DBViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        resultViewController.song = song
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        vc.navigationItem.backBarButtonItem = backItem
        vc.navigationController??.pushViewController(resultViewController, animated: true)
    }
    else {
        return
    }
}

// read protected API keys from plist file - 'key' parameter is the key that we want, returns the value of that key
func readKey(key: String) -> String {
    let path = Bundle.main.path(forResource: "keys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: path!)
    let value = plist?.object(forKey:key) as! String
    return value
}

