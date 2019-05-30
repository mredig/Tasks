//
//  TaskController.swift
//  Tasks
//
//  Created by Michael Redig on 5/29/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import Foundation
import CoreData

class TaskController {
	let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!

	let networkHandler = NetworkHandler()

	func put(task: Task, completion: @escaping (Result<TaskRepresentation, NetworkError>) -> Void) {
		let identifier = task.identifier ?? UUID()
		task.identifier = identifier

		let requestURL = baseURL
			.appendingPathComponent(identifier.uuidString)
			.appendingPathExtension("json")

		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethods.put.rawValue

		guard let taskRep = task.taskRepresentation else {
			completion(.failure(.otherError(error: NSError())))
			return
		}
		let encoder = JSONEncoder()
		do {
			request.httpBody = try encoder.encode(taskRep)
		} catch {
			completion(.failure(.dataCodingError(specifically: error)))
			return
		}
		 try? saveToPersistentStore()

		networkHandler.transferMahCodableDatas(with: request, completion: completion)

	}

	func fetchTasksFromServer(completion: @escaping (Result<[TaskRepresentation], NetworkError>) -> Void) {
		let requestURL = baseURL.appendingPathExtension("json")

		let request = URLRequest(url: requestURL)
		networkHandler.transferMahCodableDatas(with: request) { (result: Result<[String: TaskRepresentation], NetworkError>) in
			do {
				let taskReps = try result.get()
				let taskRepsArray = Array(taskReps.values)
				try self.updateTasks(with: taskRepsArray)
				completion(.success(taskRepsArray))
			} catch {
				completion(.failure(error as? NetworkError ?? NetworkError.otherError(error: error)))
			}
		}
	}


	private func updateTasks(with taskRepresentations: [TaskRepresentation]) throws {
		for taskRep in taskRepresentations {
			guard let identifier = UUID(uuidString: taskRep.identifier) else { continue }
			if let task = getTaskFromCoreData(forUUID: identifier) {
				task.name = taskRep.name
				task.notes = taskRep.notes
				task.setPriority(str: taskRep.priority)
			} else {
				_ = Task(taskRepresentation: taskRep)
			}
		}
		try saveToPersistentStore()
	}

	private func getTaskFromCoreData(forUUID uuid: UUID) -> Task? {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
		do {
			let moc = CoreDataStack.shared.mainContext
			return try moc.fetch(fetchRequest).first
		} catch {
			NSLog("error fetching task with id '\(uuid)': \(error)")
			return nil
		}
	}

	func saveToPersistentStore() throws {
		let moc = CoreDataStack.shared.mainContext
		try moc.save()
	}
}
