//
//  PresetCatalog+Connection.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 12/11/26.
//

import Foundation

/// Desafios pré-prontos da categoria conexão.
extension PresetCatalog {
    static let connection: [PresetChallenge] = [
        PresetChallenge(
            title: "o gesto é pequeno, o efeito não",
            subTitle: "Mande um “pensei em você”",
            rationale: "Escolha alguém e mande uma mensagem dizendo que pensou nela hoje, sem pedir nada e sem esperar nada.",
            achievement: PresetAchievement(
                title: "pensei em você",
                description: "você passou {tempo} alegrando o dia de alguém com um “pensei em você”"
            )
        ),
        PresetChallenge(
            title: "gratidão não tem prazo",
            subTitle: "Agradeça por algo antigo",
            rationale: "Pense em alguém que te ajudou um dia e mande uma mensagem de agradecimento, citando o que a pessoa fez.",
            achievement: PresetAchievement(
                title: "gratidão vintage",
                description: "você passou {tempo} agradecendo a alguém por algo que nunca agradeceu"
            )
        ),
        PresetChallenge(
            title: "pendências também pesam",
            subTitle: "Responda aquela mensagem",
            rationale: "Abra a conversa que você está adiando responder e responda agora, mesmo que seja uma resposta simples.",
            achievement: PresetAchievement(
                title: "pendência zerada",
                description: "você passou {tempo} respondendo aquela mensagem que estava adiando"
            )
        ),
        PresetChallenge(
            title: "reconhecer em voz alta",
            subTitle: "Elogie por escrito",
            rationale: "Pense em alguém que você admira e mande uma mensagem dizendo uma qualidade específica dela.",
            achievement: PresetAchievement(
                title: "admiração dita",
                description: "você passou {tempo} escrevendo a alguém o que admira nela"
            )
        ),
        PresetChallenge(
            title: "histórias compartilhadas",
            subTitle: "Lembre de uma boa memória a dois",
            rationale: "Escolha uma pessoa e mande a ela uma lembrança boa que vocês viveram juntos, com um “lembra quando...?”.",
            achievement: PresetAchievement(
                title: "lembra quando?",
                description: "você passou {tempo} revivendo um momento bom com alguém"
            )
        ),
        PresetChallenge(
            title: "voz vale mais que texto",
            subTitle: "Ligue para alguém querido",
            rationale: "Ligue agora para alguém de quem você gosta, nem que seja por 3 minutos. Pergunte como a pessoa está.",
            achievement: PresetAchievement(
                title: "voz que aproxima",
                description: "você passou {tempo} ao telefone e fez a diferença para alguém"
            )
        ),
        PresetChallenge(
            title: "curiosidade pelo outro",
            subTitle: "Pergunte uma coisa que nunca perguntou",
            rationale: "Escolha alguém próximo e mande uma pergunta que nunca fez a ela, como “qual foi seu primeiro emprego?”.",
            achievement: PresetAchievement(
                title: "pergunta inédita",
                description: "você passou {tempo} conhecendo melhor alguém que achava que conhecia"
            )
        ),
        PresetChallenge(
            title: "leveza depois da conversa",
            subTitle: "Peça desculpas pendentes",
            rationale: "Se existe alguém a quem você deve um pedido de desculpas simples, mande agora uma mensagem honesta e curta.",
            achievement: PresetAchievement(
                title: "alma mais leve",
                description: "você passou {tempo} tomando coragem e pediu desculpas"
            )
        ),
        PresetChallenge(
            title: "boa coisa se divide",
            subTitle: "Compartilhe algo que te fez bem",
            rationale: "Mande a alguém uma música, texto ou foto que te fez bem e diga por que lembrou da pessoa.",
            achievement: PresetAchievement(
                title: "bem dividido",
                description: "você passou {tempo} dividindo algo que te fez bem com alguém"
            )
        ),
        PresetChallenge(
            title: "quem está no seu time",
            subTitle: "Pense em três pessoas importantes",
            rationale: "Pense em três pessoas que fazem diferença na sua vida. Quando foi a última vez que disse isso a elas?",
            achievement: PresetAchievement(
                title: "time do coração",
                description: "você passou {tempo} lembrando de quem faz diferença na sua vida"
            )
        ),
        PresetChallenge(
            title: "algumas conexões só estão em pausa",
            subTitle: "Retome uma amizade antiga",
            rationale: "Mande uma mensagem genuína a um colega de escola com quem perdeu contato, perguntando como ele está.",
            achievement: PresetAchievement(
                title: "amizade de volta",
                description: "você passou {tempo} reativando uma amizade que estava em pausa"
            )
        ),
        PresetChallenge(
            title: "voz em tempo real",
            subTitle: "Ligue em vez de mandar áudio",
            rationale: "Em vez de mandar áudio ou texto, ligue para alguém que você gosta e converse por uns minutos.",
            achievement: PresetAchievement(
                title: "tempo real",
                description: "você passou {tempo} numa ligação em vez de mandar áudio"
            )
        ),
        PresetChallenge(
            title: "histórias passadas de mão em mão",
            subTitle: "Peça uma recomendação",
            rationale: "Peça a alguém uma recomendação de livro, filme ou música e depois conte o que achou.",
            achievement: PresetAchievement(
                title: "de mão em mão",
                description: "você passou {tempo} pedindo uma recomendação e ganhou um presente"
            )
        ),
        PresetChallenge(
            title: "pedir também aproxima",
            subTitle: "Peça uma ajudinha",
            rationale: "Peça a alguém uma ajuda pequena, como uma dica ou uma opinião. Pedir ajuda cria vínculo.",
            achievement: PresetAchievement(
                title: "vínculo criado",
                description: "você passou {tempo} pedindo uma ajudinha e se aproximou de alguém"
            )
        ),
        PresetChallenge(
            title: "humor também conecta",
            subTitle: "Mande um meme exclusivo",
            rationale: "Escolha um meme que só uma pessoa específica entenderia e envie a ela, sem explicar nada.",
            achievement: PresetAchievement(
                title: "meme exclusivo",
                description: "você passou {tempo} escolhendo um meme que só uma pessoa entenderia"
            )
        ),
        PresetChallenge(
            title: "reagir é mais que curtir",
            subTitle: "Responda um story de verdade",
            rationale: "Escolha o story de alguém e responda com uma mensagem de verdade, em vez de um emoji.",
            achievement: PresetAchievement(
                title: "mais que emoji",
                description: "você passou {tempo} respondendo um story com uma mensagem de verdade"
            )
        ),
        PresetChallenge(
            title: "interesse genuíno",
            subTitle: "Pergunte do dia a um familiar",
            rationale: "Mande uma mensagem para alguém da sua família perguntando como foi o dia dela e o que deixou mais feliz.",
            achievement: PresetAchievement(
                title: "laço de família",
                description: "você passou {tempo} perguntando como foi o dia de alguém da família"
            )
        ),
        PresetChallenge(
            title: "voz traz presença",
            subTitle: "Mande um áudio de 30 segundos",
            rationale: "Grave um áudio curto contando algo bom que aconteceu com você e envie a alguém que gosta de ouvir você.",
            achievement: PresetAchievement(
                title: "áudio do bem",
                description: "você passou {tempo} gravando um áudio sobre uma coisa boa que viveu"
            )
        ),
        PresetChallenge(
            title: "confiar também conecta",
            subTitle: "Peça um conselho",
            rationale: "Pense em algo que você está decidindo e peça a opinião de alguém em quem você confia, por mensagem.",
            achievement: PresetAchievement(
                title: "conselho pedido",
                description: "você passou {tempo} pedindo um conselho e se sentiu mais leve"
            )
        ),
        PresetChallenge(
            title: "vibrar pelo outro",
            subTitle: "Celebre uma conquista",
            rationale: "Lembre de algo bom que aconteceu com alguém e mande uma mensagem celebrando, mesmo que atrasada.",
            achievement: PresetAchievement(
                title: "vibra junto",
                description: "você passou {tempo} celebrando a conquista de alguém"
            )
        ),
        PresetChallenge(
            title: "futuro compartilhado",
            subTitle: "O que você está esperando?",
            rationale: "Pergunte a um amigo qual é a coisa que ele mais espera para as próximas semanas. Responda também.",
            achievement: PresetAchievement(
                title: "futuro em comum",
                description: "você passou {tempo} descobrindo o que um amigo mais espera"
            )
        ),
        PresetChallenge(
            title: "reconhecer influência",
            subTitle: "Diga o que aprendeu com ela",
            rationale: "Pense em alguém de quem você aprendeu algo importante e mande uma mensagem contando o que foi.",
            achievement: PresetAchievement(
                title: "boa influência",
                description: "você passou {tempo} contando a alguém o que aprendeu com ela"
            )
        ),
        PresetChallenge(
            title: "planejar aproxima",
            subTitle: "Proponha um plano",
            rationale: "Proponha a alguém um plano simples para os próximos dias, como um café, uma caminhada ou uma videochamada.",
            achievement: PresetAchievement(
                title: "plano marcado",
                description: "você passou {tempo} marcando um plano e saiu do “a gente se vê”"
            )
        ),
        PresetChallenge(
            title: "nostalgia compartilhada",
            subTitle: "Mande uma foto antiga",
            rationale: "Escolha uma foto antiga em que você e alguém estão juntos e envie com uma legenda curta e carinhosa.",
            achievement: PresetAchievement(
                title: "nostalgia pura",
                description: "você passou {tempo} revendo uma foto antiga e puxou uma boa lembrança"
            )
        ),
        PresetChallenge(
            title: "lembrar é cuidar",
            subTitle: "Retome o assunto",
            rationale: "Pense em algo que alguém te contou recentemente e mande uma mensagem perguntando como ficou.",
            achievement: PresetAchievement(
                title: "escuta ativa",
                description: "você passou {tempo} retomando um assunto que alguém tinha contado"
            )
        ),
        PresetChallenge(
            title: "atenção em vez de curtida",
            subTitle: "Comente de verdade",
            rationale: "Escolha a publicação de alguém e deixe um comentário sincero e específico sobre o que gostou.",
            achievement: PresetAchievement(
                title: "além da curtida",
                description: "você passou {tempo} comentando de verdade em vez de só curtir"
            )
        ),
        PresetChallenge(
            title: "trilha sonora do outro",
            subTitle: "Qual música você está ouvindo?",
            rationale: "Pergunte a alguém qual música está marcando a semana dela e peça o link.",
            achievement: PresetAchievement(
                title: "trilha sonora",
                description: "você passou {tempo} descobrindo a música da semana de alguém"
            )
        ),
        PresetChallenge(
            title: "família além da rotina",
            subTitle: "Mande mensagem a um parente distante",
            rationale: "Escolha um parente com quem fala pouco, como um primo, tio ou avó, e pergunte por mensagem como ele está.",
            achievement: PresetAchievement(
                title: "família ampliada",
                description: "você passou {tempo} conversando com um parente com quem falava pouco"
            )
        ),
        PresetChallenge(
            title: "presença sem cobrança",
            subTitle: "Diga “estou aqui”",
            rationale: "Pense em alguém numa fase difícil e mande uma mensagem dizendo que está por perto, sem esperar resposta.",
            achievement: PresetAchievement(
                title: "estou aqui",
                description: "você passou {tempo} dizendo “estou aqui” a quem talvez precisasse"
            )
        ),
        PresetChallenge(
            title: "carinho com motivo",
            subTitle: "Diga por que gosta dela",
            rationale: "Mande a alguém uma mensagem dizendo um motivo específico pelo qual você gosta da companhia dela.",
            achievement: PresetAchievement(
                title: "boa companhia",
                description: "você passou {tempo} contando a alguém por que gosta da companhia dela"
            )
        ),
        PresetChallenge(
            title: "datas que aproximam",
            subTitle: "Adiante um parabéns",
            rationale: "Veja quem faz aniversário nesta semana e mande uma mensagem agora ou anote para não esquecer.",
            achievement: PresetAchievement(
                title: "parabéns em dia",
                description: "você passou {tempo} se adiantando para o aniversário de alguém"
            )
        ),
        PresetChallenge(
            title: "quem deixa sua rotina leve",
            subTitle: "Agradeça a quem facilita",
            rationale: "Mande um agradecimento a alguém que facilita sua rotina, como um colega, vizinho ou porteiro.",
            achievement: PresetAchievement(
                title: "gentileza diária",
                description: "você passou {tempo} agradecendo a alguém que facilita o seu dia"
            )
        ),
        PresetChallenge(
            title: "perguntar e escutar",
            subTitle: "Como você está, de verdade?",
            rationale: "Pergunte a alguém próximo “como você está, de verdade?” e dê espaço para a resposta, sem pressa.",
            achievement: PresetAchievement(
                title: "ouvido amigo",
                description: "você passou {tempo} escutando de verdade como alguém está"
            )
        ),
        PresetChallenge(
            title: "compartilhe o seu momento",
            subTitle: "Mande uma foto do agora",
            rationale: "Tire uma foto de algo bonito ou curioso ao seu redor e envie a alguém dizendo que lembrou dela.",
            achievement: PresetAchievement(
                title: "foto do agora",
                description: "você passou {tempo} capturando o seu momento e mandou para alguém"
            )
        ),
        PresetChallenge(
            title: "conexões que você cria",
            subTitle: "Apresente duas pessoas",
            rationale: "Pense em duas pessoas que se dariam bem e apresente uma à outra por mensagem, explicando por quê.",
            achievement: PresetAchievement(
                title: "elo perfeito",
                description: "você passou {tempo} apresentando duas pessoas que tinham tudo a ver"
            )
        ),
        PresetChallenge(
            title: "reconhecer faz diferença",
            subTitle: "Elogie o trabalho de alguém",
            rationale: "Mande a um colega uma mensagem elogiando algo específico que ele fez bem recentemente.",
            achievement: PresetAchievement(
                title: "elogio de peso",
                description: "você passou {tempo} elogiando o trabalho de um colega"
            )
        ),
        PresetChallenge(
            title: "deixe que te conheçam",
            subTitle: "Conte uma novidade sua",
            rationale: "Mande a um amigo uma novidade sua, mesmo pequena. Compartilhar também aproxima.",
            achievement: PresetAchievement(
                title: "livro aberto",
                description: "você passou {tempo} contando uma novidade sua para um amigo"
            )
        ),
        PresetChallenge(
            title: "risadas que só vocês têm",
            subTitle: "Relembre uma piada interna",
            rationale: "Mande a alguém uma piada interna antiga de vocês, sem contexto, e veja se a pessoa lembra.",
            achievement: PresetAchievement(
                title: "piada interna",
                description: "você passou {tempo} relembrando uma piada interna e arrancou risadas"
            )
        ),
        PresetChallenge(
            title: "saudade dita aproxima",
            subTitle: "Diga que sente saudade",
            rationale: "Mande uma mensagem a alguém de quem sente falta dizendo apenas isso: que está com saudade.",
            achievement: PresetAchievement(
                title: "saudade dita",
                description: "você passou {tempo} dizendo a alguém que estava com saudade"
            )
        ),
        PresetChallenge(
            title: "histórias de quem você ama",
            subTitle: "Peça uma lembrança de infância",
            rationale: "Pergunte a um familiar mais velho qual é a lembrança favorita da infância dele.",
            achievement: PresetAchievement(
                title: "baú de histórias",
                description: "você passou {tempo} ouvindo uma lembrança de infância de um familiar"
            )
        ),
        PresetChallenge(
            title: "estar disponível é um presente",
            subTitle: "Ofereça ajuda",
            rationale: "Mande a alguém uma mensagem perguntando se precisa de ajuda com algo nesta semana.",
            achievement: PresetAchievement(
                title: "mão estendida",
                description: "você passou {tempo} oferecendo ajuda a alguém sem esperar pedido"
            )
        ),
        PresetChallenge(
            title: "carinho em papel",
            subTitle: "Deixe um bilhete",
            rationale: "Escreva um bilhete curto e carinhoso e deixe onde alguém da sua casa vai encontrar.",
            achievement: PresetAchievement(
                title: "carinho em papel",
                description: "você passou {tempo} escrevendo um bilhete carinhoso a alguém da casa"
            )
        ),
        PresetChallenge(
            title: "o outro também tem paixões",
            subTitle: "Pergunte sobre um hobby",
            rationale: "Pergunte a alguém sobre um hobby ou interesse dela e peça para contar como tudo começou.",
            achievement: PresetAchievement(
                title: "hobby em pauta",
                description: "você passou {tempo} ouvindo alguém falar sobre o que ama fazer"
            )
        ),
        PresetChallenge(
            title: "sua dica pode fazer o dia",
            subTitle: "Indique algo para alguém",
            rationale: "Mande a alguém uma indicação de livro, série, receita ou lugar, dizendo por que ela vai gostar.",
            achievement: PresetAchievement(
                title: "dica certeira",
                description: "você passou {tempo} indicando algo que tinha tudo a ver com alguém"
            )
        ),
        PresetChallenge(
            title: "torcida também conecta",
            subTitle: "Mande um “boa sorte”",
            rationale: "Pense em alguém que tem algo importante pela frente e mande uma mensagem de boa sorte.",
            achievement: PresetAchievement(
                title: "torcida oficial",
                description: "você passou {tempo} torcendo por alguém e mandou boa sorte"
            )
        ),
        PresetChallenge(
            title: "ver o rosto aproxima",
            subTitle: "Faça uma videochamada",
            rationale: "Ligue por vídeo para alguém que mora longe, nem que seja por 5 minutos.",
            achievement: PresetAchievement(
                title: "perto de longe",
                description: "você passou {tempo} em videochamada com alguém que mora longe"
            )
        ),
        PresetChallenge(
            title: "lugares guardam histórias",
            subTitle: "Lembre de um lugar juntos",
            rationale: "Mande a alguém o nome de um lugar onde vocês estiveram juntos e pergunte do que ela lembra.",
            achievement: PresetAchievement(
                title: "mapa afetivo",
                description: "você passou {tempo} relembrando com alguém um lugar especial"
            )
        ),
        PresetChallenge(
            title: "conexão ao vivo",
            subTitle: "Converse com quem está perto",
            rationale: "Puxe uma conversa rápida com alguém que está perto de você agora, em casa ou no trabalho.",
            achievement: PresetAchievement(
                title: "papo ao vivo",
                description: "você passou {tempo} conversando com quem estava por perto"
            )
        ),
        PresetChallenge(
            title: "orgulho dito chega mais longe",
            subTitle: "Diga “tenho orgulho de você”",
            rationale: "Mande a alguém uma mensagem dizendo que tem orgulho de algo que ela fez ou está fazendo.",
            achievement: PresetAchievement(
                title: "fã número 1",
                description: "você passou {tempo} mostrando a alguém o orgulho que sente dela"
            )
        ),
    ]
}
