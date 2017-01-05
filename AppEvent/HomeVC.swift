//
//  HomeVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

private enum NameCell:String {
    case Header = "HomeHeaderCell"
    case HeaderCell = "homeHeaderCell"
    
    case Title = "HomeTitleCell"
    case HomeTitleCell = "homeTitleCell"
    
    case Detail = "HomeDetailCell"
    case HomeDetailCell = "homeDetailCell"
}

class HomeVC: UIViewController {
    
    @IBOutlet weak var tbvHome: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.navigationController?.navigationBar.topItem?.title = "Home"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tbvHome.registerNib(UINib.init(nibName: NameCell.Header.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HeaderCell.rawValue)
        tbvHome.registerNib(UINib.init(nibName: NameCell.Title.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HomeTitleCell.rawValue)
        tbvHome.registerNib(UINib.init(nibName: NameCell.Detail.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HomeDetailCell.rawValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension HomeVC : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 10
        default:
            return 2
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NameCell.HeaderCell.rawValue, forIndexPath: indexPath) as! HomeHeaderCell
            
            if indexPath.row % 2 == 0 {
                cell.imgTemperature.image = UIImage.init(named: "Rain")
                cell.lblTitle.text = "Da Nang"
            } else {
                cell.lblTitle.text = "HCM City"
            }
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NameCell.HomeTitleCell.rawValue, forIndexPath: indexPath) as! HomeTitleCell
            
            if indexPath.row == 0 {
                cell.lblStartTime.text = "2:00 PM"
                cell.lblEndTime.text = "5:00 PM"
                cell.viewColor.backgroundColor = UIColor.yellowColor()
            } else if indexPath.row == 1 {
                cell.viewColor.backgroundColor = UIColor.orangeColor()
            } else {
                cell.viewColor.backgroundColor = UIColor.greenColor()
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NameCell.HomeDetailCell.rawValue, forIndexPath: indexPath) as! HomeDetailCell
            
            return cell
        }
    }
}

extension HomeVC : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 44
        case 1:
            return 65
        case 2:
            return 333
        default:
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 0.0001
        default:
            return 10
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
}
