import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: CustomStringConvertible, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
    }

    var description: String {
        let status = isCompleted ? "✅" : "❌"
        return "\(status) \(title)"
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system 
// to persist and retrieve the list of todos. 
// Utilize Swift's `FileManager` to handle file operations.
final class FileSystemCache: Cache {
    private let fileName = "todos.json"

    private var fileURL: URL? {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsURL.appendingPathComponent(fileName)
        }
        return nil
    }

    func save(todos: [Todo]) {
        guard let fileURL = fileURL else { return }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(todos)
            try data.write(to: fileURL)
        } catch {
            print("\n❗ Failed to save todos! Error: \(error)")
        }
    }

    func load() -> [Todo]? {
        guard let fileURL = fileURL else { return nil }
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileURL)
            let todos = try decoder.decode([Todo].self, from: data)
            return todos
        } catch {
            print("\n❗ Failed to load todos! Error: \(error)")
            return nil
        }
    }
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session. 
// This won't retain todos across different app launches, 
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    private var todos: [Todo] = []
    
    func save(todos: [Todo]) {
        self.todos = todos
    }
    
    func load() -> [Todo]? {
        return todos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)` 
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
    var todos: [Todo] = []
    var cache: Cache

    init(cache: Cache) {
        self.cache = cache
        self.todos = cache.load() ?? []
    }

    func listTodos() {
        if todos.isEmpty {
            print("\n❗ No todos!")
        } else {
            print("\n📝 Your Todos:\n")
            for (index, todo) in todos.enumerated() {
                let status = todo.isCompleted ? "✅" : "❌"
                print("\t\(index + 1). \(status) \(todo.title)")
            }
        }
    }

    func addTodo(with title: String) {
        let newTodo = Todo(title: title)
        todos.append(newTodo)
        cache.save(todos: todos)
        print("\n📌 Todo added!")
    }

    func toggleCompletion(forTodoAtIndex index: Int) {
        guard index >= 0 && index < todos.count else {
            print("\n❗ Invalid index!")
            return
        }
        todos[index].isCompleted.toggle()
        cache.save(todos: todos)
        print("\n🔄 Todo completion status toggled!")
        
    }

    func deleteTodo(atIndex index: Int) {
        guard index >= 0 && index < todos.count else {
            print("\n❗ Invalid index!")
            return
        }
        todos.remove(at: index)
        cache.save(todos: todos)
        print("\n🗑️  Todo deleted!")
    }
}
// * The `App` class should have a `func run()` method, this method should perpetually 
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases 
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
    private var todoManager = TodoManager(cache: cache)
    
    enum Command: String {
        case add
        case list
        case toggle
        case delete
        case exit
    }
    
    init(cache: Cache) {
        self.todoManager = TodoManager(cache: cache)
    }

    func run() {
        var runStatus = true

        while runStatus {
            print("\nWhat would you like to do? (add, list, toggle, delete, exit): ", terminator: "")

            if let input = readLine() {
                let command = Command(rawValue: String(input))

                switch command {
                case .add:
                    print("\nEnter Todo title: ", terminator: "")
                    if let title = readLine() {
                        todoManager.addTodo(with: title)
                    }
                case .list:
                    todoManager.listTodos()
                case .toggle:
                    todoManager.listTodos()
                    if todoManager.todos.isEmpty {
                        break
                    } else {
                        print("\nEnter the number of the todo to toggle: ", terminator: "")
                        if let toggleNumber = readLine() {
                            if let index = Int(toggleNumber) {
                                todoManager.toggleCompletion(forTodoAtIndex: index - 1)
                            } else {
                                print("\n❗ Invalid index!")
                            }
                        }
                    }
                case .delete:
                    todoManager.listTodos()
                    if todoManager.todos.isEmpty {
                        break
                    } else {
                        print("\nEnter the number of the todo to delete: ", terminator: "")
                        if let deletedNumber = readLine() {
                            if let index = Int(deletedNumber) {
                                todoManager.deleteTodo(atIndex: index - 1)
                            } else {
                                print("\n❗ Invalid index!")
                            }
                        }
                    }
                case .exit:
                    runStatus = false
                    print("\n👋 Exiting the app!\n")
                default:
                    print("\n❗ Unknown command!")
                }
            }
        }
    }
}
// TODO: Write code to set up and run the app.
print("\n🌟 Welcome to Todo CLI! 🌟")

let useFileSystemCache = true // set to false if you want to use in-memory cache
let cache: Cache = useFileSystemCache ? FileSystemCache() : InMemoryCache()

let user = App(cache: cache)
user.run()