//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Michael Redig on 5/27/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {

	let taskController = TaskController()

	lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		fetchRequest.sortDescriptors = [
										NSSortDescriptor(key: "priority", ascending: false),
										NSSortDescriptor(key: "name", ascending: true)
										]
		let fetchedResultsContoller = NSFetchedResultsController(fetchRequest: fetchRequest,
																 managedObjectContext: CoreDataStack.shared.mainContext,
																 sectionNameKeyPath: "priority",
																 cacheName: nil)
		fetchedResultsContoller.delegate = self
		do {
			try fetchedResultsContoller.performFetch()
		} catch {
			print("error performing initial fetch for frc: \(error)")
		}
		return fetchedResultsContoller
	}()


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		taskController.fetchTasksFromServer { [weak self] (result: Result<[TaskRepresentation], NetworkError>) in
			DispatchQueue.main.async {
				do {
					_ = try result.get()
					self?.tableView.reloadData()
					print("updated")
				} catch {
					NSLog("error fetching tasks: \(error)")
				}
			}
		}
		tableView.reloadData()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let detailVC = segue.destination as? TaskDetailViewController {
			detailVC.taskController = taskController
			if segue.identifier == "ShowDetail" {
				if let indexPath = tableView.indexPathForSelectedRow {
					detailVC.task = fetchedResultsController.object(at: indexPath)
				}
			}
		}
	}
}

// MARK: - Tableview stuff
extension TasksTableViewController {

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let number = fetchedResultsController.sections?[section].name, let value = Int16(number) else { return nil }

		return TaskPriority(rawValue: value)?.stringValue.capitalized
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

		let task = fetchedResultsController.object(at: indexPath)
		cell.textLabel?.text = task.name

		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let task = fetchedResultsController.object(at: indexPath)

			// delete remote
			taskController.delete(task: task) { [weak self] (result: Result<Data?, NetworkError>) in
				DispatchQueue.main.async {
					do {
						_ = try result.get()
					} catch {
						let alert = UIAlertController(error: error)
						self?.present(alert, animated: true)
					}
				}
			}

			//save in memory
			guard let context = task.managedObjectContext else { return }
			context.delete(task)
			//write to disk
			do {
				try CoreDataStack.shared.save(context: context)
			} catch {
				print("error saving core data:\(error)")
			}
		}
	}
}

// MARK: - fetched results controller delegate
extension TasksTableViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange sectionInfo: NSFetchedResultsSectionInfo,
					atSectionIndex sectionIndex: Int,
					for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			let indexSet = IndexSet(integer: sectionIndex)
			tableView.insertSections(indexSet, with: .automatic)
		case .delete:
			let indexSet = IndexSet(integer: sectionIndex)
			tableView.deleteSections(indexSet, with: .automatic)
		default:
			break
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any,
					at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType,
					newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .move:
			guard let newIndexPath = newIndexPath, let indexPath = indexPath else { return }
			tableView.moveRow(at: indexPath, to: newIndexPath)
		case .update:
			guard let indexPath = indexPath else { return }
			tableView.reloadRows(at: [indexPath], with: .automatic)
		@unknown default:
			print(#line, #file, "unknown change type: \(type)")
		}
	}
}
