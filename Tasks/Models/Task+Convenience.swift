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
}

extension Task {
	convenience init(name: String, notes: String? = nil, priority: TaskPriority, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		self.init(context: context)
		self.name = name
		self.notes = notes
		self.priority = priority.rawValue
	}
}
