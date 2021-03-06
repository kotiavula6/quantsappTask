//
//  ViewController.swift
//  QuantsAppTask
//
//  Created by avula koti on 11/02/20.
//  Copyright © 2020 avula koti. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController,UITextViewDelegate {
    var feedsArray = [Feeds]()
    
        //MARK:- Outlets
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            self.tableview.rowHeight = UITableView.automaticDimension
        }
    }
        //MARK:- Application LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getFeed()
        pinchgestures()
    }
    
        //MARK:- Functions
    func  getFeed() {
        let url = URL(string: "https://api.androidhive.info/feed/feed.json")
        URLSession.shared.dataTask(with: url!){ (data, response, error)
            in
            guard let data = data else {
                return
            }
            do {
                let json = try JSON(data:data)
                let results = json["feed"]
                print(json)
                //  print(results)
                for array in results.arrayValue {
                    self.feedsArray.append(Feeds(json: array))
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                        self.tableview.delegate = self
                        self.tableview.dataSource = self
                    }
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

        //MARK:- Extension TableViewCell
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "customTableViewCell") as! customTableViewCell
        cell.urlText.text = (feedsArray[indexPath.row].url!!)
        cell.urlText.textColor = randomColor()
        cell.nameLabel.text = (feedsArray[indexPath.row].name!!)
        cell.statusLabel.text = (feedsArray[indexPath.row].status!!)
        cell.statusLabel.numberOfLines = 0
        cell.timeLabel.text = (feedsArray[indexPath.row].timeStamp!!)
        
        //MARK:- Time Stamp
        if let lastUpdated: String = (feedsArray[indexPath.row].timeStamp!){
            let epocTime = TimeInterval(lastUpdated)! / 1000
            let unixTimestamp = NSDate(timeIntervalSince1970: epocTime)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone() as TimeZone?
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.date(from: String(describing: unixTimestamp))
            let updatedTimeStamp = unixTimestamp
            let cellDate = DateFormatter.localizedString(from: updatedTimeStamp as Date, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.medium)
            
            cell.timeLabel.text = cellDate
        }
        
        cell.profilePicImage.sd_setImage(with: URL(string: (feedsArray[indexPath.row].profilepic!!)), placeholderImage: UIImage(named: "ProfilePlaceholder"))
        
        
        cell.feedImage.sd_setImage(with: URL(string:(feedsArray[indexPath.row].image!!)), placeholderImage: UIImage(named: "FeedPlaceHolder"))

        return cell
    }

}

        //MARK:- Gestures

extension ViewController {
    
    func pinchgestures() {
        tableview.isUserInteractionEnabled = true
        let pinchGeture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        tableview.addGestureRecognizer(pinchGeture)
    }
    
    @objc func pinchGesture(sender:UIPinchGestureRecognizer)  {
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
    }
}

        //MARK:- RandomColor
extension ViewController {
    
    func randomCGFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    func randomColor() -> UIColor {
        let r = randomCGFloat()
        let g = randomCGFloat()
        let b = randomCGFloat()
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

