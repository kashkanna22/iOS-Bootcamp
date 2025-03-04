//
//  ContentView.swift
//  Todoey
//
//  Created by Kashyap Kannajyosula on 2/25/25.
//

import SwiftUI

struct Todo: Identifiable {
    var id = UUID()
    var item: String
    var isDone: Bool
}

struct ContentView: View {
    @State private var todos: [Todo] = [
        Todo(item: "Buy milk from store", isDone: false),
        Todo(item: "Study for ECON410", isDone: false),
        Todo(item: "Call my parents", isDone: true)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($todos) { $todo in
                    HStack {
                        Toggle("", isOn: $todo.isDone)
                        TextField("Todo item", text: $todo.item)
                            .foregroundColor(todo.isDone ? .gray : .primary)
                            .strikethrough(todo.isDone)
                    }
                }
                .onDelete(perform: { indexSet in
                    todos.remove(atOffsets: indexSet)
                })
                
                Section {
                    Button(action: {
                        todos.append(Todo(item: "", isDone: false))
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Reminder")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Todoey")
        }
    }
}

#Preview {
    ContentView()
}
