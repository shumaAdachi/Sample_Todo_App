//
//  TodoStore.swift
//  Sample_App
//
//  Created by 安達秀馬 on 2026/04/06.
//

import Foundation
func saveTodos(_ todos: [Todo]) {
    if let data = try? JSONEncoder().encode(todos) {
        UserDefaults.standard.set(data, forKey: "todos")
    }
}

func loadTodos() -> [Todo] {
    if let data = UserDefaults.standard.data(forKey: "todos"),
       let todos = try? JSONDecoder().decode([Todo].self, from: data) {
        return todos
    }
    return []
}
