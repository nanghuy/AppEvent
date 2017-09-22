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
    @IBOutlet weak var heightConstraintTable: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintTable: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.navigationController?.navigationBar.topItem?.title = "Home"
    }
    
    override func viewDidLayoutSubviews() {
//        heightConstraintTable.constant = (navigationController?.navigationBar.frame.size.height)!
//        bottomConstraintTable.constant = (tabBarController?.tabBar.frame.size.height)!
//        
//        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tbvHome.register(UINib.init(nibName: NameCell.Header.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HeaderCell.rawValue)
        tbvHome.register(UINib.init(nibName: NameCell.Title.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HomeTitleCell.rawValue)
        tbvHome.register(UINib.init(nibName: NameCell.Detail.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HomeDetailCell.rawValue)
        
        // Commit 1
        // Commit 2
        // Commit 3
        // Commit 4
        // commit 5
        // commit 6
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 5
        default:
            return 2
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NameCell.HeaderCell.rawValue, for: indexPath) as! HomeHeaderCell
            
            if indexPath.row % 2 == 0 {
                cell.imgTemperature.image = UIImage.init(named: "Rain")
                cell.lblTitle.text = "Da Nang"
            } else {
                cell.lblTitle.text = "HCM City"
            }
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NameCell.HomeTitleCell.rawValue, for: indexPath) as! HomeTitleCell
            
            if indexPath.row == 0 {
                cell.lblStartTime.text = "2:00 PM"
                cell.lblEndTime.text = "5:00 PM"
                cell.viewColor.backgroundColor = UIColor.yellow
            } else if indexPath.row == 1 {
                cell.viewColor.backgroundColor = UIColor.orange
            } else {
                cell.viewColor.backgroundColor = UIColor.green
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NameCell.HomeDetailCell.rawValue, for: indexPath) as! HomeDetailCell
            
            return cell
        }
    }
}

extension HomeVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 0.0001
        default:
            return 10
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
}
