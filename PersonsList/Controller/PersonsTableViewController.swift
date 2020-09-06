//
//  TableViewController.swift
//  PersonsList
//
//  Created by Alex Yatsenko on 31.07.2020.
//  Copyright © 2020 Alexislog's Production. All rights reserved.
//

import UIKit

final class PersonsTableViewController: UITableViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    private var persons = [Person]()
    private var filteredPersons = [Person]()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: Cell.id)
        fetchPersons()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredPersons.count : persons.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.id,
                                                 for: indexPath)
        let person = isFiltering ? filteredPersons[indexPath.row] : persons[indexPath.row]
        cell.textLabel?.text = person.name
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePerson(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editPerson(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setupNavigationItem() {
        title = "Persons"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addPressed))
        navigationItem.rightBarButtonItem?.style = .done
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search name"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func fetchPersons() {
        coreDataManager.fetchPersons { result in
            switch result {
            case .success(let persons):
                self.persons = persons
                tableView.reloadData()
            case .failure(let error):
                showAlert(with: AlertTitle.fetch.title, and: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(with title: String,
                           and message: String,
                           completion: ((String) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        if title == AlertTitle.add || title == AlertTitle.change {
            alert.addTextField { textFiled in
                textFiled.placeholder = "New person"
            }
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .destructive))
        }
        alert.addAction(UIAlertAction(title: "Done",
                                      style: .default,
                                      handler: { _ in
                                        if let text = alert.textFields?.first?.text {
                                            completion?(text)
                                        }
        }))
        if title == AlertTitle.change, let indexPath = tableView.indexPathForSelectedRow {
            let person = isFiltering ? filteredPersons[indexPath.row] : persons[indexPath.row]
            alert.textFields?.first?.text = person.name
        }
        present(alert, animated: true)
    }
    
    @objc private func addPressed() {
        savePerson()
    }
    
    // MARK: - Core Data Stack
    
    private func savePerson() {
        showAlert(with: AlertTitle.add, and: AlertTitle.enterName) { text in
            self.coreDataManager.savePerson(with: text) { result in
                switch result {
                case .success(let person):
                    self.persons.append(person)
                    self.tableView.insertRows(at: [IndexPath(row: self.persons.count - 1,
                                                              section: 0)],
                                               with: .automatic)
                case .failure(let error):
                    self.showAlert(with: AlertTitle.save.title, and: error.localizedDescription)
                }
            }
        }
    }
    
    private func deletePerson(at indexPath: IndexPath) {
        let person = isFiltering ? filteredPersons[indexPath.row] : persons[indexPath.row]
        coreDataManager.delete(person: person) { result in
            switch result {
            case .success():
                if isFiltering {
                    if let filteredIndex = filteredPersons.firstIndex(of: person),
                        let index = persons.firstIndex(of: person) {
                        filteredPersons.remove(at: filteredIndex)
                        persons.remove(at: index)
                    }
                } else {
                    if let index = persons.firstIndex(of: person) {
                        persons.remove(at: index)
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                showAlert(with: AlertTitle.delete.title, and: error.localizedDescription)
            }
        }
    }
    
    private func editPerson(at indexPath: IndexPath) {
        showAlert(with: AlertTitle.change, and: AlertTitle.enterName) { text in
            let person = self.isFiltering ? self.filteredPersons[indexPath.row] : self.persons[indexPath.row]
            person.name = text
            self.coreDataManager.edit(person: person) { result in
                switch result {
                case .success():
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    self.showAlert(with: AlertTitle.edit.title, and: error.localizedDescription)
                }
            }
        }
    }
}

    // MARK: - UISearchResultsUpdating

extension PersonsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterPersons(for: searchController.searchBar.text!)
    }
    
    private func filterPersons(for name: String) {
        filteredPersons = persons.filter { $0.name!.lowercased().contains(name.lowercased()) }
        tableView.reloadData()
    }
}
