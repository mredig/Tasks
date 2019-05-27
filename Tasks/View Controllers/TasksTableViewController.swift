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
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

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
}
