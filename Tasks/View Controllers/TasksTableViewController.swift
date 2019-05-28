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

	lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		fetchRequest.sortDescriptors = [
										NSSortDescriptor(key: "priority", ascending: true),
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
		tableView.reloadData()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetail" {
			let detailVC = segue.destination as! TaskDetailViewController
			if let indexPath = tableView.indexPathForSelectedRow {
				detailVC.task = fetchedResultsController.object(at: indexPath)

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
			let moc = CoreDataStack.shared.mainContext
			//save in memory
			moc.delete(task)
			//write to disk
			do {
				try moc.save()
			} catch {
				print("error saving core data:\(error)")
			}
			tableView.deleteRows(at: [indexPath], with: .automatic)
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
