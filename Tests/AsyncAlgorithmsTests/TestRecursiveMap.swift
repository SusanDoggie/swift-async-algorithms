//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Async Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@preconcurrency import XCTest
import AsyncAlgorithms

final class TestRecursiveMap: XCTestCase {
    
    struct Dir: Hashable {
        
        var id: UUID = UUID()
        
        var parent: UUID?
        
        var name: String
        
    }
    
    struct Path: Hashable {
        
        var id: UUID
        
        var path: String
        
    }
    
    func testAsyncRecursiveMap() async {
        
        var list: [Dir] = []
        list.append(Dir(name: "root"))
        list.append(Dir(parent: list[0].id, name: "images"))
        list.append(Dir(parent: list[0].id, name: "Users"))
        list.append(Dir(parent: list[2].id, name: "Susan"))
        list.append(Dir(parent: list[3].id, name: "Desktop"))
        list.append(Dir(parent: list[1].id, name: "test.jpg"))
        
        let answer = [
            Path(id: list[0].id, path: "/root"),
            Path(id: list[1].id, path: "/root/images"),
            Path(id: list[2].id, path: "/root/Users"),
            Path(id: list[5].id, path: "/root/images/test.jpg"),
            Path(id: list[3].id, path: "/root/Users/Susan"),
            Path(id: list[4].id, path: "/root/Users/Susan/Desktop"),
        ]
        
        let _list = list
        
        let _result: AsyncRecursiveMapSequence = list.async
            .compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .recursiveMap { parent in _list.async.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        var result: [Path] = []
        
        for await item in _result {
            result.append(item)
        }
        
        XCTAssertEqual(result, answer)
    }
    
    func testAsyncThrowingRecursiveMap() async throws {
        
        var list: [Dir] = []
        list.append(Dir(name: "root"))
        list.append(Dir(parent: list[0].id, name: "images"))
        list.append(Dir(parent: list[0].id, name: "Users"))
        list.append(Dir(parent: list[2].id, name: "Susan"))
        list.append(Dir(parent: list[3].id, name: "Desktop"))
        list.append(Dir(parent: list[1].id, name: "test.jpg"))
        
        let answer = [
            Path(id: list[0].id, path: "/root"),
            Path(id: list[1].id, path: "/root/images"),
            Path(id: list[2].id, path: "/root/Users"),
            Path(id: list[5].id, path: "/root/images/test.jpg"),
            Path(id: list[3].id, path: "/root/Users/Susan"),
            Path(id: list[4].id, path: "/root/Users/Susan/Desktop"),
        ]
        
        let _list = list
        
        let _result: AsyncThrowingRecursiveMapSequence = list.async
            .compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .recursiveMap { parent in _list.async.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        var result: [Path] = []
        
        for try await item in _result {
            result.append(item)
        }
        
        XCTAssertEqual(result, answer)
    }
    
    struct View {
        
        var id: Int
        
        var children: [View] = []
    }
    
    func testAsyncRecursiveMap2() async {
        
        let tree = [
            View(id: 1, children: [
                View(id: 3),
                View(id: 4, children: [
                    View(id: 6),
                ]),
                View(id: 5),
            ]),
            View(id: 2),
        ]
        
        let views: AsyncRecursiveMapSequence = tree.async.recursiveMap { $0.children.async }
        
        var result: [Int] = []
        
        for await view in views {
            result.append(view.id)
        }
        
        XCTAssertEqual(result, Array(1...6))
    }
    
    func testAsyncThrowingRecursiveMap2() async throws {
        
        let tree = [
            View(id: 1, children: [
                View(id: 3),
                View(id: 4, children: [
                    View(id: 6),
                ]),
                View(id: 5),
            ]),
            View(id: 2),
        ]
        
        let views: AsyncThrowingRecursiveMapSequence = tree.async.recursiveMap { $0.children.async }
        
        var result: [Int] = []
        
        for try await view in views {
            result.append(view.id)
        }
        
        XCTAssertEqual(result, Array(1...6))
    }
    
}
