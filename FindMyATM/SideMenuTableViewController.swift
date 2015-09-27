//
//  SideMenuTableViewController.swift
//  OOPBusMaps
//
//  Created by Jasmin Abou Aldan on 11/12/14.
//  Copyright (c) 2014 Jasmin Abou Aldan. All rights reserved.
//

import UIKit


/**************************************************************************************************************/
//MARK: - Menu Delegate Protocol

protocol SideMenuTableViewControllerDelegate{
    func sideMenuControlDidSelectRow(indexPath: NSIndexPath)
}

//MARK: - Side Menu Table View Controller Class
///This class is populating data inside side menu
class SideMenuTableViewController: UITableViewController {
    
    /**********************************************************************************************************/
    //MARK: - Variable Declaration
    
    var delegate: SideMenuTableViewControllerDelegate?
    var tableData: Array<String> = []
    
    /**********************************************************************************************************/
    //MARK: - Table View Setup

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }
        else {
            return tableData.count
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return nil
        }
        else{
            return NSLocalizedString("BANKS", comment: "banks")
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell! 
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.textColor = UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1.0)
            
            let selectedView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 1.0)
            
            cell!.selectedBackgroundView = selectedView
        }
        
        if indexPath.section == 0{
            cell!.textLabel!.text = NSLocalizedString("ALL_ATMS", comment: "All atms")
        }
        else{
            cell!.textLabel!.text = tableData[indexPath.row] // ispis teksta (broj autobusa)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideMenuControlDidSelectRow(indexPath)
    }
    

}
