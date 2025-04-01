//
//  ContentView.swift
//  Todoey 2.0
//
//  Created by Kashyap Kannajyosula on 4/1/25.
//

import SwiftUI

struct Todo: Identifiable {
    var id = UUID()
    var item: String
    var isDone: Bool
}

struct TodoRowView: View {
    @Binding var todo: Todo
    
    var body: some View {
        HStack {
            Toggle("", isOn: $todo.isDone)
            TextField("Todo item", text: $todo.item)
                .foregroundColor(todo.isDone ? .gray : .primary)
                .strikethrough(todo.isDone)
        }
    }
}

struct ContentView: View {
    @State private var todos: [Todo] = [
        Todo(item: "Buy milk from store", isDone: false),
        Todo(item: "Study for ECON410", isDone: false),
        Todo(item: "Call my parents", isDone: true)
    ]
    
    @State private var showInfoView = false
    @State private var title: String = "Todoey"
    @State private var themeColor: Color = .blue
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($todos) { $todo in
                    TodoRowView(todo: $todo)
                }
                .onDelete { indexSet in
                    todos.remove(atOffsets: indexSet)
                }
                
                Section {
                    Button {
                        todos.append(Todo(item: "", isDone: false))
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Reminder")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(title)
            .toolbar {
                Button(action: { showInfoView = true }) {
                    Image(systemName: "info.circle")
                }
            }
            .sheet(isPresented: $showInfoView) {
                InfoView(title: $title, themeColor: $themeColor)
            }
        }
        .tint(themeColor)
    }
}

struct InfoView: View {
    @Binding var title: String
    @Binding var themeColor: Color
    @Environment(\.dismiss) var dismiss // Fix dismissal method
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("App Title")) {
                    TextField("Enter title", text: $title)
                }
                
                Section(header: Text("Theme Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                themeColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        themeColor == color ? Image(systemName: "checkmark.circle.fill").foregroundColor(.white) : nil
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") {
                    dismiss() // Correct dismissal
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
