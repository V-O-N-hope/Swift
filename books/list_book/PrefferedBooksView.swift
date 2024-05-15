//
//  PrefferedBooksView.swift
//  books
//
//  Created by user on 15.05.24.
//

import SwiftUI
import Foundation
import Firebase

struct PrefferedBooksView: View {
    @EnvironmentObject var appPage: PageState
    @EnvironmentObject var auth: AuthState
    
    @State private var books: [Book] = [] // Хранение списка всех книг
    @State private var filteredBooks: [Book] = [] // Хранение отфильтрованных книг
    @State private var searchText: String = "" // Хранение текста поиска
    @State private var preferredBooks: [String] = [] // Хранение списка предпочитаемых книг
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding()
                .background(
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                )
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.blue)
                        .padding(.top, 55) // Регулируйте отступ, чтобы подчеркивание было видно
                )
                .onChange(of: searchText) { _ in
                    filterBooks()
                }
            
            List(filteredBooks, id: \.name) { book in
                Button(action: {
                    appPage.selectedBook = book
                    appPage.bookViewMode = 1
                    appPage.page = PageEnum.DETAILS
                }) {
                    Text(book.name)
                }
            }
            .task {
                await fetchBooks() // Получение списка книг при загрузке представления
            }
        }
        
        Spacer()
        HStack{
            Spacer()
            Button(action: {appPage.page = PageEnum.PROFILE}, label: {
                VStack{
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                    Text("Profile")
                        .font(.system(size:14))
                }
            }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .frame(height:50)
            Spacer()
            Button(action: {
                appPage.page = PageEnum.ITEMS
            }, label: {
                VStack{
                    Image(systemName: "list.bullet")
                        .resizable()
                        .scaledToFit()
                    Text("Items")
                        .font(.system(size:14))
                }
                
            }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .frame(height:50)
            Spacer()
            Button(action: {
                appPage.page = PageEnum.FEATURED
            }, label: {
                VStack{
                    Image(systemName: "star.circle")
                        .resizable()
                        .scaledToFit()
                    Text("Featured")
                        .font(.system(size:14))
                }
                
            }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .frame(height:50)
            Spacer()
        }.frame(height: 50, alignment: .bottom)
    }
    
    private func fetchBooks() async {

        
        let database = Database.database().reference()
        let booksRef = database.child("books")
        
        let uid = Firebase.Auth.auth().currentUser?.uid;
        
        let prefsRef = database.child("prefs").child(uid!)

        do {
            let prefsSnapshot = try await prefsRef.getData()
            if let prefsData = prefsSnapshot.value as? [String] {
                print(prefsData)
                preferredBooks = prefsData
            }
        } catch {
            print("Error fetching preferences: \(error)")
        }
        
        do {
            let snapshot = try await booksRef.getData()
            if let booksData = snapshot.value as? [String: [String: Any]] {
                var fetchedBooks: [Book] = []
                for (_, bookData) in booksData {
                    if let name = bookData["name"] as? String,
                       let author = bookData["author"] as? String,
                       let tagsData = bookData["tags"] as? [String] {
                        var tags: [Tag] = []
                        for tagData in tagsData {
                            if let tag = Tag(rawValue: tagData) {
                                tags.append(tag)
                            }
                        }
                        let book = Book(name: name, author: author, tags: tags)
                        fetchedBooks.append(book)
                    }
                }
                books = fetchedBooks
                filterBooks() // Фильтрация книг при получении данных
            }
        } catch {
            print("Error fetching books: \(error)")
        }
    }
    
    private func filterBooks() {
        if searchText.isEmpty {
                filteredBooks = books.filter { preferredBooks.contains($0.name) } // Фильтрация книг по предпочитаемым книгам
            } else {
                filteredBooks = books.filter { $0.name.localizedCaseInsensitiveContains(searchText) && preferredBooks.contains($0.name) } // Фильтрация книг по имени и предпочитаемым книгам
            }
    }
}
