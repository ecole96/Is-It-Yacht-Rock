//
//  FirstViewController.swift
//  Yacht or Nyacht
//
//  Created by Evan Cole on 9/3/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import Alamofire

// class for "hub" of the app - recording screen
class RecordingViewController: UIViewController {
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    var spotifyToken: String?
    var lastTokenTime: Date?
    var expiresIn: Int?
    
    var _client: ACRCloudRecognition?
    
    // handling some exceptions in the database (typos that the ACRCloud API spits out / foreign artists)
    let specialArtists = ["矢野顕子":"Akiko Yano", "Larsen/Feitan Band":"Larsen/Feiten Band", "Larsen-Feiten Band":"Larsen/Feiten Band","松原正樹":"Masaki Matsubara","角松敏生":"Toshiki Kadomatsu","Daryl Hall And John Oates": "Daryl Hall & John Oates", "Seals & Crofts":"Seals and Crofts","Nielson & Pearson":"Nielsen/Pearson","Jim Messina":"Jimmy Messina","JaR (Jay Graydon & Randy Goodrum)":"JaR","England Dan Seals":"England Dan","B.B.&Q. Band":"The B. B. & Q. Band"]
    let specialTitles = ["いつか王子様が":"Someday My Prince May Come","Hill Street Blues":"Hill Street Blues Theme","WKRP In Cincinnati":"WKRP In Cincinatti Theme","Breezin'":"Breezin' 2006", "Isn't It Alway Love":"Isn't It Always Love", "Yah Mo B There":"Yah-Mo Be There"]
    var currentArtist: String? {
        didSet {
            for dict in specialArtists {
                if currentArtist == dict.key {
                    currentArtist = dict.value
                    break
                }
            }
        }
    }
    
    var acrid: String?
    var currentSong: String? {
        didSet {
            if currentSong?.range(of: "&amp;") != nil {
                currentSong = currentSong?.replacingOccurrences(of: "&amp;", with: "&")
            }
        
            for dict in specialTitles {
                if currentSong?.range(of: dict.key) != nil {
                    if dict.key == "Hill Street Blues" {
                        currentArtist = "Mike Post & Larry Carlton"
                    }
                    else if dict.key == "WKRP In Cincinatti" {
                        currentArtist = "Steve Carlisle"
                    }
                    else if dict.key == "Breezin'" {
                        if acrid == "9ae9475a62f696e08ccba74a30e94321" {
                            currentArtist = "George Benson & Al Jarreau"
                        }
                        else {
                            break
                        }
                    }
                    currentSong = dict.value
                    break
                }
            }
        }
    }
    
