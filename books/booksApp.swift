//
//  booksApp.swift
//  books
//
//  Created by user on 15.05.24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

enum PageEnum {
    case SIGNIN
    case DETAILS
    case FEATURED
    case PROFILE
    case ITEMS
    case SIGNUP
}

class PageState: ObservableObject {
    @Published var page: PageEnum
    var bookViewMode: Int
    var selectedBook: Book
    
    init(page: PageEnum){
        self.page = page
        bookViewMode = 0
        selectedBook = Book.init(name: "",author: "", tags: [])
    }
}

class AuthState: ObservableObject {
    @Published var authorized: Bool
    
    
    init(authorized: Bool){
        self.authorized = false;
    }
}

@main
struct booksApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject var appPage = PageState(page: PageEnum.SIGNIN)
    @ObservedObject var auth = AuthState(authorized: false)
    var body: some Scene {
        WindowGroup {
            switch(appPage.page){
            case PageEnum.SIGNUP:
                SignUpView(email:"",password: "").environmentObject(appPage)
                    .environmentObject(auth)
            case PageEnum.PROFILE:
                profileView().environmentObject(appPage).environmentObject(auth)
            case PageEnum.ITEMS:
                BooksListView().environmentObject(appPage).environmentObject(auth)
            case PageEnum.DETAILS:
                BookDetailsView(book: appPage.selectedBook, mode: appPage.bookViewMode).environmentObject(appPage).environmentObject(auth)
            case PageEnum.FEATURED:
                PrefferedBooksView().environmentObject(appPage).environmentObject(auth)
            default:
                AuthUIView(email:"",password: "").environmentObject(appPage)
                    .environmentObject(auth)
            }
        }
    }
}
