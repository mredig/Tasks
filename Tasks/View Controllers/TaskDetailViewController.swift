//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Michael Redig on 5/27/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
	@IBOutlet var nameTextField: UITextField!
	@IBOutlet var notesTextView: UITextView!
	@IBOutlet var priorityControl: UISegmentedControl!

	var taskController: TaskController?
	var task: Task? {
		didSet {
			updateViews()
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		updateViews()
	}

	private func updateViews() {
		title = task?.name ?? "Create Task"

		var name: String?
		var notes: String?
		
		task?.managedObjectContext?.performAndWait {
			name = task?.name
			notes = task?.notes
		}

		guard isViewLoaded, let task = task else { return }

		nameTextField.text = name
		notesTextView.text = notes
		priorityControl.selectedSegmentIndex = Int(task.priority)
	}

	@IBAction func save(_ sender: UIBarButtonItem) {
		guard let name = nameTextField.text, !name.isEmpty else { return }
		let notes = notesTextView.text

		let priorityIndex = priorityControl.selectedSegmentIndex
		let priority = TaskPriority(rawValue: Int16(priorityIndex)) ?? TaskPriority.normal

		CoreDataStack.shared.mainContext.performAndWait {
			if let task = task {
				// edit existing task
				task.name = name
				task.notes = notes
				task.priority = priority.rawValue
				taskController?.put(task: task, completion: { (result: Result<TaskRepresentation, NetworkError>) in
					do {
						_ = try result.get()
					} catch {
						print("error putting data: \(error)")
					}
				})
			} else {
				let task = Task(name: name, notes: notes, priority: priority)
				taskController?.put(task: task, completion: { (result: Result<TaskRepresentation, NetworkError>) in
					do {
						_ = try result.get()
					} catch {
						print("error putting data: \(error)")
					}
				})
			}

			// saved to disk here
			let moc = CoreDataStack.shared.mainContext
			do {
				try CoreDataStack.shared.save(context: moc)
			} catch {
				print("error saving managed object context: \(error)")
			}
		}
		navigationController?.popViewController(animated: true)
	}
}
