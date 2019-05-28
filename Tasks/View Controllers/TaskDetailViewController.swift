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
		guard isViewLoaded, let task = task else { return }
		nameTextField.text = task.name
		notesTextView.text = task.notes
		priorityControl.selectedSegmentIndex = Int(task.priority)
	}

	@IBAction func save(_ sender: UIBarButtonItem) {
		guard let name = nameTextField.text, !name.isEmpty else { return }
		let notes = notesTextView.text

		let priorityIndex = priorityControl.selectedSegmentIndex
		let priority = TaskPriority(rawValue: Int16(priorityIndex)) ?? TaskPriority.normal

		if let task = task {
			// edit existing task
			task.name = name
			task.notes = notes
			task.priority = priority.rawValue
		} else {
			//create new task

			// initializing the object is enough for coredata to actually incorporate the item in its context (not saved to disk though)
			_ = Task(name: name, notes: notes, priority: priority)
		}

		// saved to disk here
		let moc = CoreDataStack.shared.mainContext
		do {
			try moc.save()
		} catch {
			print("error saving managed object context: \(error)")
		}
		navigationController?.popViewController(animated: true)
	}
}
