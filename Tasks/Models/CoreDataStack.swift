//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Michael Redig on 5/27/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	static let shared = CoreDataStack()
	private init() {}

	lazy var container: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Tasks")
		container.loadPersistentStores(completionHandler: { (_, error) in
			if let error = error {
				fatalError("Failed to load persistent stores: \(error)")
			}
		})
		return container
	}()

	var mainContext: NSManagedObjectContext {
		return container.viewContext
	}
}
