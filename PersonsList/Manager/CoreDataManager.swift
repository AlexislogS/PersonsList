//
//  CoreDataManager.swift
//  PersonsList
//
//  Created by Alex Yatsenko on 03.08.2020.
//  Copyright © 2020 Alexislog's Production. All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersonsData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetch
    
    func fetchPersons(completion: (_ result: Result<[Person], Error>) -> Void) {
        do {
            let request: NSFetchRequest<Person> = Person.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let persons = try persistentContainer.viewContext.fetch(request)
            completion(.success(persons))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - Save person
    
    func savePerson(with text: String, completion: (_ result: Result<Person, Error>) -> Void) {
        let person = Person(context: persistentContainer.viewContext)
        person.name = text
        do {
            try self.persistentContainer.viewContext.save()
            completion(.success(person))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - Delete person
    
    func delete(person: Person, completion: (_ result: Result<Void, Error>) -> Void) {
        persistentContainer.viewContext.delete(person)
        do {
            try persistentContainer.viewContext.save()
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - Edit person
    
    func edit(person: Person, name: String, completion: (_ result: Result<Void, Error>) -> Void) {
        do {
            try self.persistentContainer.viewContext.save()
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
