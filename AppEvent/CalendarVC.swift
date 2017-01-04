//
//  CalendarVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit
private enum NameCell:String {
    case Title = "HomeTitleCell"
    case HomeTitleCell = "homeTitleCell"
}
class CalendarVC: UIViewController {
    
    struct Color {
        static let selectedText = UIColor.whiteColor()
        static let text = UIColor.blackColor()
        static let textDisabled = UIColor.grayColor()
        static let selectionBackground = UIColor(red: 236/255, green: 0, blue: 56/255, alpha: 1.0)
        static let sundayText = text
        static let sundayTextDisabled = textDisabled
        static let sundaySelectionBackground = selectionBackground
    }
    var animationFinished = true
    @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var tbvCalendar: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let setting = UIBarButtonItem(image: UIImage(named: "Settings"), style: .Plain, target: self, action: #selector(settingCalendar))
        let add = UIBarButtonItem(image: UIImage(named: "Plus"), style: .Plain, target: self, action: #selector(addEvent))
        self.navigationController?.navigationBar.topItem?.title = CVDate(date: NSDate()).globalDescription
        
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = setting
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = add
        
        
        tbvCalendar.registerNib(UINib.init(nibName: NameCell.Title.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HomeTitleCell.rawValue)
        
    }
    
    func settingCalendar(){
        print("setting")
    }
    
    func addEvent(){
        print("add event")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        calendarMenuView.commitMenuViewUpdate()
        
    }
}

extension CalendarVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return true
    }
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return UIColor.blackColor()
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        //        return shouldShowDaysOut
        return true
    }
    
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let randomDay = 5
        if day == randomDay || day == 7 {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        return [Color.selectionBackground]
    }
    
    func dayOfWeekBackGroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        print(dayView.date.day,", ",dayView.date.globalDescription)
    }
    
    func presentedDateUpdated(date: CVDate) {
        
        if self.navigationController?.navigationBar.topItem?.title != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            
            let offset = CGFloat(44)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
            }) { _ in
                
                self.animationFinished = true
                self.navigationController?.navigationBar.topItem?.title = updatedMonthLabel.text
                updatedMonthLabel.removeFromSuperview()
            }
            
        }
    }
    
    
}


// MARK: - CVCalendarViewAppearanceDelegate

extension CalendarVC: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFontOfSize(14) }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .Selected, _), (_, .Highlighted, _): return Color.selectedText
        case (.Sunday, .In, _): return Color.sundayText
        case (.Sunday, _, _): return Color.sundayTextDisabled
        case (_, .In, _): return Color.text
        default: return Color.textDisabled
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (.Sunday, .Selected, _), (.Sunday, .Highlighted, _): return Color.sundaySelectionBackground
        case (_, .Selected, _), (_, .Highlighted, _): return Color.selectionBackground
        default: return nil
        }
    }
}

extension CalendarVC : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
}

extension CalendarVC : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
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

