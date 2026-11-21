//
//  ChallengeFinalWidgetLiveActivity.swift
//  ChallengeFinalWidget
//
//  Created by Débora Cristina Silva Ferreira on 23/10/26.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents   


/// Transforma um número de segundos em um texto no formato HH:MM:SS.
///
/// Só é usado quando o cronômetro está PARADO (`isRunning == false`): o valor é fixo,
/// então podemos formatar como quisermos. Enquanto roda, quem desenha o tempo é o
/// sistema (`Text(..., style: .timer)`), que escolhe o formato sozinho (`0:05`, `1:02:05`).
private func formatElapsed(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
    }
    return String(format: "%d:%02d", minutes, remainingSeconds)
}

// MARK: - TimerLabel

/// O tempo da atividade, reutilizado em todas as apresentações da Live Activity
/// (tela bloqueada, ilha expandida e ilha compacta).
///
/// Rodando: o sistema conta sozinho a partir de `startTime`, sem o app precisar mandar
/// atualização a cada segundo (o sistema limita a frequência de updates).
/// Parado: mostra `elapsedSeconds`, o tempo final guardado pelo app.
struct TimerLabel: View {
    let context: ActivityViewContext<ChallengeFinalWidgetAttributes>
    var font: Font = .caption2
    /// De que lado da caixa de largura fixa o tempo encosta.
    /// `.leading` (padrão) para a tela bloqueada e a ilha expandida; `.trailing` na ilha compacta.
    var alignment: Alignment = .leading

    var body: some View {
        // Reserva a largura de `0:00:00` (7 caracteres), que é o formato do sistema a partir de 1 hora.
        // Sem essa reserva o texto do timer, que ocupa todo o espaço que recebe, alargaria a ilha.
        // Por reservar o caso mais largo, sobra folga enquanto o tempo é menor que 1 hora.
        Text("0:00:00")
        //Usa dígitos com largura uniforme
            .monospacedDigit()
        // utiliza a fonte passada como parametro
            .font(font)
        //Oculta o texto visualmente, mas mantém seu espaço no layout.
            .hidden()
        // O overlay coloca outra View sobre a View original.
            .overlay(alignment: alignment) {
                // Se estiver rodando
                if context.state.isRunning {
                    // Text utiliza startTime como referência
                    Text(context.state.startTime, style: .timer)
                        .monospacedDigit()
                        .font(font)
                        .lineLimit(1)
                    // permite que o texto seja reduzido até 70% do tamanho original para tentar caber no espaço disponível.
                        .minimumScaleFactor(0.7)
                        // o texto ocupa a caixa toda; isto alinha os dígitos dentro dela
                        .multilineTextAlignment(alignment == .trailing ? .trailing : .leading)
                } else {
                    // Quando o cronômetro está parado, utiliza o valor do tempo guardado ate o momento
                    Text(formatElapsed(context.state.elapsedSeconds))
                        .monospacedDigit()
                        .font(font)
                        .lineLimit(1)
                    // permite que o texto seja reduzido até 70% do tamanho original para tentar caber no espaço disponível.
                        .minimumScaleFactor(0.7)
                        // o texto ocupa a caixa toda; isto alinha os dígitos dentro dela
                        .multilineTextAlignment(alignment == .trailing ? .trailing : .leading)
                }
            }
    }
}

// MARK: - Live Activity

/// A Live Activity do cronômetro: o que aparece na tela bloqueada e na Dynamic Island
/// enquanto a atividade está em andamento.
///
/// Quem inicia, para e cancela é o `WidgetWorker` (no app). Os dados chegam por
/// `ChallengeFinalWidgetAttributes`: o grupo da atividade em `context.attributes.name`
/// e o estado do cronômetro em `context.state`.
struct ChallengeFinalWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // Interface da tela bloqueada
        ActivityConfiguration(for: ChallengeFinalWidgetAttributes.self) { context in
            // Banner da tela bloqueada (ou versão pequena, no Smart Stack do Apple Watch e no CarPlay).
            ActivityContentView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Ilha expandida (quando a pessoa segura a ilha): ícone grande à esquerda e,
                // no centro, o grupo da atividade e o tempo. As regiões possíveis são leading/center/trailing/bottom.
                // Exibe um simbolo de timer
                
                
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        VStack {
                            Spacer()
                            Image(systemName: "timer")
                                .font(.system(size: 56, weight: .bold))
                            
                            Spacer()
                        }
                        
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(context.attributes.name)
                                .font(.caption2)
                                .fontWeight(.thin)
                            
                            TimerLabel(context: context, font: .body)
                            
                        }
                        .padding(.horizontal, 8)
                        
                        Spacer()
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        VStack(alignment:.trailing) {
                            Spacer()

                            Button(intent: TogglePauseIntent()) {
                                Image(context.state.isRunning ? "buttonPause" : "buttonPlay")
                                    .resizable()
                                    .frame(width: 52, height: 52)
                                    .contentTransition(.identity)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }.padding(.horizontal, 8)


                    }
                    
                }
                
            }  compactLeading: {
                Image(systemName: "timer")
                    .font(.title)
              
                
            } compactTrailing: {
             
                
                TimerLabel(context: context, font: .caption2, alignment: .trailing)

            } minimal: {
                Image(systemName: "timer")
                    .font(.title)
            }
            // cor do contorno da ilha
            .keylineTint(Color.red)

        }
        // Adota a família pequena (Smart Stack do Apple Watch e CarPlay), além da padrão (tela bloqueada).
        .supplementalActivityFamilies([.small])
    }
}

