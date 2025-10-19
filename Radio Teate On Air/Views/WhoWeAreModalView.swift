//
//  WhoWeAreModalView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//


//
//  WhoWeAreModalView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//

import SwiftUI

struct WhoWeAreModalView: View {
    @State private var content: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(content)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .padding(.top, 20)
        }
        .onAppear {
            loadContent()
        }
    }
    
    private func loadContent() {
        content = """
        La radio, con la sua capacità di raggiungere un vasto pubblico, ha dimostrato di essere uno strumento cruciale nella diffusione di notizie, cultura e intrattenimento.
        
        Fondata con l'obiettivo di fornire una piattaforma innovativa e giovane per la diffusione di contenuti radiofonici, Teate On Air combina il fascino tradizionale della radio con le potenzialità della tecnologia moderna, il primo mezzo di comunicazione di massa ripensato nell'era dei social network, diventa mezzo con la vocazione di comunicare con e tra i giovani.
        
        Il progetto è nato grazie alla passione dei volontari di Erga Omnes, sotto l'egida della Regione Abruzzo e del Comune di Chieti, in collaborazione con l'Informagiovani di Chieti, il CSV Abruzzo e l'Università degli Studi G. d'Annunzio di Chieti-Pescara.
        
        Teate On Air è la radio via internet nata a Chieti. Pensata nel periodo del lockdown, con le scuole chiuse per l'emergenza COVID-19, le piazze e le strade vietate, i locali costretti alla serrata, ecco che torna protagonista la radio per accorciare la distanza tra i giovani.
        
        All'ex-centro sociale San Martino a Chieti Scalo, in Via Monte Grappa n. 176, è stato realizzato uno studio radiofonico, da qui si parla di musica, attualità, protagonismo giovanile, opportunità formative e lavorative, ecc., il tutto visto con gli occhi dei giovani che sono i principali protagonisti.
        
        L'obiettivo di Teate On Air è quello di creare sempre di più uno spazio di aggregazione, di scambio di idee e competenze, di dare l'opportunità di crescita ai giovani e di dare voce alla cittadinanza.
        
        Il punto di nascita è Chieti ma dalle radici il progetto cresce in tutto il territorio abruzzese ed oltre e per rafforzare l'idea, che non ha scopo di lucro, si cercano giovani motivati che hanno voglia di mettersi in gioco e che possono dedicare le loro competenze e parte del loro tempo per aggiungere valore al gruppo.
        """
    }
}

#Preview {
    WhoWeAreModalView()
}