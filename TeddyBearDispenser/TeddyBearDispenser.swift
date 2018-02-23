//
//  TeddyBearDispenser.swift
//  TeddyBearDispenser
//
//  Created by Kathleen Hang on 2/20/18.
//  Copyright © 2018 Team Cowdog. All rights reserved.
//

// contains NS classes
import Foundation
// for UIImage
import UIKit

// possible bear choices available for purchase
enum BearSelection: String {
    case redBear
    case orangeBear
    case yellowBear
    case greenBear
    case blueBear
    case purpleBear
    
    func icon() -> UIImage {
        // UIImage named initializer is failable. We don't want to return optional
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            // return the default image
            return #imageLiteral(resourceName: "default")
        }
    }
}
// each dispenser item contains price and quantity
// FIXME: - rename DispensedItem to DispenserItem because dispensed implies processing a purchase
protocol DispensedItem {
    var price: Double { get }
    var quantity: Int { get set }
}

// possible error types that could happen while processing a purchase
enum DispensingError: Error {
    case invalidSelection
    case outOfStock
    // tuple: allow user know how much cash is required to complete the transaction. Uses associated value.
    case insufficientFunds(required: Double)
}

// tracks data with persisting values in regards to specifically the bear dispenser
protocol BearDispenser {
    // selection of type: BearSelection array. Cannot be modified. Can only be obtained.
    var selection: [BearSelection] { get }
    // user account balance
    var totalBalance: Double { get set }
    // instead of putting primitive data type, just put the actual custom data types. inventory is a dictionary with a nested dictionary as the value of the pair.
    var inventory: [BearSelection: DispensedItem] { get set }
    // must feed the bear dispenser with an acceptable inventory type, first and foremost.
    init(inventory: [BearSelection: DispensedItem])
    // allows to deposit funds into account
    func addFunds(_ amount: Double)
    // the selection passed into this method will be used to access the inventory dictionary to obtain the item selected
    func dispense(selection: BearSelection, quantity: Int) throws
    // unnecessary but gives context to people reading our code
    func item(forSelection selection: BearSelection) -> DispensedItem?
    

}


// struct object to represent the dispenser item
// struct works well when it does not matter what instance of the item you have
// struct initializes member values automatically
// we use this protocol so it is more interchangeable. Later on, we could swap it with different types of items like cheap items, expensive items, midrange items, etc.
struct Item: DispensedItem {
    let price: Double
    var quantity: Int
}

// do not forget error handling for conversion problems
// naming convention: conversionError vs InventoryError
enum InventoryError: Error {
    // if bundle could not find the resource at the path
    case invalidResource
    // the contents may not be able to be converted if it is an array since we need a dictionary
    case conversionFailure
    case invalidSelection
}

// a class DOES things, so Plist converter will be a class
class PlistConverter {
    // static works for class or struct. We do not have to create instance of plist converter to use it. just call the type. Example: PlistConverter.someMethod(). why we use type/static: We do not need to hold onto any data. Once it converts the data, we do not need the data anymore.
    
    // naming convention: plistToDictionary() vs dictionary()
    // AnyObject means any instance of any class type or object
    // Any can represent any instance type including functions
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        // store the passed parameter values to get the path of file and make sure it is correct type
        // guard because resource might not exist
        // need else since this is a guard statement
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            // if bundle cannot find path for resource
            throw InventoryError.invalidResource
        }
        // guard because it might return array instead of dictionary
        // wont be able to convert dictionary. need to return swift type by using typecasting(cant use NSDictionary. need to use swift dictionary [String: AnyObject])
        // downcast conditional dictionary to the type we want. convert to generic dictionary. by using as? [String: AnyObject] typecasting.
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            throw InventoryError.conversionFailure
        }
        // return dictionary once it has been downcasted
        return dictionary
    }
}

// there is no inventory class
// naming convention: InventoryUnarchiver vs DictionaryToInventory
class InventoryUnarchiver {
    // this dictionary type matches the one specified dictionary() conversion method.
    // this will return the same type specified in the protocol for inventory
    static func dispensingInventory(fromDictionary dictionary: [String: AnyObject]) throws -> [BearSelection: DispensedItem] {
        // refers to empty dictionary [:]
        var inventory: [BearSelection: DispensedItem] = [:]
        // iterates through every key value pair in dictionary
        for (key, value) in dictionary {
            // use type alias Any because the value is a double and int
            // get price, quantity from each item in dictionary
            // this will cast the dictionary value as Any
            // retrieving from dictionary using key always returns optional because key may not exist
            // String refers to quantity or price String
            // "price" is key then type cast value to Double since its currently at Any
            // value is a nested dictionary
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                // assign the obtained values to constant called item
                // it works because price has been casted to double and quantity has been casted into int
                // still need to convert String key into BearSelection datatype for our inventory
                let item = Item(price: price, quantity: quantity)
                
                // to use raw value: go to enum and specify data type of String. String raw value = special behavior: will return case name
                // it will select this from enum. if the key does not exist then error handling activates
                // raw value initializer
                guard let selection = BearSelection(rawValue: key)
                    // selection does not exist
                    else {
                        throw InventoryError.invalidSelection
                }
                // add the successfully converted key and value pair to our inventory
                inventory.updateValue(item, forKey: selection)
            }
        }
        return inventory
    }
}
// this actually implements the bear dispenser protocol. we put every variable and method from that protocol into this class ALONG with implementation because of protocol is a contract.
// classes are good for maintaining state
class TeddyBearDispenser: BearDispenser {
    // it knows based off dot notation because we specified the enum data type for the class. array of possible bear selections
    let selection: [BearSelection] = [.redBear, .orangeBear, .yellowBear, .greenBear, .blueBear, .purpleBear]
    // for each key , we have an instance of this item type that stores info about price and quantity. it is a nested dictionary.
    var inventory: [BearSelection : DispensedItem]
    // start the user off with $50
    var totalBalance: Double = 50.0
    // if the init is a protocol requirement, you must write keyword required. the inventory passed through the parameters is assigned to our local inventory
    required init(inventory: [BearSelection : DispensedItem]) {
        self.inventory = inventory
    }
    // the purchasing transaction
    func dispense(selection: BearSelection, quantity: Int) throws {
        // if selection is valid, store the inventory selection into item variable
        //item obtained through inventory selection **
        guard var item = inventory[selection] else {
            throw DispensingError.invalidSelection
        }
        
        // item has quantity property because it is a nested dictionary containing both quantity and price as stored properties.
        // if they ask for more than what is in stock, then throw error
        guard item.quantity >= quantity else {
            throw DispensingError.outOfStock
        }
        // item.price is how unit price is obtained. grand total is obtained from TeddyBearDispenser.swift
        // calculate the grand total and store into a constant named totalPrice
        // cast quantity into double for calculation
        let totalPrice = item.price * Double(quantity)
        
        // if they have enough cash, deduct the total from their account and decrease the specific item's stock quantity
        if totalBalance >= totalPrice {
            totalBalance -= totalPrice
            item.quantity -= quantity
            // updateValue is a dictionary method
            inventory.updateValue(item, forKey: selection)
        }
        // if they do not have enough cash then calculate how much extra they were insufficient and throw the error containing the extra amount required
        else {
            let amountRequired = totalPrice - totalBalance
            throw DispensingError.insufficientFunds(required: amountRequired)
        }
    }
    // unnecessary but gives context to people reading our code
    func item(forSelection selection: BearSelection) -> DispensedItem? {
        return inventory[selection]
    }
    // add cash to account
    func addFunds(_ amount: Double) {
        totalBalance += amount
    }
}

