    // recording button flag
    var _currentlyRecording = false {
        didSet {
            if _currentlyRecording {
                recordButton.tintColor = UIColor.red
                recordingLabel.text = "Recording..."
            }
            else {
                recordButton.tintColor = UIColor.white
                recordingLabel.text = "Tap to Record"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let config = ACRCloudConfig();
        config.accessKey = readKey(key:"ACR_accessKey")
        config.accessSecret = readKey(key:"ACR_accessSecret")
        config.host = readKey(key:"ACR_host")
        //if you want to identify your offline db, set the recMode to "rec_mode_local"
        config.recMode = rec_mode_remote;
        config.audioType = "recording"
        config.requestTimeout = 10
        config.protocol = "http"
        config.keepPlaying = 2  //1 is restore the previous Audio Category when stop recording. 2 (default), only stop recording, do nothing with the Audio Category.
        config.resultBlock = {[weak self] result, resType in
            self?.handleResult(result!, resType:resType)
        }
        self._client = ACRCloudRecognition(config: config)
        
        spotifyToken = nil
        lastTokenTime = nil
        expiresIn = nil
    }
    
    // info button handler - move to info screen
    @IBAction func infoButton(_ sender: Any) {
        let vc = self
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let InfoViewController = storyBoard.instantiateViewController(withIdentifier: "InfoViewController")
        InfoViewController.navigationItem.title = "Info"
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        vc.navigationItem.backBarButtonItem = backItem
        vc.navigationController?.pushViewController(InfoViewController, animated: true)
    }
    
    // record button handler
    @IBAction func recordButton(_ sender: UIButton) {
        if(!_currentlyRecording) {
            self._client?.startRecordRec();
            self._currentlyRecording = true;
            print("Recording...")
        }
        else {
            self._client?.stopRecordRec()
            self._currentlyRecording = false;
            print("Stopped recording")
        }
    }
    
    // handler for ACRCloud results (song recognition)
    func handleResult(_ result: String, resType: ACRCloudResultType) -> Void
    {
        DispatchQueue.main.async {
            print(result);
            var moveToResultsPage = false
            if let data = result.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    let statusCode = json["status"]["code"].int
                    if statusCode == 0 {
                        // add song data
                        self.acrid = json["metadata"]["music"][0]["acrid"].string
                        self.currentArtist = json["metadata"]["music"][0]["artists"][0]["name"].string
                        self.currentSong = json["metadata"]["music"][0]["title"].string
                        moveToResultsPage = true
                        print(self.currentArtist!,"-",self.currentSong!)
                    }
                    else if statusCode == 1001 {
                        // no match found
                        print("No match")
                        self.createAlert(title:"No Match",message:"We couldn't recognize your audio.")
                    }
                    else {
                        // some error occurred
                        print("JSON returned an unsuccessful status code")
                        self.createAlert(title:"Recognition Error",message:"Something went wrong.")
                    }
                }
            }
            
            self._client?.stopRecordRec();
            
            if moveToResultsPage { // success - move to results page to display song info and Yachtski status
                self.searchDatabase() {
                    song in
                    self.saveRecord(song: song!)
                    transitionToResults(vc: self, song: song!)
                    self._currentlyRecording = false;
                }
            }
            else { // fail - remain on record screen
                self._currentlyRecording = false;
            }
            
        }
    }
    
