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
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top)
                ], alignment: .leading, spacing: 16, content: {
                    ForEach(vm.results, id: \.self) { app in
                        AppInfo(app: app)
                    }
                })
                .padding(.horizontal, 12)
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
