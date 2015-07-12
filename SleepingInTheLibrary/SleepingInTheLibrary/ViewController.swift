//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 1/26/15.
//  Copyright (c) 2015 Udacity. All rights reserved.

//  Converted to support xcode 7 and new swift version

import UIKit

/* 1 - Define constants */
let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.galleries.getPhotos"
let API_KEY = "YOUR_API_KEY_HERE"
let GALLERY_ID = "5704-72157622566655097"
let EXTRAS = "url_m"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"

class ViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    
    @IBAction func touchRefreshButton(sender: AnyObject) {
        getImageFromFlickr()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getImageFromFlickr() {
        
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "gallery_id": GALLERY_ID,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)", appendNewline: false)
            } else {
                /* 5 - Success! Parse the data */
                var parsingError: NSError? = nil
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch var error as NSError {
                    parsingError = error
                    parsedResult = nil
                } catch {
                    fatalError()
                }
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        
                        /* 6 - Grab a single, random image */
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        
                        /* 7 - Get the image url and title */
                        let photoTitle = photoDictionary["title"] as? String
                        let imageUrlString = photoDictionary["url_m"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        
                        /* 8 - If an image exists at the url, set the image and title */
                        if let imageData = NSData(contentsOfURL: imageURL!) {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photoImageView.image = UIImage(data: imageData)
                                self.photoTitle.text = photoTitle
                            })
                        } else {
                            print("Image does not exist at \(imageURL)", appendNewline: false)
                        }
                    } else {
                        print("Cant find key 'photo' in \(photosDictionary)", appendNewline: false)
                    }
                } else {
                    print("Cant find key 'photos' in \(parsedResult)", appendNewline: false)
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task!.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + "&".join(urlVars)
    }
}