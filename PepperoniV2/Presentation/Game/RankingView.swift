//
//  RankingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    @State var rankedPlayers: [Player] = []
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack{
            Header(
                title: "TOTAL RANKING",
                dismissAction: {
                    showAlert = true
                }
            )
            .padding(.bottom, 20)
            ScrollView{
                ForEach(rankedPlayers.indices, id:\.self) { index in
                    if index == 0{ // 1등일 때
                        let player = rankedPlayers[index]
                        RoundedRectangle(cornerRadius:10)
                            .frame(height:80)
                            .foregroundStyle(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex:"A52DEF"), location: 0.01),
                                        .init(color: Color(hex:"873FF2"), location: 0.19),
                                        .init(color: Color(hex:"6B56F4"), location: 0.36),
                                        .init(color: Color(hex:"4ADBFF"), location: 1.0)
                                    ]),
                                    center: UnitPoint(x: 0.52, y: -0.1),
                                    startRadius: 7,
                                    endRadius: 180
                                )
                            )
                            .overlay{
                                ZStack{
                                    RoundedRectangle(cornerRadius:10)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: Color(hex: "FFD8F4"), location: 0.00),
                                                Gradient.Stop(color: Color(hex: "EA42BD"), location: 0.60),
                                                Gradient.Stop(color: Color(hex: "FFD8F4"), location: 0.78),
                                                Gradient.Stop(color: Color(hex: "904BDE"), location: 0.91)
                                            ]),
                                            startPoint: UnitPoint(x: 0.35, y: -0.1),
                                            endPoint:  UnitPoint(x: 0.45, y: 1.2)
                                        ),
                                                
                                                lineWidth: 1
                                        )
                                        .frame(height:80)
                                    HStack{
                                        Text("1위")
                                            .hakgyoansim(size: 26)
                                        Spacer()
                                        Text("\(player.nickname ?? "")")
                                            .suit(.bold, size: 22)
                                        Spacer()
                                        Text("\(player.score)점")
                                            .hakgyoansim(size: 20)
                                    }.padding(.horizontal, 15)
                                }
                                
                                
                            }
                            .padding(.init(top: 0, leading: 16, bottom: 16, trailing: 16))
                    } else if index != rankedPlayers.count-1{ //2~n-1등일 때
                        let player = rankedPlayers[index]
                        RoundedRectangle(cornerRadius:10)
                            .foregroundStyle(                    LinearGradient(
                                gradient: Gradient(colors: [Color(hex:"37363B"), Color(hex:"19191B")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height:70)
                            .overlay{
                                HStack{
                                    Text("\(index+1)위")
                                        .hakgyoansim(size: 20)
                                        .foregroundStyle(index == 1 || index == 2 ? Color.ppMint_00 : Color.ppBlueGray)
                                    Spacer()
                                    Text("\(player.nickname ?? "")")
                                        .suit(.medium, size: 18)
                                        .foregroundStyle(Color.ppWhiteGray)
                                    Spacer()
                                    Text("\(player.score)점")
                                        .hakgyoansim(size: 18)
                                        .foregroundStyle(Color.ppDarkGray_01)
                                }.padding(.init(top: 0, leading: 18, bottom: 0, trailing: 15))
                            }
                            .padding(.horizontal, 16)
                    } else { // 꼴찌일 때
                        let player = rankedPlayers[index]
                        RoundedRectangle(cornerRadius:10)
                            .foregroundStyle(Color.black)
                            .frame(height:70)
                            .overlay{
                                ZStack{
                                    RoundedRectangle(cornerRadius:10)
                                        .stroke(
                                            RadialGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color(hex:"A52DEF"), location: 0.01),
                                                    .init(color: Color(hex:"873FF2"), location: 0.19),
                                                    .init(color: Color(hex:"6B56F4"), location: 0.36),
                                                    .init(color: Color(hex:"4ADBFF"), location: 1.0)
                                                ]),
                                                center: UnitPoint(x: 0.52, y: -0.1),
                                                startRadius: 7,
                                                endRadius: 180
                                            ),
                                            lineWidth: 1
                                        )
                                        .frame(height:70)
                                    HStack{
                                        Text("꼴찌")
                                            .hakgyoansim(size: 22)
                                            .foregroundStyle(Color.ppBlueGray)
                                        Spacer()
                                        Text("\(player.nickname ?? "")")
                                            .suit(.medium, size: 18)
                                        Spacer()
                                        Text("\(player.score)점")
                                            .hakgyoansim(size: 18)
                                            .foregroundStyle(Color.ppDarkGray_01)
                                    }.padding(.horizontal, 15)
                                }
                                
                            }
                            .shadow(color: .white.opacity(0.38), radius: 8.2, x: 0, y: 0)
                            .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                    }
                    
                }
            }
            
            Spacer()
            Button {
                // 현재는 turnSetting으로 이동
                // 3: VideoPlay로 이동
                gameViewModel.retryThisQuote()
                gameViewModel.turnComplete = 0
                router.pop(depth: 4)
            } label: {
                RoundedRectangle(cornerRadius: 60)
                    .frame(height: 54)
                    .foregroundStyle(Color.ppBlueGray)
                    .overlay{
                        Text("똑같은 대사로 한번더")
                            .suit(.extraBold, size: 16)
                            .foregroundStyle(Color.ppBlack_01)
                    }
            }
            .padding(.horizontal, 16)
            
            
            Button {
                gameViewModel.turnComplete = 0
                router.popToRoot()
            } label: {
                Text("나가기")
                    .suit(.bold, size:16)
                    .foregroundStyle(Color.ppWhiteGray)
            }
            .padding(18)
        }
        .onAppear{
            rankedPlayers = gameViewModel.players.sorted { player1, player2 in
                player1.score > player2.score
            }
        }
    }
}

//#Preview {
//    RankingView()
//        .preferredColorScheme(.dark)
//}