// MARK: - ActivityContentView

/// Conteúdo da Live Activity fora da Dynamic Island.
/// Lê a família renderizada (`activityFamily`) para escolher entre o banner completo e o layout pequeno.
struct ActivityContentView: View {
    @Environment(\.activityFamily) private var activityFamily
    let context: ActivityViewContext<ChallengeFinalWidgetAttributes>

    var body: some View {
        switch activityFamily {
        case .small:
            smallBody
        default:
            mediumBody
        }
    }

    /// Banner da tela bloqueada: ícone, grupo da atividade (`attributes.name`), o tempo e o botão.
    private var mediumBody: some View {
        HStack {
            Image(systemName: "timer")
                .font(.system(size: 50, weight: .bold))

            VStack(alignment: .leading) {
                Text(context.attributes.name)
                    .font(.caption2)
                    .fontWeight(.thin)

                TimerLabel(context: context, font: .body)
            }

            Spacer()

            Button(intent: TogglePauseIntent()) {
                Image(context.state.isRunning ? "buttonPause" : "buttonPlay")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .contentTransition(.identity)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    /// Layout compacto: ícone, grupo e tempo, sem o botão, para caber em áreas pequenas.
    private var smallBody: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.title2.weight(.bold))

            VStack(alignment: .leading) {
                Text(context.attributes.name)
                    .font(.caption2)
                    .fontWeight(.thin)
                    .lineLimit(1)

                TimerLabel(context: context, font: .body)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
    }
}
    

// MARK: - Dados de preview
// Só servem para o Xcode desenhar os `#Preview` abaixo; não vão para o app.

extension ChallengeFinalWidgetAttributes {
    fileprivate static var preview: ChallengeFinalWidgetAttributes {
        ChallengeFinalWidgetAttributes(name: "World")
    }
}

extension ChallengeFinalWidgetAttributes.ContentState {
    fileprivate static var smiley: ChallengeFinalWidgetAttributes.ContentState {
        ChallengeFinalWidgetAttributes.ContentState(emoji: "😀",             startTime: Date(), isRunning: true, elapsedSeconds: 0)
    }
    
    fileprivate static var starEyes: ChallengeFinalWidgetAttributes.ContentState {
        ChallengeFinalWidgetAttributes.ContentState(emoji: "🤩",   startTime: Date(), isRunning: false, elapsedSeconds: 42)
    }
}

// Cada `#Preview` mostra uma apresentação: tela bloqueada, ilha expandida, compacta e mínima.
// Para testar o formato de 1 hora, use `startTime: Date().addingTimeInterval(-3600)` no estado de preview.
#Preview("Notification", as: .content, using: ChallengeFinalWidgetAttributes.preview) {
    ChallengeFinalWidgetLiveActivity()
} contentStates: {
    ChallengeFinalWidgetAttributes.ContentState.smiley
    ChallengeFinalWidgetAttributes.ContentState.starEyes
}


#Preview("Ilha expandida", as: .dynamicIsland(.expanded), using: ChallengeFinalWidgetAttributes.preview) {
    ChallengeFinalWidgetLiveActivity()
} contentStates: {
    ChallengeFinalWidgetAttributes.ContentState.smiley
}

#Preview("Ilha compacta", as: .dynamicIsland(.compact), using: ChallengeFinalWidgetAttributes.preview) {
    ChallengeFinalWidgetLiveActivity()
} contentStates: {
    ChallengeFinalWidgetAttributes.ContentState.smiley
}

#Preview("Ilha mínima", as: .dynamicIsland(.minimal), using: ChallengeFinalWidgetAttributes.preview) {
    ChallengeFinalWidgetLiveActivity()
} contentStates: {
    ChallengeFinalWidgetAttributes.ContentState.smiley
}
