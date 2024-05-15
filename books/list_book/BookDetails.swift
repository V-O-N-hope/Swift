//
//  BookDetails.swift
//  books
//
//  Created by user on 15.05.24.
//
import SwiftUI
import Firebase
import FirebaseStorage

struct BookDetailsView: View {
    @EnvironmentObject var appPage: PageState
    @EnvironmentObject var auth: AuthState
    
    var book: Book
    var mode: Int
    
    @State private var imgUrls: [String] = [] // Хранение списка всех книг
    
    func getUrls() {
        imgUrls = []
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let folderRef = storageRef.child("images/\(book.name)")
        
        let dispatchGroup = DispatchGroup() // Создание DispatchGroup
        
        folderRef.listAll { result, error in
            if let error = error {
                print("Error listing files: \(error)")
                return
            }
            
            guard let imageFiles = result?.items else {
                print("No image files found")
                return
            }
            
            let filteredFiles = imageFiles.filter { $0.name.hasSuffix(".jpg") || $0.name.hasSuffix(".png") }
            
            for imageFile in filteredFiles {
                dispatchGroup.enter() // Вход в DispatchGroup
                
                imageFile.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                    } else if let downloadURL = url {
                        print(downloadURL)
                        imgUrls.append(downloadURL.absoluteString)
                    }
                    
                    dispatchGroup.leave() // Выход из DispatchGroup
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Этот блок выполнится, когда все операции завершатся
            
            // В этом месте imgUrls будет содержать все URL-адреса
            print("All download URLs retrieved:", imgUrls)
        }
    }
    
    func loadImage(from url: String) -> Image {
        guard let imageUrl = URL(string: url),
              let imageData = try? Data(contentsOf: imageUrl),
              let uiImage = UIImage(data: imageData) else {
            return Image(systemName: "photo")
        }
        
        return Image(uiImage: uiImage)
    }
    
    var body: some View {
        VStack {
            Text(book.name)
                .font(.title)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.8))
                )
            
            Text("By \(book.author)")
                .font(.headline)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.8))
                )
            
            HStack(spacing: 10) {
                ForEach(book.tags, id: \.self) { tag in
                    Text(tag.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.8))
                        )
                }
            }
            .padding()
            .onAppear(perform: getUrls)
            .onChange(of: imgUrls) { newImgUrls in
                
            }
        }
        
        ScrollView {
            LazyVStack {
                ForEach(imgUrls, id: \.self) { imgUrl in
                    loadImage(from: imgUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                }
            }
        }
        
        if (mode == 0){
            Button(action: addToFavorites) {
                Text("Add to favorites")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }else{
            Button(action: {
                removeFromFavorites()
                appPage.page = PageEnum.FEATURED
            }) {
                Text("Delete from favorites")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
    
    func addToFavorites() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }
        
        let b_name = book.name
        
        let database = Database.database().reference()
        let prefsRef = database.child("prefs").child(uid)
        
        prefsRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if var prefsData = snapshot.value as? [String] {
                    if !prefsData.contains(b_name) {
                        prefsData.append(b_name)
                        prefsRef.setValue(prefsData)
                        print("Book added to favorites")
                    } else {
                        print("Book is already in favorites")
                    }
                }
            } else {
                let prefsData = [b_name]
                prefsRef.setValue(prefsData)
                print("Book added to favorites")
            }
        }
    }

    func removeFromFavorites() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }
        
        let b_name = book.name
        
        let database = Database.database().reference()
        let prefsRef = database.child("prefs").child(uid)
        
        prefsRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if var prefsData = snapshot.value as? [String] {
                    if let index = prefsData.firstIndex(of: b_name) {
                        prefsData.remove(at: index)
                        prefsRef.setValue(prefsData)
                        print("Book removed from favorites")
                    } else {
                        print("Book is not in favorites")
                    }
                } else {
                    print("Invalid data format")
                }
            } else {
                print("No favorites found")
            }
        }
    }
}

