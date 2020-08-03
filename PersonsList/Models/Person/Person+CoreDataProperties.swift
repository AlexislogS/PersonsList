//
//  Person+CoreDataProperties.swift
//  PersonsList
//
//  Created by Alex Yatsenko on 03.08.2020.
//  Copyright © 2020 Alexislog's Production. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?

}
