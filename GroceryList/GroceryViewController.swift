//
//  GroceryViewController.swift
//  TableViewFun
//
//  Created by Adam Zarn on 3/22/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import CoreData
import BTNavigationDropdownMenu

class GroceryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cost: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var myTableView: UITableView!
    
    let resetAlert: UIAlertController = UIAlertController(title: "Are you sure you want to reset?", message: "This will uncheck all items and set all quantities to 1.",preferredStyle: UIAlertControllerStyle.Alert)
    
    @IBAction func generateList(sender: AnyObject) {
        let listView = self.storyboard!.instantiateViewControllerWithIdentifier("ListViewController") as! ListViewController
        self.navigationController!.pushViewController(listView, animated: true)
        
        let totalCost = 1.0825*(costValue*0.95)
        listView.costString = "Total REDcard cost with tax: " + String(formatter().stringFromNumber(totalCost)!)
    }
    

    @IBAction func resetButtonPressed(sender: AnyObject) {
        self.presentViewController(resetAlert, animated: true, completion: nil)
    }
    
    func formatter() -> NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    var costValue = 0.0
    var navBarTitle: String!
    var lastNumberOfUnits = "1"
    
    let sections = ["Produce","W1/W2","W3/W4","W5/W6","W7/W8","W9/W10","W11/W12","W13/W14","W15/W16","W17/W18","W19/W20","W21/W22","W23/W24","W25/W26","W27/W28","W29/W30","South Wall"]
    
    var foodItems = [NSManagedObject]()
    var fullArray: [[NSManagedObject]] = []
    var tempArray: [NSManagedObject] = []
    
    var indexOfSectionToDisplay: Int = 0
    
    func updateCost(c: Double) {
        cost.title = String(formatter().stringFromNumber(c)!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        lastNumberOfUnits = textField.text!
        textField.becomeFirstResponder()
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            textField.text = lastNumberOfUnits
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getData()
        myTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        resetAlert.addAction(UIAlertAction(title:"Reset",
            style: UIAlertActionStyle.Default,
            handler: {(alert: UIAlertAction!) in
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "Food")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key:"aisleNumber", ascending: true),
                    NSSortDescriptor(key:"name", ascending: true)]
                
                do {
                    let results = try context.executeFetchRequest(fetchRequest)
                    self.foodItems = results as! [NSManagedObject]
                    for foodItem in self.foodItems {
                        foodItem.setValue(false, forKey: "isSelected")
                        foodItem.setValue(1.0, forKey: "numberSelected")
                    }
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
                
                self.costValue = 0.0
                self.updateCost(self.costValue)
                NSUserDefaults.standardUserDefaults().setValue(self.costValue, forKey: "cost")
                
                self.myTableView.reloadData()

        })
        )
        
        resetAlert.addAction(UIAlertAction(title:"Cancel",style: UIAlertActionStyle.Default, handler: nil))
        
        getData()
        
        if let cost = NSUserDefaults.standardUserDefaults().valueForKey("cost") {
            costValue = cost as! Double
        }
        
        updateCost(costValue)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(GroceryViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                containerView: self.navigationController!.view,
                                                title: "Grocery List",
                                                items: ["Produce","W1/W2","W3/W4","W5/W6","W7/W8","W9/W10","W11/W12","W13/W14","W15/W16","W17/W18","W19/W20","W21/W22","W23/W24","W25/W26","W27/W28","W29/W30","South Wall"])
        
        self.navBar.titleView = menuView
        menuView.arrowTintColor = UIColor.blackColor()
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            let moveToIndexPath = NSIndexPath(forRow: 0, inSection: indexPath)
            self.myTableView.scrollToRowAtIndexPath(moveToIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        menuView.shouldChangeTitleText = false
        
    }
    
    func getData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Food")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"aisleNumber", ascending: true),
                                        NSSortDescriptor(key:"name", ascending: true)]
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            foodItems = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        fullArray = []
        for index1 in 0...self.sections.count - 1 {
            tempArray = []
            for index2 in 0...foodItems.count - 1 {
                if String(foodItems[index2].valueForKey("aisleNumber")!) == String(index1) {
                    tempArray.append(foodItems[index2])
                }
            }
            fullArray.append(tempArray)
        }
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fullArray[section].count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDelegate.managedObjectContext
            context.deleteObject(fullArray[indexPath.section][indexPath.row] as NSManagedObject)
        
            fullArray[indexPath.section].removeAtIndex(indexPath.row)
            appDelegate.saveContext()
            
            getData()
            self.myTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let currentAisleElement = self.fullArray[indexPath.section][indexPath.row]
        
        let editView = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditViewController") as! AddEditViewController
        editView.nameText = currentAisleElement.valueForKey("name") as? String
        editView.baseUnitText = currentAisleElement.valueForKey("baseUnit") as? String
        editView.priceText = currentAisleElement.valueForKey("price") as? Double
        editView.aisleText = sections[(currentAisleElement.valueForKey("aisleNumber") as? Int)!]
        editView.imageName = currentAisleElement.valueForKey("imageName") as? String
        
        editView.editingFoodItem = true
        editView.editingIndexPathRow = indexPath.row
        
        self.presentViewController(editView, animated: true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: CustomCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CustomCell
        cell.checkBox.tag = (indexPath.section * 1000) + indexPath.row
        cell.units.tag = (indexPath.section * 1000) + indexPath.row
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        }
        
        let currentAisleElement = self.fullArray[indexPath.section][indexPath.row]
        
        cell.units.delegate = self
        if let numSel = currentAisleElement.valueForKey("numberSelected") {
            cell.units.text = String(numSel)
        } else {
            cell.units.text = lastNumberOfUnits
        }
        
        let isSel = String(currentAisleElement.valueForKey("isSelected")!)
        
        if isSel == "0" {
            cell.checkBox.setImage(UIImage(named: "unchecked.png"), forState: UIControlState.Normal)
        } else {
            cell.checkBox.setImage(UIImage(named: "checked.png"), forState: UIControlState.Normal)
        }
        
        let name = currentAisleElement.valueForKey("name") as? String
        let price = currentAisleElement.valueForKey("price") as? Double
        let baseUnit = currentAisleElement.valueForKey("baseUnit") as? String
        let imageName = currentAisleElement.valueForKey("imageName") as? String
        
        cell.setCell(name!,
                     RightLabelString: String(formatter().stringFromNumber(price!)!),
                     baseUnitLabel: baseUnit!,
                     imageName: imageName!)
        
        return cell
        
    }
    


    @IBAction func textBoxEdited(sender: UITextField) {
        
        let textBoxRow = sender.tag % 1000
        let textBoxSection = (sender.tag - textBoxRow) / 1000

        let currentAisleElement = self.fullArray[textBoxSection][textBoxRow]
        currentAisleElement.setValue(Double(sender.text!), forKey: "numberSelected")
        
        if String(currentAisleElement.valueForKey("numberSelected")) == "" {
           currentAisleElement.setValue(1.0, forKey: "numberSelected")
        }
        
        var numSelUnwrapped = 0.0
        let isSel = String(currentAisleElement.valueForKey("isSelected")!)
        let price = currentAisleElement.valueForKey("price") as! Double
        if let numSel = currentAisleElement.valueForKey("numberSelected") {
            numSelUnwrapped = numSel as! Double
        } else {
            numSelUnwrapped = Double(lastNumberOfUnits)!
        }
        
        if isSel == "1" {
            costValue += price * (numSelUnwrapped - Double(lastNumberOfUnits)!)
            updateCost(costValue)
        }
    }
    
    @IBAction func checkBoxPressed(sender: UIButton) {
        
        let checkBoxRow = sender.tag % 1000
        let checkBoxSection = (sender.tag - checkBoxRow) / 1000
        
        let currentAisleElement = self.fullArray[checkBoxSection][checkBoxRow]
        
        let indexPath = NSIndexPath(forRow:checkBoxRow,inSection:checkBoxSection)
        let cell = myTableView.cellForRowAtIndexPath(indexPath) as! CustomCell
        
        if cell.checkBox.currentImage == UIImage(named:"unchecked.png") {
            
            cell.checkBox.setImage(UIImage(named: "checked.png"), forState: UIControlState.Normal)
            currentAisleElement.setValue(true, forKey: "isSelected")
            
            if String(currentAisleElement.valueForKey("numberSelected")) == "" {
                currentAisleElement.setValue(1.0, forKey: "numberSelected")
            }
            
            let price = currentAisleElement.valueForKey("price")! as! Double
            
            var numSelUnwrapped = 0.0
            if let numSel = currentAisleElement.valueForKey("numberSelected") {
                numSelUnwrapped = numSel as! Double
            } else {
                numSelUnwrapped = Double(lastNumberOfUnits)!
            }

            costValue += price * numSelUnwrapped
        
        } else {
            
            cell.checkBox.setImage(UIImage(named: "unchecked.png"), forState: UIControlState.Normal)
            currentAisleElement.setValue(false,forKey:"isSelected")
            
            if String(currentAisleElement.valueForKey("numberSelected")) == "" {
                currentAisleElement.setValue(1.0, forKey: "numberSelected")
            }
            
            let price = currentAisleElement.valueForKey("price")! as! Double
            
            var numSelUnwrapped = 0.0
            if let numSel = currentAisleElement.valueForKey("numberSelected") {
                numSelUnwrapped = numSel as! Double
            } else {
                numSelUnwrapped = Double(lastNumberOfUnits)!
            }

            costValue -= price * numSelUnwrapped
            
        }
    
    updateCost(costValue)
    NSUserDefaults.standardUserDefaults().setValue(costValue, forKey: "cost")
        
    }

    
    
}

