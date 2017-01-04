//
//  TabbarVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
        let homeNavi = UINavigationController.init(rootViewController: homeVC)
        let searchVC = SearchVC(nibName: "SearchVC", bundle: nil)
        let searchNavi = UINavigationController.init(rootViewController: searchVC)
        let calendarVC = CalendarVC(nibName: "CalendarVC", bundle: nil)
        let calendarNavi = UINavigationController.init(rootViewController: calendarVC)
        let profileVC = ProfileVC(nibName: "ProfileVC", bundle: nil)
        let profileNavi = UINavigationController.init(rootViewController: profileVC)
        
        let viewControllers = [homeNavi, searchNavi, calendarNavi, profileNavi]
        self.viewControllers = viewControllers
        
        homeVC.tabBarItem = UITabBarItem.init(title: "Home", image: UIImage.init(named: "Home"), tag: 1)
        searchVC.tabBarItem = UITabBarItem.init(title: "Search", image: UIImage.init(named: "Search"), tag: 2)
        calendarVC.tabBarItem = UITabBarItem.init(title: "Calendar", image: UIImage.init(named: "Calendar"), tag: 3)
        profileVC.tabBarItem = UITabBarItem.init(title: "Profile", image: UIImage.init(named: "Profile"), tag: 4)
        
        
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
