//
//  ContentView.swift
//  GridSearchSwiftUI
//
//  Created by Hakyoung Kim on 2020/11/29.
//

import SwiftUI
import KingfisherSwiftUI

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable {
    let copyright, name, artworkUrl100, releaseDate: String
}

class GridViewModel: ObservableObject {
    
    @Published var results = [Result]()
    
    init() {
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/kr/ios-apps/top-free/all/100/explicit.json") else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            do {
                guard let data = data else { return }
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                print(rss)
                DispatchQueue.main.async {
                    self.results = rss.feed.results
                }
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }
}

struct GridView: View {
    
    @StateObject var vm = GridViewModel()
    @State var searchText = ""
    @State var isSearching = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBar(searchText: $searchText, isSearching: $isSearching)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                        GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                        GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top)
                    ], alignment: .leading, spacing: 16, content: {
                        ForEach(vm.results.filter({
                            $0.name.contains(searchText) || searchText.isEmpty
                        }), id: \.self) { app in
                            AppInfo(app: app)
                        }
                    })
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Grid Search")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}

struct AppInfo: View {
    
    let app: Result
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            KFImage(URL(string: app.artworkUrl100))
                .resizable()
                .scaledToFit()
                .cornerRadius(22)
                .overlay(RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.gray, lineWidth: 0.2))
            
            Text(app.name)
                .font(.system(size: 10, weight: .semibold))
                .padding(.top, 4)
            Text(app.releaseDate)
                .font(.system(size: 9, weight: .regular))
            Text(app.copyright)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.gray)
        }
    }
}

struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                TextField("Search apps", text:$searchText)
                    .padding()
                    .padding(.horizontal, 32)
            }
            .background(Color(.systemGray5))
            .cornerRadius(6)
            .onTapGesture(perform: {
                isSearching = true
            })
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    
                    if isSearching {
                        Button(action: { searchText = "" } , label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        })
                    }
                }
                .padding(.horizontal)
                .foregroundColor(.gray)
            )
            .transition(.move(edge: .trailing))
            .animation(.spring())
            .padding(.horizontal)
            .padding(.bottom)
            
            if isSearching {
                Button("cancel") {
                    isSearching = false
                    searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.trailing)
                .padding(.leading, -16)
                .padding(.bottom)
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
        }
    }
}
