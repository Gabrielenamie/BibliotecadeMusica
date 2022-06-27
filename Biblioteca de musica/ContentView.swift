//
//  ContentView.swift
//  Biblioteca de musica
//
//  Created by Gabriele Namie on 16/06/22.
//

import SwiftUI
import MusicKit

struct Item: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let artist: String
    let imageUrl: URL?
}

struct ContentView: View {
    @State var songs = [Item]()
    
    var body: some View {
        NavigationView{
            List(songs) {song in HStack {
                AsyncImage(url: song.imageUrl)
                    .frame(width: 75, height: 75, alignment: .center)
                VStack (alignment: .leading) {
                    Text(song.name)
                        .font(.title)
                    Text(song.artist)
                        .font(.footnote)
                    }
                 .padding()
                }
            }
        }
        .onAppear {fetchMusic()}
    }
    
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Love", types: [Song.self])
        
        request.limit = 30
        return request
    }()
    
    private func fetchMusic() {
        Task{
            //Pedir permissão
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                //Pedido -> Resposta
                do{
                    let result = try await request.response()
                    //Adicionar musica
                    self.songs = result.songs.compactMap({return .init(name: $0.title, artist: $0.artistName, imageUrl: $0.artwork?.url(width: 75, height: 75))
                    })
                    print(String(describing: songs[0]))
                    
                } catch {
                    print(String(describing: error))
                }
            default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
