//
//  PresetCatalog+Movement.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 12/11/26.
//

import Foundation

/// Desafios pré-prontos da categoria movimento.
extension PresetCatalog {
    static let movement: [PresetChallenge] = [
        PresetChallenge(
            title: "solte o que a tela prendeu",
            subTitle: "Gire os ombros",
            rationale: "Faça 10 círculos lentos com os ombros para trás e 10 para frente. Perceba onde o corpo estava travado.",
            achievement: PresetAchievement(
                title: "ombros soltos",
                description: "você passou {tempo} girando os ombros e notou o quanto estavam tensos"
            )
        ),
        PresetChallenge(
            title: "equilíbrio em 30 segundos",
            subTitle: "Fique na ponta dos pés",
            rationale: "Fique na ponta dos pés por 30 segundos, apoiando-se numa parede ou móvel se precisar. Respire normalmente.",
            achievement: PresetAchievement(
                title: "pés de bailarina",
                description: "você passou {tempo} na ponta dos pés e acordou as panturrilhas"
            )
        ),
        PresetChallenge(
            title: "um lado de cada vez",
            subTitle: "Alongue o pescoço devagar",
            rationale: "Incline a cabeça devagar para um lado e segure por 20 segundos. Depois troque. Sem movimentos bruscos.",
            achievement: PresetAchievement(
                title: "pescoço em paz",
                description: "você passou {tempo} alongando o pescoço sem pressa e sentiu o alívio"
            )
        ),
        PresetChallenge(
            title: "o corpo também precisa de pausa",
            subTitle: "Fique em pé agora",
            rationale: "Levante-se agora e leia o resto do que quiser em pé. Mudar de posição já é movimento.",
            achievement: PresetAchievement(
                title: "de pé no scroll",
                description: "você passou {tempo} em pé e deu uma pausa ao corpo no meio do scroll"
            )
        ),
        PresetChallenge(
            title: "cuide de quem digita",
            subTitle: "Abra e feche as mãos",
            rationale: "Abra e feche as mãos 15 vezes, devagar, esticando bem os dedos. Depois balance os pulsos.",
            achievement: PresetAchievement(
                title: "pausa do teclado",
                description: "você passou {tempo} alongando as mãos que passam o dia digitando"
            )
        ),
        PresetChallenge(
            title: "flexibilidade sem meta",
            subTitle: "Toque os pés",
            rationale: "Em pé, incline o corpo para frente e vá até onde for confortável, sem forçar. Fique 20 segundos respirando.",
            achievement: PresetAchievement(
                title: "limite aceito",
                description: "você passou {tempo} alongando sem forçar e aceitou seu limite de hoje"
            )
        ),
        PresetChallenge(
            title: "articulações também precisam de atenção",
            subTitle: "Dez rotações de tornozelo",
            rationale: "Sentado ou em pé, gire cada tornozelo 10 vezes para cada lado. Perceba a diferença entre os dois lados.",
            achievement: PresetAchievement(
                title: "tornozelo livre",
                description: "você passou {tempo} girando os tornozelos e achou o lado travado"
            )
        ),
        PresetChallenge(
            title: "alinhe e respire",
            subTitle: "Postura de montanha",
            rationale: "Fique em pé com os pés paralelos, ombros relaxados e coluna alta. Respire fundo 5 vezes nessa posição.",
            achievement: PresetAchievement(
                title: "modo montanha",
                description: "você passou {tempo} alinhando o corpo e respirando com calma"
            )
        ),
        PresetChallenge(
            title: "um abraço em si mesmo",
            subTitle: "Abrace-se e alongue as costas",
            rationale: "Cruze os braços no peito como num abraço e gire o tronco devagar para um lado e para o outro, 5 vezes cada.",
            achievement: PresetAchievement(
                title: "autoabraço",
                description: "você passou {tempo} se abraçando e alongando as costas ao mesmo tempo"
            )
        ),
        PresetChallenge(
            title: "respiração que mexe o corpo",
            subTitle: "Respire expandindo as costelas",
            rationale: "Coloque as mãos nas laterais das costelas e inspire sentindo elas se abrirem. Repita 8 vezes, bem devagar.",
            achievement: PresetAchievement(
                title: "respiro amplo",
                description: "você passou {tempo} respirando e sentindo as costelas se expandirem"
            )
        ),
        PresetChallenge(
            title: "postura é treino",
            subTitle: "Sente sem encosto",
            rationale: "Sente sem apoiar as costas por 5 minutos, com a coluna alinhada. Perceba quando o corpo pede para desistir.",
            achievement: PresetAchievement(
                title: "coluna de aço",
                description: "você passou {tempo} sem encostar na cadeira e sentiu o core trabalhar"
            )
        ),
        PresetChallenge(
            title: "força que vem de você",
            subTitle: "Sente e levante sem as mãos",
            rationale: "Numa cadeira firme, levante e sente 10 vezes sem apoiar as mãos. Vá devagar e controle a descida.",
            achievement: PresetAchievement(
                title: "sem as mãos",
                description: "você passou {tempo} sentando e levantando sem usar as mãos"
            )
        ),
        PresetChallenge(
            title: "equilíbrio é treino",
            subTitle: "Um pé só por 30 segundos",
            rationale: "Fique num pé só por 30 segundos, com uma parede ou móvel por perto para se apoiar. Troque de pé e repita.",
            achievement: PresetAchievement(
                title: "modo flamingo",
                description: "você passou {tempo} num pé só e descobriu seu lado mais fraco"
            )
        ),
        PresetChallenge(
            title: "solte quem trabalha o dia todo",
            subTitle: "Gire os punhos",
            rationale: "Gire os punhos 10 vezes para cada lado, devagar. Depois sacuda as mãos soltas por alguns segundos.",
            achievement: PresetAchievement(
                title: "punhos leves",
                description: "você passou {tempo} soltando os punhos depois de horas de tela"
            )
        ),
        PresetChallenge(
            title: "ocupe todo o espaço",
            subTitle: "Alongue para o alto",
            rationale: "Entrelace os dedos, estique os braços para cima e alongue a coluna por 20 segundos, respirando fundo.",
            achievement: PresetAchievement(
                title: "rumo ao céu",
                description: "você passou {tempo} esticando o corpo e sentiu a coluna agradecer"
            )
        ),
        PresetChallenge(
            title: "movimento em qualquer lugar",
            subTitle: "Marche parado por 1 minuto",
            rationale: "Marche no lugar por 1 minuto, levantando bem os joelhos. Se estiver num espaço apertado, faça mais devagar.",
            achievement: PresetAchievement(
                title: "marcha no lugar",
                description: "você passou {tempo} marchando no lugar e o corpo acordou"
            )
        ),
        PresetChallenge(
            title: "abra o que a postura fechou",
            subTitle: "Alongue o peito",
            rationale: "Junte as mãos atrás das costas, estique os braços e abra o peito por 20 segundos, sem forçar.",
            achievement: PresetAchievement(
                title: "peito aberto",
                description: "você passou {tempo} abrindo o peito que a postura tinha fechado"
            )
        ),
        PresetChallenge(
            title: "coluna em movimento",
            subTitle: "Gato e vaca na cadeira",
            rationale: "Sentado, mãos nos joelhos: inspire arqueando as costas, expire arredondando a coluna. Repita 8 vezes.",
            achievement: PresetAchievement(
                title: "gato e vaca",
                description: "você passou {tempo} mexendo a coluna inteira sem sair da cadeira"
            )
        ),
        PresetChallenge(
            title: "energia em 20 segundos",
            subTitle: "Dez polichinelos",
            rationale: "Com espaço e piso seguro, faça 10 polichinelos. Se não puder pular, faça só o movimento dos braços.",
            achievement: PresetAchievement(
                title: "polichinelo pro",
                description: "você passou {tempo} fazendo polichinelos e acordou na marra"
            )
        ),
        PresetChallenge(
            title: "aguente mais um pouquinho",
            subTitle: "Meio agachamento parado",
            rationale: "Desça num meio agachamento, pés na largura dos ombros, e segure por 20 segundos. Se doer o joelho, pare.",
            achievement: PresetAchievement(
                title: "aguentou firme",
                description: "você passou {tempo} num meio agachamento e as pernas tremeram"
            )
        ),
        PresetChallenge(
            title: "o corpo também tem lados",
            subTitle: "Alongue as laterais",
            rationale: "Em pé ou sentado, levante um braço e incline o tronco para o lado oposto por 15 segundos. Troque de lado.",
            achievement: PresetAchievement(
                title: "laterais em dia",
                description: "você passou {tempo} alongando as laterais e respirou mais fundo"
            )
        ),
        PresetChallenge(
            title: "cuidado em pequena escala",
            subTitle: "Massageie as mãos",
            rationale: "Pressione a palma da mão com o polegar, fazendo pequenos círculos. Dedique 1 minuto a cada mão.",
            achievement: PresetAchievement(
                title: "spa das mãos",
                description: "você passou {tempo} massageando as próprias mãos com carinho"
            )
        ),
        PresetChallenge(
            title: "sinta o centro",
            subTitle: "Balance o peso",
            rationale: "Em pé, passe o peso de um pé para o outro, bem devagar, 10 vezes. Perceba como o corpo se ajusta sozinho.",
            achievement: PresetAchievement(
                title: "no seu centro",
                description: "você passou {tempo} balançando o peso e sentiu o equilíbrio trabalhar"
            )
        ),
        PresetChallenge(
            title: "tire o travamento do corpo",
            subTitle: "Sacuda tudo",
            rationale: "Sacuda braços, pernas e ombros por 20 segundos, como quem tira a água do corpo. Vale parecer ridículo.",
            achievement: PresetAchievement(
                title: "sacudida geral",
                description: "você passou {tempo} sacudindo o corpo inteiro e se sentiu mais leve"
            )
        ),
        PresetChallenge(
            title: "tensão que passa despercebida",
            subTitle: "Solte a mandíbula",
            rationale: "Deixe a boca entreaberta, dentes sem se tocar e língua solta. Mexa a mandíbula de leve por 30 segundos.",
            achievement: PresetAchievement(
                title: "mandíbula solta",
                description: "você passou {tempo} soltando a mandíbula e notou que estava travada"
            )
        ),
        PresetChallenge(
            title: "postura que se constrói",
            subTitle: "Aproxime as omoplatas",
            rationale: "Puxe os ombros para trás, aproximando as omoplatas, e segure por 5 segundos. Solte e repita 10 vezes.",
            achievement: PresetAchievement(
                title: "postura em obra",
                description: "você passou {tempo} corrigindo a postura e aproximando as omoplatas"
            )
        ),
        PresetChallenge(
            title: "pescoço sem pressa",
            subTitle: "Semicírculos com a cabeça",
            rationale: "Leve o queixo ao peito e faça meios círculos lentos de ombro a ombro, 5 vezes. Não incline para trás.",
            achievement: PresetAchievement(
                title: "pêndulo calmo",
                description: "você passou {tempo} soltando o pescoço com semicírculos lentos"
            )
        ),
        PresetChallenge(
            title: "força sem sair do lugar",
            subTitle: "Flexão na parede",
            rationale: "Apoie as mãos numa parede, na altura dos ombros, e faça 10 flexões devagar, levando o peito até ela.",
            achievement: PresetAchievement(
                title: "empurra parede",
                description: "você passou {tempo} fazendo flexões na parede e os braços trabalharam"
            )
        ),
        PresetChallenge(
            title: "abdômen em modo cadeira",
            subTitle: "Joelho ao peito sentado",
            rationale: "Sentado na beira da cadeira, leve um joelho de cada vez em direção ao peito, 10 vezes de cada lado.",
            achievement: PresetAchievement(
                title: "core na cadeira",
                description: "você passou {tempo} levantando os joelhos sem sair da cadeira"
            )
        ),
        PresetChallenge(
            title: "solte o peso que você carrega",
            subTitle: "Ombros até as orelhas",
            rationale: "Suba os ombros até as orelhas, segure 3 segundos e solte de uma vez. Repita 8 vezes.",
            achievement: PresetAchievement(
                title: "largou o peso",
                description: "você passou {tempo} subindo e soltando os ombros e sentiu o peso sair"
            )
        ),
        PresetChallenge(
            title: "pernas fortes, passo a passo",
            subTitle: "Afundo devagar",
            rationale: "Dê um passo à frente e flexione os dois joelhos devagar, com apoio se precisar. Faça 5 vezes cada perna.",
            achievement: PresetAchievement(
                title: "passo a passo",
                description: "você passou {tempo} fazendo afundos e sentiu as pernas acordarem"
            )
        ),
        PresetChallenge(
            title: "gire a coluna com calma",
            subTitle: "Torção na cadeira",
            rationale: "Sentado, segure o encosto com uma mão e gire o tronco devagar para esse lado. Segure 15 segundos e troque.",
            achievement: PresetAchievement(
                title: "torção calma",
                description: "você passou {tempo} girando o tronco na cadeira e soltou as costas"
            )
        ),
        PresetChallenge(
            title: "ombros aquecidos",
            subTitle: "Círculos com os braços",
            rationale: "Estique os braços para os lados e faça 10 círculos pequenos para frente e 10 para trás.",
            achievement: PresetAchievement(
                title: "hélice humana",
                description: "você passou {tempo} girando os braços e aqueceu os ombros"
            )
        ),
        PresetChallenge(
            title: "a frente das pernas agradece",
            subTitle: "Alongue a coxa em pé",
            rationale: "Em pé, com apoio, segure um pé atrás e leve o calcanhar em direção ao bumbum por 20 segundos. Troque.",
            achievement: PresetAchievement(
                title: "coxa alongada",
                description: "você passou {tempo} alongando as coxas e sentiu as pernas mais leves"
            )
        ),
        PresetChallenge(
            title: "passos também contam",
            subTitle: "Caminhe por 2 minutos",
            rationale: "Levante e caminhe pelo cômodo ou pela casa por 2 minutos, no ritmo que quiser. Só não pare.",
            achievement: PresetAchievement(
                title: "andar é preciso",
                description: "você passou {tempo} caminhando e tirou o corpo do modo parado"
            )
        ),
        PresetChallenge(
            title: "cabeça no lugar certo",
            subTitle: "Recolha o queixo",
            rationale: "Sem inclinar a cabeça, puxe o queixo para trás, como um queixo duplo. Segure 5 segundos e repita 8 vezes.",
            achievement: PresetAchievement(
                title: "cabeça no lugar",
                description: "você passou {tempo} alinhando a cabeça e aliviou o pescoço"
            )
        ),
        PresetChallenge(
            title: "pés em vaivém",
            subTitle: "Calcanhar e ponta",
            rationale: "Sentado, apoie o calcanhar e levante a ponta do pé, depois inverta. Faça 15 vezes com cada pé.",
            achievement: PresetAchievement(
                title: "pés em vaivém",
                description: "você passou {tempo} alternando calcanhar e ponta e acordou os pés"
            )
        ),
        PresetChallenge(
            title: "quadril também trava",
            subTitle: "Abra o quadril sentado",
            rationale: "Sentado, apoie um tornozelo sobre o joelho oposto e incline o tronco à frente por 20 segundos. Troque.",
            achievement: PresetAchievement(
                title: "destrava quadril",
                description: "você passou {tempo} alongando o quadril sem sair da cadeira"
            )
        ),
        PresetChallenge(
            title: "ombro alongado, tensão a menos",
            subTitle: "Braço cruzado no peito",
            rationale: "Puxe um braço esticado na frente do peito com a outra mão e segure por 20 segundos. Depois troque.",
            achievement: PresetAchievement(
                title: "tensão a menos",
                description: "você passou {tempo} alongando os ombros, um de cada vez"
            )
        ),
        PresetChallenge(
            title: "cuide do que pouco se mexe",
            subTitle: "Alongue atrás do braço",
            rationale: "Leve uma mão às costas por cima do ombro e, com a outra, puxe o cotovelo de leve por 15 segundos. Troque.",
            achievement: PresetAchievement(
                title: "tríceps feliz",
                description: "você passou {tempo} alongando a parte de trás dos braços"
            )
        ),
        PresetChallenge(
            title: "equilíbrio e quadril",
            subTitle: "Perna para o lado",
            rationale: "Em pé, com apoio, levante uma perna esticada para o lado e desça devagar, 10 vezes. Depois troque.",
            achievement: PresetAchievement(
                title: "quadril em ação",
                description: "você passou {tempo} erguendo as pernas de lado e o quadril trabalhou"
            )
        ),
        PresetChallenge(
            title: "energia em 30 segundos",
            subTitle: "Socos no ar",
            rationale: "Em pé, com os joelhos levemente dobrados, dê socos alternados no ar, para frente, por 30 segundos.",
            achievement: PresetAchievement(
                title: "boxe imaginário",
                description: "você passou {tempo} dando socos no ar e liberou energia"
            )
        ),
        PresetChallenge(
            title: "pescoço que gira com calma",
            subTitle: "Olhe por cima do ombro",
            rationale: "Gire a cabeça devagar para olhar por cima de um ombro e segure por 10 segundos. Depois troque de lado.",
            achievement: PresetAchievement(
                title: "giro de coruja",
                description: "você passou {tempo} girando o pescoço devagar para os dois lados"
            )
        ),
        PresetChallenge(
            title: "força que ninguém vê",
            subTitle: "Contraia o abdômen",
            rationale: "Puxe o umbigo para dentro e segure por 10 segundos, respirando normalmente. Repita 5 vezes.",
            achievement: PresetAchievement(
                title: "força secreta",
                description: "você passou {tempo} ativando o abdômen sem ninguém perceber"
            )
        ),
        PresetChallenge(
            title: "peito aberto, costas ativas",
            subTitle: "Abra os braços",
            rationale: "Estique os braços à frente e abra-os para os lados, juntando as omoplatas. Volte devagar. Repita 10 vezes.",
            achievement: PresetAchievement(
                title: "costas ativas",
                description: "você passou {tempo} abrindo os braços e ativou as costas"
            )
        ),
        PresetChallenge(
            title: "movimento em outra direção",
            subTitle: "Passos para o lado",
            rationale: "Dê 10 passos para um lado e 10 para o outro, com os joelhos levemente dobrados. Pouco espaço? Vá e volte.",
            achievement: PresetAchievement(
                title: "modo caranguejo",
                description: "você passou {tempo} andando de lado e acordou as pernas"
            )
        ),
    ]
}
