//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Michael Redig on 5/27/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: Int16, CaseIterable {
	case low
	case normal
	case high
	case critical

	var stringValue: String {
		switch self {
		case .low:
			return "low"
		case .normal:
			return "normal"
		case .high:
			return "high"
		case .critical:
			return "critical"
		}
	}

	static func fromStringValue(stringValue: String) -> TaskPriority? {
		switch stringValue {
		case "low":
			return .low
		case "normal":
			return .normal
		case "high":
			return .high
		case "critical":
			return .critical
		default:
			return nil
		}
	}
}

extension Task {
	convenience init(name: String, notes: String? = nil, priority: TaskPriority, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		self.init(context: context)
		self.name = name
		self.notes = notes
		self.priority = priority.rawValue
		self.identifier = identifier
	}

	//used to get task from firebase
	convenience init?(taskRepresentation: TaskRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		guard let priority = TaskPriority.fromStringValue(stringValue: taskRepresentation.priority),
			let identifier = UUID(uuidString: taskRepresentation.identifier) else { return nil }
		self.init(name: taskRepresentation.name, notes: taskRepresentation.notes, priority: priority, identifier: identifier, context: context)
	}

	//used to send task object to firebase
	var taskRepresentation: TaskRepresentation? {
		guard let actualPriority = TaskPriority(rawValue: priority)  else { return nil }
		let stringPriority = actualPriority.stringValue
		guard let name = name else { return nil }
		return TaskRepresentation(name: name, notes: notes, priority: stringPriority, identifier: identifier?.uuidString ?? "")
	}
}
