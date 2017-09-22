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
    
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var constraintBotton: NSLayoutConstraint!
    
    struct Color {
        static let selectedText = UIColor.white
        static let text = UIColor.black
        static let textDisabled = UIColor.gray
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
        
        let setting = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(settingCalendar))
        let add = UIBarButtonItem(image: UIImage(named: "Plus"), style: .plain, target: self, action: #selector(addEvent))
        self.navigationController?.navigationBar.topItem?.title = CVDate(date: Foundation.Date()).globalDescription
        
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = setting
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = add
        
        
        tbvCalendar.register(UINib.init(nibName: NameCell.Title.rawValue, bundle: nil), forCellReuseIdentifier: NameCell.HomeTitleCell.rawValue)
        let nib = UINib(nibName: "CalendarTableSectionHeader", bundle: nil)
        tbvCalendar.register(nib, forHeaderFooterViewReuseIdentifier: "CalendarTableSectionHeader")
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
        
        constraintTop.constant = self.navigationController!.navigationBar.frame.size.height + 20
        constraintBotton.constant = (self.tabBarController?.tabBar.frame.size.height)!

        self.view.layoutIfNeeded()

    }
}

extension CalendarVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return true
    }
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    // MARK: Optional methods
    
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return UIColor.black
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        //        return shouldShowDaysOut
        return true
    }
    
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let randomDay = 6
        if day == randomDay || day == 7 {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        return [Color.selectionBackground]
    }
    
    func dayOfWeekBackGroundColor() -> UIColor {
        return UIColor.groupTableViewBackground
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        print(dayView.date.day,", ",dayView.date.globalDescription)
        
        if dayView.date.day == 6 {
            self.tbvCalendar.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        if dayView.date.day == 7 {
            self.tbvCalendar.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
        }

    }
    
    func presentedDateUpdated(_ date: CVDate) {
        
        if self.navigationController?.navigationBar.topItem?.title != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textAlignment = .center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            
            let offset = CGFloat(44)
            updatedMonthLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            updatedMonthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.animationFinished = false
                
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransform.identity
                
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
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFont(ofSize: 14) }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return Color.selectedText
        case (.sunday, .in, _): return Color.sundayText
        case (.sunday, _, _): return Color.sundayTextDisabled
        case (_, .in, _): return Color.text
        default: return Color.textDisabled
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (.sunday, .selected, _), (.sunday, .highlighted, _): return Color.sundaySelectionBackground
        case (_, .selected, _), (_, .highlighted, _): return Color.selectionBackground
        default: return nil
        }
    }
}

extension CalendarVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CalendarTableSectionHeader") as! CalendarTableSectionHeader

        header.backgroundViewHeader.layer.borderWidth = 1
        header.backgroundViewHeader.layer.borderColor = UIColor.lightGray.cgColor
        
        switch section {
        case 0:
            header.titleLabel.text = "6/1/2017"
        case 1:
            header.titleLabel.text = "7/1/2017"
        default:
            header.titleLabel.text = ""
        }
        
        return header
    }
}

extension CalendarVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)        
        let mainVC = DetailVC(nibName:"DetailVC", bundle:nil)
        self.navigationController!.pushViewController(mainVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
}

