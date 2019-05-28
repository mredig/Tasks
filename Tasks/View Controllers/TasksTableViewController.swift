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
	var tasks: [Task] {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		let moc = CoreDataStack.shared.mainContext
		do {
			return try moc.fetch(fetchRequest)
		} catch {
			print("error fetching tasks: \(error)")
			return []
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetail" {
			let detailVC = segue.destination as! TaskDetailViewController
			if let indexPath = tableView.indexPathForSelectedRow {
				detailVC.task = tasks[indexPath.row]
			}
		}
	}
}

extension TasksTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

		let task = tasks[indexPath.row]
		cell.textLabel?.text = task.name

		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let task = tasks[indexPath.row]
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
