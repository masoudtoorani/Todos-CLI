import XCTest
@testable import Sources

final class AppTests: XCTestCase {
    //Todo Struct Tests
    func testTodoStringRepresentation_WhenNotCompleted() {
        let todo = Todo(title: "Test Todo")
        XCTAssertEqual(todo.description, "❌ Test Todo", "Todo description should show ❌ when not completed.")
    }

    func testTodoStringRepresentation_WhenCompleted() {
        var todo = Todo(title: "Test Todo")
        todo.isCompleted = true
        XCTAssertEqual(todo.description, "✅ Test Todo", "Todo description should show ✅ when completed.")
    }

    //TodoManager Tests
    
    func testAddTodo() {
        let manager = TodoManager(cache: InMemoryCache())
        manager.addTodo(with: "Buy apple")
        XCTAssertEqual(manager.todos.count, 1, "There should be 1 todo after adding.")
        XCTAssertEqual(manager.todos[0].title, "Buy apple", "The todo's title should be 'Buy apple'.")
    }

    func testToggleCompletion() {
        let manager = TodoManager(cache: InMemoryCache())
        manager.addTodo(with: "Buy apple")
        manager.toggleCompletion(forTodoAtIndex: 0)
        XCTAssertTrue(manager.todos[0].isCompleted, "The todo should be marked as completed after toggling.")
    }

    func testDeleteTodo() {
        let manager = TodoManager(cache: InMemoryCache())
        manager.addTodo(with: "Buy apple")
        manager.deleteTodo(atIndex: 0)
        XCTAssertTrue(manager.todos.isEmpty, "There should be no todos after deleting.")
    }

    //InMemoryCache Tests
    
    func testInMemoryCacheSaveAndLoad() {
        let cache = InMemoryCache()
        let todo = Todo(title: "Test")
        cache.save(todos: [todo])
        let loadedTodos = cache.load()
        XCTAssertEqual(loadedTodos?.count, 1, "InMemoryCache should load 1 todo.")
        XCTAssertEqual(loadedTodos?.first?.title, "Test", "The loaded todo should have the correct title.")
    }

    //FileSystemCache Tests

    func testFileSystemCacheSaveAndLoad() {
        let cache = FileSystemCache()
        let todo = Todo(title: "Test")
        cache.save(todos: [todo])

        // Load the saved todos from the file system
        let loadedTodos = cache.load()
        XCTAssertEqual(loadedTodos?.count, 1, "FileSystemCache should load 1 todo.")
        XCTAssertEqual(loadedTodos?.first?.title, "Test", "The loaded todo should have the correct title.")
    }
    
    // Test to check if saving works by modifying the todos and loading them back
    func testFileSystemCacheUpdateAndLoad() {
        let cache = FileSystemCache()
        let todo1 = Todo(title: "Test 1")
        let todo2 = Todo(title: "Test 2")
        cache.save(todos: [todo1, todo2])

        // Update todos
        var todos = cache.load()!
        todos[0].isCompleted = true
        cache.save(todos: todos)
        
        // Load updated todos
        let loadedTodos = cache.load()
        XCTAssertEqual(loadedTodos?[0].isCompleted, true, "The first todo should be marked as completed.")
    }
}