    // attempt to match recorded song with song in database
    func searchDatabase(completion: @escaping (Song?) -> (Void)) {
        var song: Song?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let request = NSFetchRequest<DBEntry>(entityName: "DBEntry")
            request.fetchLimit = 1
            let artistPredicate = NSPredicate(format: "artist CONTAINS[cd] %@",currentArtist!)
            let simplifiedTitle = simplifyTitle(string:currentSong!)
            let titlePredicate = NSPredicate(format:"simplifiedTitle =[cd] %@",simplifiedTitle)
            request.predicate = NSCompoundPredicate(type: .and, subpredicates:[artistPredicate,titlePredicate])
            let fetch = try context.fetch(request)
            if let match = fetch.first {
                song = Song(title: match.title, artist:match.artist, yachtski: match.yachtski, show: match.show, jd: match.jd, steve: match.steve, hunter: match.hunter, dave: match.dave, imageURL: match.imageURL)
                completion(song)
            }
            else {
                print("Not in the database")
                var imageURL: String?
                getSpotifyInfo(artist: self.currentArtist!, title: simplifiedTitle) {
                    result in
                    imageURL = result
                    //print(imageURL as Any)
                    song = Song(title:self.currentSong!, artist:self.currentArtist!, yachtski:nil, show: nil, jd: nil, steve: nil, hunter: nil, dave: nil, imageURL: imageURL)
                    completion(song)
                }
            }
        }
        catch {
            print("Error - fetch task failed")
            song = Song(title:self.currentSong!, artist:self.currentArtist!, yachtski:nil, show: nil, jd: nil, steve: nil, hunter: nil, dave: nil, imageURL: nil)
            completion(song)
        }
    }
    
    // authorize Spotify API and get cover art (wrapper function for all the Spotify work)
    func getSpotifyInfo(artist: String, title: String, completion: @escaping (String?) -> (Void))  {
            var imageURL: String?
            if !self.spotifyIsAuthorized() {
                print("Authorizing Spotify Web API...")
                self.authorizeSpotify() {
                    response in
                    print("Authorized")
                    self.getImageURL(artist:self.currentArtist!, title: title) {
                        result in
                        imageURL = result
                        print("Cover art: ",imageURL as Any)
                        completion(imageURL)
                    }
                }
            }
            else {
                self.getImageURL(artist:self.currentArtist!, title: title) {
                    result in
                    imageURL = result
                    print("Cover art:",imageURL as Any)
                    completion(imageURL)
                }
            }
    }
    
    // search for song cover art using Spotify API
    func getImageURL(artist: String, title: String, completion: @escaping (String?)->(Void)) {
        var query_artist = artist
        for ch in ["&",",","$","+","=",":",";","/","?"] { // remove special chars
            if query_artist.contains(ch) {
                query_artist = query_artist.replacingOccurrences(of: ch, with: "")
            }
        }
        var query_string = query_artist + " " + title as String?
        query_string = query_string!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = "https://api.spotify.com/v1/search?q=" + query_string! + "&type=track&market=US&limit=1"
        let headers = ["Accept": "application/json",
                          "Content-Type": "application/json",
                          "Authorization": "Bearer " + self.spotifyToken!]
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            if let json = try? JSON(data: response.data!) {
                let results = json["tracks"]["items"]
                if results.count > 0 {
                    let imageURL = results[0]["album"]["images"][1]["url"].string
                    completion(imageURL)
                }
                else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
            
        }
    }
    
    // authorize Spotify API
    func authorizeSpotify(completion: @escaping (Any?) -> Void) {
        let auth_str = readKey(key:"spotify_auth")
        let auth_base64 = Data(auth_str.utf8).base64EncodedString()
        let parameters = ["grant_type": "client_credentials"]
        let headers = ["Authorization":"Basic " + auth_base64]
        // get auth key
        Alamofire.request("https://accounts.spotify.com/api/token",method: .post, parameters: parameters, headers: headers).responseJSON {
            response in
            if let json = try? JSON(data: response.data!) {
                self.spotifyToken = json["access_token"].string
                self.expiresIn = json["expires_in"].int
                self.lastTokenTime = Date() // remember authentication time (needed to determine if token has expired)
                completion(response.result.value)
            }
            else {
                completion(nil)
            }
        }
    }
    
    // determine if spotify API is authorized (for getting album art)
    func spotifyIsAuthorized() -> Bool {
        var spotifyIsAuthorized = false
        if spotifyToken != nil {
            if Date().timeIntervalSince(lastTokenTime!) < 3600 { // auth tokens expire every hour
                spotifyIsAuthorized = true
            }
        }
        return spotifyIsAuthorized
    }
    
    // save recorded song to core data
    func saveRecord(song: Song) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity=NSEntityDescription.entity(forEntityName: "HistoryEntry", in:context)
        let newRecord = NSManagedObject(entity: entity!, insertInto: context)
        let date = Date()
        newRecord.setValue(song.title,forKey:"title")
        newRecord.setValue(song.artist,forKey: "artist")
        newRecord.setValue(song.show,forKey:"show")
        newRecord.setValue(song.yachtski,forKey: "yachtski")
        newRecord.setValue(song.jd,forKey:"jd")
        newRecord.setValue(song.steve,forKey: "steve")
        newRecord.setValue(song.hunter,forKey:"hunter")
        newRecord.setValue(song.dave,forKey: "dave")
        newRecord.setValue(song.imageURL,forKey:"imageURL")
        newRecord.setValue(date,forKey:"date")
        do {
            try context.save()
            print("Record saved")
        } catch {
            print("Error saving record")
            print(error.localizedDescription)
        }
    }
    
    // create alert message (for failure message)
    func createAlert(title:String, message: String) {
        let alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
