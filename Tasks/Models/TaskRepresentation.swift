//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Michael Redig on 5/29/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable {
	let name: String
	let notes: String?
	let priority: String
	let identifier: String
}

struct TaskRepresentationMessage: Codable {
	let message: String
}
