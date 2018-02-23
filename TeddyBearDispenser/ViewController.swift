//
//  ViewController.swift
//  TeddyBearDispenser
//
//  Created by Kathleen Hang on 2/18/18.
//  Copyright © 2018 Team Cowdog. All rights reserved.
//
import UIKit

fileprivate let reuseIdentifier = "dispensedItem"
fileprivate let screenWidth = UIScreen.main.bounds.width

// collection view uses data source and delegate how??
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // refers to the container
    @IBOutlet weak var collectionView: UICollectionView!
    // refers to grand total label
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    // declare a bear dispenser. we choose a protocol to start out with in case we want to swap out our bear dispenser type
    let bearDispenser: BearDispenser
    // optional because when app starts, there is nothing selected
    var currentSelection: BearSelection?
    
    //what is ns coder??
    required init?(coder aDecoder: NSCoder) {
        // convert plist to dictionary
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "TeddyBearInventory", ofType: "plist")
            // convert dictionary into inventory
            let inventory = try InventoryUnarchiver.dispensingInventory(fromDictionary: dictionary)
            
            // assign teddy bear dispenser class object to local bear dispenser constant with initialized inventory
            self.bearDispenser = TeddyBearDispenser(inventory: inventory)
            // if our inventory cant be set up, there is no point starting this app
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCollectionViewCells()
        updateDisplayWith(balance: bearDispenser.totalBalance, totalPrice: 0, itemPrice: 0, itemQuantity: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Setup
    // MARK can be viewed in the quick jump bar
    
    func setupCollectionViewCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding: CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    
    // default values to nil so you dont have to pass argument to call it. optional so we can call that particular value attribute if we want to
    // balance, grand total, unit price, item quantity
    // update display attributes on vc side because of view**
    func updateDisplayWith(balance: Double? = nil, totalPrice: Double? = nil, itemPrice: Double? = nil, itemQuantity: Int? = nil) {
        
        if let balanceValue = balance {
            balanceLabel.text = "$\(balanceValue)"
        }
        
        if let totalValue = totalPrice {
            totalLabel.text = "\(totalValue)"
        }
        
        if let priceValue = itemPrice {
            priceLabel.text = "$\(priceValue)"
        }
        
        if let quantityValue = itemQuantity {
            quantityLabel.text = "\(quantityValue)"
        }
    }
    
    // we do this in a method because we always have to do that operation where we grab the items price and multiply it by quantity
    func updateTotalPrice(for item: DispensedItem){
        let totalPrice = item.price * quantityStepper.value
        updateDisplayWith(totalPrice: totalPrice)
    }
    
    @IBAction func updateQuantity(_ sender: UIStepper) {
        let quantity = Int(quantityStepper.value)
        updateDisplayWith(itemQuantity: quantity)
        
        // have selection, turn into item and use item to calculate grand total
        if let currentSelection = currentSelection, let item = bearDispenser.item(forSelection: currentSelection) {
            updateTotalPrice(for: item)
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        // handler executed when we execute action
        let okAction = UIAlertAction(title: "OK", style: .default, handler: dismissAlert)
        alertController.addAction(okAction)
        // ask vc to show another view. modal view: display another view on top
        present(alertController, animated: true, completion: nil)
    }
    // must match UIAlertAction -> Void of okAction handler
    // when we hit an error, we reset everything
    func dismissAlert(sender: UIAlertAction) -> Void {
        updateDisplayWith(balance: 0, totalPrice: 0, itemPrice: 0, itemQuantity: 1)
    }
    

    @IBAction func addFunds() {
        bearDispenser.addFunds(10.0)
        updateDisplayWith(balance: bearDispenser.totalBalance)
    }
    
    
    
    // MARK: Bear Dispenser
    
    // note: missing closing bracket caused weird errors such as collectionView undeclared
    @IBAction func purchase() {
        // quick optional unwrap
        // if current selection is valid then dispense the bear with current selection and stepper property value
        // make sure the user selected an item before clicking purchase button
        if let currentSelection = currentSelection {
            do {
                // this is purchase method
                // quantity is obtained through the stepper**
                try bearDispenser.dispense(selection: currentSelection, quantity: Int(quantityStepper.value))
                // reset after purchase
                updateDisplayWith(balance: bearDispenser.totalBalance, totalPrice: 0.0, itemPrice: 0, itemQuantity: 1)
            }
            // else show appropriate error
              catch DispensingError.outOfStock {
                showAlertWith(title: "Out of Stock", message: "This item is unavailable. Please make another selection")
            } catch DispensingError.invalidSelection {
                showAlertWith(title: "Invalid Selection", message: "Please make another selection")
                // bound to local constant. then using string interpolation to use that value for message
            } catch DispensingError.insufficientFunds(let required) {
                let message = "You need $\(required) to complete the transaction"
                showAlertWith(title: "Insufficient Funds", message: message)
            } catch let error {
                fatalError("\(error)")
            }
            // deselect the first selected item after purchase
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                collectionView.deselectItem(at: indexPath, animated: true)
                updateCell(having: indexPath, selected: false)
            }
            
            else {
                // FIXME: Alert user to no selection
            }
        }
    }
        
        // MARK: UICollectionViewDataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            // what is this referring to?
            return bearDispenser.selection.count
        }
        // cell displays our image
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DispensingItemCell else {
                fatalError()
            }
            // collection view uses indexes and it stores it in indexPath. nested array. .row gets us to index we care about
            // we know exactly what selection is being loaded into that cell
            let item = bearDispenser.selection[indexPath.row]
            // set that image
            cell.iconView.image = item.icon()
            
            return cell
        }

        // MARK: UICollectionViewDelegate
        // when an item is tapped. path gives us index position of the item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            updateCell(having: indexPath, selected: true)
            // stepper goes back to 1 every time we select a new item
            quantityStepper.value = 1
            //this is the one the user selected by tapping. selection array refers to one of the enum bear items
            currentSelection = bearDispenser.selection[indexPath.row]
            if let currentSelection = currentSelection, let item = bearDispenser.item(forSelection: currentSelection) {
                let totalPrice = item.price * quantityStepper.value
                // reset everything
                updateDisplayWith(totalPrice: totalPrice, itemPrice: item.price)
            }
        }
        // deselect the item
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            updateCell(having: indexPath, selected: false)
        }
        
        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
            updateCell(having: indexPath, selected: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
            updateCell(having: indexPath, selected: false)
        }
        
        func updateCell(having indexPath: IndexPath, selected: Bool) {
            let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0)
            let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
            }
        }


    }


