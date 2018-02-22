//
//  TeddyBearDispenser.swift
//  TeddyBearDispenser
//
//  Created by Kathleen Hang on 2/20/18.
//  Copyright © 2018 Team Cowdog. All rights reserved.
//

import Foundation

// specified enums for errors and bear selection
enum BearSelection: String {
    case redBear
    case orangeBear
    case yellowBear
    case greenBear
    case blueBear
    case purpleBear
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return
        }
    }
}
// protocols for dispensed item and bear dispenser
protocol DispensedItem {
    let price: Double { get  }
    var quantity: Int { get set }
}

enum DispensingError: Error {
    case invalidSelection
    case outOfStock
    // ????
    case insufficientFunds(required: Double)
}

// does not track grand total
// tracks stuff with persisting values in regards to specifically bear dispenser
protocol BearDispenser {
    // tracks item selection, total account balance, inventory, and grand total
    // selection of type: bear selection array. cant be modified. can only be obtained
    var selection: [BearSelection] { get }
    
    // user account balance
    var totalBalance: Double { get set }
    // instead of putting data type, just put the actual custom data types. dictionary.
    var inventory: [BearSelection: DispensedItem] { get set }
    
    // need to populate the inventory with bear items
    init(inventory: [BearSelection: DispensedItem])
    // allows to deposit funds into account
    func addFunds(_ amount: Double)
    // how did they get the parameter names? why no external naming? what is the parameter name refering to?
    func dispense(selection: BearSelection, quantity: Int) throws
    // confused about this like dispense function
    func item(forSelection selection: BearSelection) -> VendingItem?
    

}


// why do we need a struct dispenseditem Item??
struct Item: DispensedItem {
    let price: Double
    var quantity: Int
}

// dont forget error handling for conversion problems
// naming convention conversionError vs InventoryError
enum InventoryError: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistConverter {
    // why static?
    // naming convention: plistToDictionary() vs dictionary()
    // any object means any class object
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        // store the passed parameter values to get the path of file and make sure it is correct data type
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.invalidResource
        }
        // guard because it might return array instead of dictionary
        // wont be able to convert dictionary.
        // downcast conditional dictionary to the type we want. convert to generic dictionary.
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            throw InventoryError.conversionFailure
        }
        return dictionary
    }
}

// there is no inventory class
// naming convention: InventoryUnarchiver vs DictionaryToInventory
class InventoryUnarchiver {
    static func dispensingInventory(fromDictionary dictionary: [String: AnyObject]) throws -> [BearSelection: DispensedItem] {
        var inventory: [BearSelection: DispensedItem] = [:]
        // how does it know key value reference?
        for (key, value) in dictionary {
            // use type alias Any because the value is a double
            // get price, quantity from each item in dictionary
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                // assign the obtained values to constant called item
                let item = Item(price: price, quantity: quantity)
                
                // it will select this from enum. if the key doesnt exist then error handling activates
                guard let selection = BearSelection(rawValue: key)
                    else {
                        throw InventoryError.invalidSelection
                }
                // convert from dictionary to inventory??
                inventory.updateValue(item, forKey: selection)
            }
        }
        return inventory
    }
}
// this actually implements the bear dispenser protocol. we put every variable and method from protocol into this class ALONG with implementation because of protocol contract
class TeddyBearDispenser: BearDispenser {
    // it knows based off dot notation because we specified the enum data type. array of bear selections
    let selection: [BearSelection] = [.redBear, .orangeBear, .yellowBear, .greenBear, .blueBear, .purpleBear]
    var inventory: [BearSelection : DispensedItem]
    var totalBalance: Double = 50.0
    // why is it called required? the inventory passed through the parameters is assigned to our local inventory
    required init(inventory: [BearSelection : DispensedItem]) {
        self.inventory = inventory
    }
    // attempt to dispense
    func dispense(selection: BearSelection, quantity: Int) throws {
        // if attempt works, then store the inventory selection into variable item
        guard var item = inventory[selection] else {
            throw DispensingError.invalidSelection
        }
        
        // how does item know it has quantity property??
        // if they ask for more than is in stock, then throw error
        guard item.quantity >= quantity else {
            throw DispensingError.outOfStock
        }
        
        // calculate the total price and store into a constant
        let totalPrice = item.price * Double(quantity)
        
        // if they have enough money, deduct the total from their account and also decrease the specific item's stock
        if totalBalance >= totalPrice {
            totalBalance -= totalPrice
            item.quantity -= quantity
            // how does inventory know of updateValue method??
            inventory.updateValue(item, forKey: selection)
        }
        // if they dont have enough money then calculate how much extra they were insufficient and throw the error containing the extra amount needed
        else {
            let amountRequired = totalPrice - totalBalance
            throw DispensingError.insufficientFunds(required: amountRequired)
        }
        
    }
    
}

// ???
func item(forSelection selection: BearSelection) -> DispensedItem? {
    return inventory[selection]
}
// add more money to account
func addFunds(_ amount: Double) {
    totalBalance += amount
}














