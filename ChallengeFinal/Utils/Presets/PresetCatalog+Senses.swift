//
//  PresetCatalog+Senses.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 12/11/26.
//

import Foundation

/// Desafios pré-prontos da categoria sentidos.
extension PresetCatalog {
    static let senses: [PresetChallenge] = [
        PresetChallenge(
            title: "olhe de verdade",
            subTitle: "Cinco coisas que você vê",
            rationale: "Sem sair do lugar, encontre cinco coisas ao redor que você nunca tinha reparado. Observe cada uma.",
            achievement: PresetAchievement(
                title: "olho de lince",
                description: "você passou {tempo} achando 5 detalhes que passavam despercebidos"
            )
        ),
        PresetChallenge(
            title: "o que sobra quando para tudo",
            subTitle: "Ouça o silêncio",
            rationale: "Feche os olhos por 1 minuto e escute o que está ao fundo: ventilador, rua, geladeira, sua respiração.",
            achievement: PresetAchievement(
                title: "escuta profunda",
                description: "você passou {tempo} de olhos fechados ouvindo o que sempre esteve ali"
            )
        ),
        PresetChallenge(
            title: "o corpo avisa",
            subTitle: "Sinta a temperatura",
            rationale: "Perceba a temperatura em mãos, pés, rosto e nuca. Onde está mais quente? E mais frio?",
            achievement: PresetAchievement(
                title: "termômetro vivo",
                description: "você passou {tempo} mapeando a temperatura do seu corpo"
            )
        ),
        PresetChallenge(
            title: "tensão e alívio",
            subTitle: "Aperte e solte",
            rationale: "Aperte os punhos com força por 5 segundos e depois solte de uma vez. Repita 3 vezes e sinta a diferença.",
            achievement: PresetAchievement(
                title: "aperta e solta",
                description: "você passou {tempo} apertando e soltando as mãos e a tensão saiu"
            )
        ),
        PresetChallenge(
            title: "descanse os olhos",
            subTitle: "Olhe para longe",
            rationale: "Tire os olhos da tela e olhe para o ponto mais distante que conseguir ver por 20 segundos. Pisque devagar.",
            achievement: PresetAchievement(
                title: "olhos de férias",
                description: "você passou {tempo} olhando para o horizonte e descansou os olhos"
            )
        ),
        PresetChallenge(
            title: "ela está sempre aí",
            subTitle: "Escute sua respiração",
            rationale: "Por 1 minuto, apenas observe o som e o ritmo da sua respiração, sem tentar mudá-la.",
            achievement: PresetAchievement(
                title: "som do fôlego",
                description: "você passou {tempo} só ouvindo a própria respiração"
            )
        ),
        PresetChallenge(
            title: "onde você está apoiado",
            subTitle: "Sinta o peso do corpo",
            rationale: "Perceba o peso do seu corpo na cadeira, no sofá ou no chão. Onde ele pressiona mais? Onde está mais leve?",
            achievement: PresetAchievement(
                title: "ponto de apoio",
                description: "você passou {tempo} sentindo o peso do corpo e onde ele se apoia"
            )
        ),
        PresetChallenge(
            title: "o ambiente tem uma paleta",
            subTitle: "Descubra a cor dominante",
            rationale: "Olhe ao redor e identifique a cor que mais aparece. Depois procure a que menos aparece.",
            achievement: PresetAchievement(
                title: "olho de designer",
                description: "você passou {tempo} montando a paleta de cores do lugar onde está"
            )
        ),
        PresetChallenge(
            title: "gosto que ficou",
            subTitle: "Sinta a língua e a boca",
            rationale: "Perceba agora o gosto que está na sua boca e a posição da língua. Engula devagar e observe a sensação.",
            achievement: PresetAchievement(
                title: "paladar atento",
                description: "você passou {tempo} sentindo o gosto que estava na sua boca"
            )
        ),
        PresetChallenge(
            title: "pequenos movimentos, grande atenção",
            subTitle: "Mexa só os dedos dos pés",
            rationale: "Mexa só os dedos dos pés, um de cada vez se conseguir. Notar quais obedecem faz parte do desafio.",
            achievement: PresetAchievement(
                title: "dedos rebeldes",
                description: "você passou {tempo} descobrindo que mexer cada dedo do pé é difícil"
            )
        ),
        PresetChallenge(
            title: "silêncio também é descanso",
            subTitle: "Cinco minutos de nada",
            rationale: "Reserve cinco minutos para não fazer absolutamente nada. Sem tela, sem tarefa, só você e o momento.",
            achievement: PresetAchievement(
                title: "mestre do nada",
                description: "você passou {tempo} sem fazer absolutamente nada e sobreviveu"
            )
        ),
        PresetChallenge(
            title: "o familiar ainda tem novidades",
            subTitle: "Descubra sua própria mão",
            rationale: "Observe sua mão: linhas, marcas, formatos e texturas. Você a vê o dia todo, mas já olhou de verdade?",
            achievement: PresetAchievement(
                title: "mão redescoberta",
                description: "você passou {tempo} observando a própria mão e achou detalhes novos"
            )
        ),
        PresetChallenge(
            title: "tudo que você veste tem uma história",
            subTitle: "Visite sua memória",
            rationale: "Olhe as roupas que está usando e tente lembrar onde comprou cada peça. É memória disfarçada de moda.",
            achievement: PresetAchievement(
                title: "memória fashion",
                description: "você passou {tempo} relembrando a história de cada roupa que veste"
            )
        ),
        PresetChallenge(
            title: "o mundo também se lê com as mãos",
            subTitle: "Três texturas ao seu redor",
            rationale: "Escolha três objetos próximos e toque em cada um. Observe como as texturas são diferentes entre si.",
            achievement: PresetAchievement(
                title: "tato apurado",
                description: "você passou {tempo} sentindo texturas diferentes ao seu redor"
            )
        ),
        PresetChallenge(
            title: "paciência é um músculo",
            subTitle: "Conte até 137",
            rationale: "Conte mentalmente de 1 até 137, sem acelerar. O desafio é manter o ritmo e a atenção até o fim.",
            achievement: PresetAchievement(
                title: "paciência 137",
                description: "você passou {tempo} contando até 137 sem pressa e sem se perder"
            )
        ),
        PresetChallenge(
            title: "atenção em cada passo",
            subTitle: "Conte ao contrário",
            rationale: "Conte mentalmente de 50 até 0, atento a cada número. Contar para trás exige mais foco do que parece.",
            achievement: PresetAchievement(
                title: "foco regressivo",
                description: "você passou {tempo} contando de 50 até 0 com atenção total"
            )
        ),
        PresetChallenge(
            title: "ouvir de verdade",
            subTitle: "Três sons, três nomes",
            rationale: "Pare por um minuto e identifique três sons ao redor, do mais forte ao mais discreto. Tente nomear cada um.",
            achievement: PresetAchievement(
                title: "ouvido de radar",
                description: "você passou {tempo} em silêncio e achou 3 sons que ignorava"
            )
        ),
        PresetChallenge(
            title: "o olfato lembra tudo",
            subTitle: "Cheire cinco coisas",
            rationale: "Cheire cinco coisas seguras ao redor, como uma fruta, um livro ou um tempero. Que memórias aparecem?",
            achievement: PresetAchievement(
                title: "faro afiado",
                description: "você passou {tempo} cheirando coisas e uma delas trouxe uma lembrança"
            )
        ),
        PresetChallenge(
            title: "aprenda a enxergar",
            subTitle: "Dez objetos da mesma cor",
            rationale: "Escolha uma cor e encontre 10 objetos dela ao seu redor. Você vai olhar o ambiente com outros olhos.",
            achievement: PresetAchievement(
                title: "caça às cores",
                description: "você passou {tempo} caçando uma cor e viu o espaço de outro jeito"
            )
        ),
        PresetChallenge(
            title: "atenção no corpo",
            subTitle: "Sinta seus pés",
            rationale: "Por um minuto, preste atenção só nos seus pés: o contato com o chão, a temperatura, a pressão.",
            achievement: PresetAchievement(
                title: "atenção nos pés",
                description: "você passou {tempo} prestando atenção só nos seus pés"
            )
        ),
        PresetChallenge(
            title: "ritmo que acalma",
            subTitle: "Respire 4-4",
            rationale: "Inspire contando até 4 e expire contando até 4, por 2 minutos. Se perder a conta, recomece sem pressa.",
            achievement: PresetAchievement(
                title: "ritmo 4-4",
                description: "você passou {tempo} respirando no ritmo 4-4 e desacelerou"
            )
        ),
        PresetChallenge(
            title: "seu relógio interno",
            subTitle: "Adivinhe um minuto",
            rationale: "Feche os olhos e abra quando achar que passou 1 minuto. Depois confira no relógio quanto tempo passou.",
            achievement: PresetAchievement(
                title: "relógio interno",
                description: "você passou {tempo} tentando adivinhar quanto dura um minuto"
            )
        ),
        PresetChallenge(
            title: "o corpo sente o tempo todo",
            subTitle: "Roupas na pele",
            rationale: "Perceba como as roupas encostam no corpo: costuras, textura, pressão. O que você só notou agora?",
            achievement: PresetAchievement(
                title: "pele atenta",
                description: "você passou {tempo} sentindo as roupas na pele e notou o que ignorava"
            )
        ),
        PresetChallenge(
            title: "ouvir em camadas",
            subTitle: "Do som mais longe ao mais perto",
            rationale: "Feche os olhos e ache o som mais distante que conseguir. Depois traga a atenção até o mais próximo.",
            achievement: PresetAchievement(
                title: "som em camadas",
                description: "você passou {tempo} escutando do som mais longe ao mais perto"
            )
        ),
        PresetChallenge(
            title: "dê um respiro aos olhos",
            subTitle: "Pisque devagar",
            rationale: "Pisque lentamente 10 vezes, fechando os olhos por um segundo a cada vez. Perceba como os olhos relaxam.",
            achievement: PresetAchievement(
                title: "piscada lenta",
                description: "você passou {tempo} piscando devagar e deu uma pausa aos olhos"
            )
        ),
        PresetChallenge(
            title: "o corpo tem ritmo",
            subTitle: "Sinta o seu pulso",
            rationale: "Coloque dois dedos no pulso, na parte interna do punho, e sinta os batimentos por 30 segundos sem contar.",
            achievement: PresetAchievement(
                title: "pulso firme",
                description: "você passou {tempo} sentindo o próprio pulso, sem contar"
            )
        ),
        PresetChallenge(
            title: "calor que você produz",
            subTitle: "Esfregue as mãos",
            rationale: "Esfregue as palmas das mãos uma na outra por 15 segundos. Depois pare e sinta o calor e o formigamento.",
            achievement: PresetAchievement(
                title: "usina de calor",
                description: "você passou {tempo} esfregando as mãos e sentiu o calor que produziu"
            )
        ),
        PresetChallenge(
            title: "o ambiente é feito de luz",
            subTitle: "De onde vem a luz?",
            rationale: "Descubra de onde vem a luz do lugar e como ela cai nas coisas: brilhos, sombras e cantos escuros.",
            achievement: PresetAchievement(
                title: "rastro da luz",
                description: "você passou {tempo} vendo como a luz entra no lugar onde está"
            )
        ),
        PresetChallenge(
            title: "pequenos toques, grande atenção",
            subTitle: "Polegar nos dedos",
            rationale: "Encoste o polegar em cada dedo da mesma mão, um por vez, bem devagar. Sinta a ponta de cada dedo.",
            achievement: PresetAchievement(
                title: "ponta dos dedos",
                description: "você passou {tempo} tocando cada dedo com o polegar, ponta por ponta"
            )
        ),
        PresetChallenge(
            title: "da cabeça aos pés",
            subTitle: "Escaneie o corpo",
            rationale: "Em 2 minutos, leve a atenção da cabeça aos pés, parte por parte, só percebendo. Sem tentar mudar nada.",
            achievement: PresetAchievement(
                title: "scanner humano",
                description: "você passou {tempo} escaneando o corpo inteiro, da cabeça aos pés"
            )
        ),
        PresetChallenge(
            title: "olhar de verdade",
            subTitle: "Um objeto por um minuto",
            rationale: "Observe um objeto próximo por 1 minuto: forma, cor, riscos, brilho. Quanto mais olha, mais aparece.",
            achievement: PresetAchievement(
                title: "olhar de verdade",
                description: "você passou {tempo} olhando um único objeto e viu detalhes que não via"
            )
        ),
        PresetChallenge(
            title: "expressão em modo descanso",
            subTitle: "Relaxe o rosto",
            rationale: "Solte a testa, as sobrancelhas, os olhos e as bochechas, um por um. Perceba qual parte estava mais tensa.",
            achievement: PresetAchievement(
                title: "cara de descanso",
                description: "você passou {tempo} relaxando o rosto e notou a tensão que carregava"
            )
        ),
        PresetChallenge(
            title: "a respiração tem temperatura",
            subTitle: "Ar entrando, ar saindo",
            rationale: "Respire pelo nariz e perceba o ar entrando mais frio e saindo mais quente. Faça isso por 10 respirações.",
            achievement: PresetAchievement(
                title: "vai e vem do ar",
                description: "você passou {tempo} sentindo a temperatura do ar a cada respiração"
            )
        ),
        PresetChallenge(
            title: "deixe a gravidade trabalhar",
            subTitle: "Braços pesados",
            rationale: "Deixe os braços soltos ao lado do corpo e perceba quanto pesam quando você para de segurá-los.",
            achievement: PresetAchievement(
                title: "braços de chumbo",
                description: "você passou {tempo} com os braços soltos sentindo o peso deles"
            )
        ),
        PresetChallenge(
            title: "o que a luz desenha",
            subTitle: "Observe uma sombra",
            rationale: "Encontre uma sombra por perto e observe suas bordas, formato e tons. Veja se ela muda enquanto você olha.",
            achievement: PresetAchievement(
                title: "sombra de perto",
                description: "você passou {tempo} observando uma sombra cheia de detalhes"
            )
        ),
        PresetChallenge(
            title: "o toque também é um sentido",
            subTitle: "Deslize os dedos no braço",
            rationale: "Passe a ponta dos dedos de leve pelo antebraço e sinta a pele de quem toca e de quem é tocado.",
            achievement: PresetAchievement(
                title: "toque leve",
                description: "você passou {tempo} sentindo a pele do braço de outro jeito"
            )
        ),
        PresetChallenge(
            title: "temperatura na ponta dos dedos",
            subTitle: "Toque algo frio",
            rationale: "Encontre algo frio por perto, como um copo ou a mesa, e toque por alguns segundos. Sinta o frio na pele.",
            achievement: PresetAchievement(
                title: "toque gelado",
                description: "você passou {tempo} sentindo na pele a temperatura de algo frio"
            )
        ),
        PresetChallenge(
            title: "sabor em câmera lenta",
            subTitle: "Um gole com atenção",
            rationale: "Tome um gole de água ou do que tiver por perto e segure na boca por 5 segundos antes de engolir.",
            achievement: PresetAchievement(
                title: "gole consciente",
                description: "você passou {tempo} saboreando um gole e sentiu cada detalhe"
            )
        ),
        PresetChallenge(
            title: "reconheça pelo toque",
            subTitle: "Olhos fechados, mãos atentas",
            rationale: "Feche os olhos, pegue um objeto próximo e descreva forma, peso e temperatura só pelo toque.",
            achievement: PresetAchievement(
                title: "mãos que veem",
                description: "você passou {tempo} reconhecendo um objeto só pelo toque"
            )
        ),
        PresetChallenge(
            title: "o ambiente nunca está parado",
            subTitle: "Algo que se move",
            rationale: "Ache algo em movimento ao redor: uma cortina, uma folha, uma luz. Observe por 30 segundos.",
            achievement: PresetAchievement(
                title: "nada está parado",
                description: "você passou {tempo} observando com calma algo em movimento"
            )
        ),
        PresetChallenge(
            title: "o olho percebe nuances",
            subTitle: "Cinco tons de uma cor",
            rationale: "Escolha uma cor e encontre cinco tons diferentes dela ao seu redor, do mais claro ao mais escuro.",
            achievement: PresetAchievement(
                title: "mestre dos tons",
                description: "você passou {tempo} encontrando 5 tons da mesma cor no ambiente"
            )
        ),
        PresetChallenge(
            title: "o ar também toca você",
            subTitle: "Sinta o ar na pele",
            rationale: "Fique parado por 1 minuto e perceba o ar na pele: vento, ventilador ou ar parado. Onde ele toca mais?",
            achievement: PresetAchievement(
                title: "ar na pele",
                description: "você passou {tempo} percebendo o ar tocando a sua pele"
            )
        ),
        PresetChallenge(
            title: "acompanhe até o fim",
            subTitle: "Ouça um som até sumir",
            rationale: "Bata de leve num copo ou na mesa e ouça o som até ele desaparecer por completo. Repita 3 vezes.",
            achievement: PresetAchievement(
                title: "até o último eco",
                description: "você passou {tempo} ouvindo um som até ele sumir por completo"
            )
        ),
        PresetChallenge(
            title: "o chão também conversa",
            subTitle: "Pés descalços no chão",
            rationale: "Tire os sapatos e apoie os pés no chão por 1 minuto. Perceba a temperatura, a textura e a firmeza.",
            achievement: PresetAchievement(
                title: "pé no chão",
                description: "você passou {tempo} sentindo o chão com os pés descalços"
            )
        ),
        PresetChallenge(
            title: "dois olhos, duas visões",
            subTitle: "Um olho de cada vez",
            rationale: "Olhe para um objeto e feche um olho, depois o outro. Perceba como a imagem muda de lugar.",
            achievement: PresetAchievement(
                title: "dois olhares",
                description: "você passou {tempo} descobrindo que cada olho vê de um jeito"
            )
        ),
        PresetChallenge(
            title: "todo lugar tem um cheiro",
            subTitle: "Qual é o cheiro daqui?",
            rationale: "Respire fundo pelo nariz e tente descrever o cheiro do lugar onde você está, mesmo que seja sutil.",
            achievement: PresetAchievement(
                title: "nariz curioso",
                description: "você passou {tempo} sentindo o cheiro do lugar onde está"
            )
        ),
        PresetChallenge(
            title: "sinta a água de verdade",
            subTitle: "Lave as mãos com atenção",
            rationale: "Lave as mãos devagar e preste atenção na temperatura da água, no sabão e na textura da toalha.",
            achievement: PresetAchievement(
                title: "lavagem zen",
                description: "você passou {tempo} lavando as mãos com atenção em cada sensação"
            )
        ),
        PresetChallenge(
            title: "cada mordida tem sabor",
            subTitle: "Uma mordida bem devagar",
            rationale: "Se tiver algo para comer, mastigue a próxima mordida bem devagar, sentindo a textura e o sabor mudarem.",
            achievement: PresetAchievement(
                title: "sabor sem pressa",
                description: "você passou {tempo} mastigando devagar e sentiu o sabor mudar"
            )
        ),
        PresetChallenge(
            title: "sua voz mora no corpo",
            subTitle: "Sinta sua voz vibrar",
            rationale: "Murmure um “hum” longo de boca fechada e sinta onde a vibração aparece: lábios, nariz, peito.",
            achievement: PresetAchievement(
                title: "voz que vibra",
                description: "você passou {tempo} murmurando e sentiu a própria voz vibrar no corpo"
            )
        ),
        PresetChallenge(
            title: "o que fica acima de você",
            subTitle: "Olhe para o teto",
            rationale: "Olhe para o teto por 30 segundos e repare em detalhes que costuma ignorar: manchas, cantos, luminárias.",
            achievement: PresetAchievement(
                title: "lá em cima",
                description: "você passou {tempo} olhando para o teto e notou coisas novas"
            )
        ),
        PresetChallenge(
            title: "balança na palma da mão",
            subTitle: "Qual pesa mais?",
            rationale: "Pegue um objeto em cada mão e tente descobrir qual é mais pesado só pela sensação.",
            achievement: PresetAchievement(
                title: "balança de mão",
                description: "você passou {tempo} comparando o peso de dois objetos com as mãos"
            )
        ),
        PresetChallenge(
            title: "desenhe com os olhos",
            subTitle: "Contorne com o olhar",
            rationale: "Escolha um objeto e percorra todo o contorno dele com os olhos, devagar, como se fosse desenhá-lo.",
            achievement: PresetAchievement(
                title: "contorno fino",
                description: "você passou {tempo} contornando um objeto só com o olhar"
            )
        ),
        PresetChallenge(
            title: "o corpo também faz barulho",
            subTitle: "Sons do seu corpo",
            rationale: "Em silêncio, tente perceber os sons do seu corpo: respiração, estômago, o ato de engolir, batimentos.",
            achievement: PresetAchievement(
                title: "corpo sonoro",
                description: "você passou {tempo} ouvindo os sons do próprio corpo"
            )
        ),
        PresetChallenge(
            title: "escuro que descansa",
            subTitle: "Palmas sobre os olhos",
            rationale: "Esfregue as mãos e cubra os olhos fechados com as palmas por 30 segundos. Sinta o calor e o escuro.",
            achievement: PresetAchievement(
                title: "escurinho bom",
                description: "você passou {tempo} com as mãos nos olhos e deixou eles descansarem"
            )
        ),
        PresetChallenge(
            title: "o que aparece no escuro",
            subTitle: "Cores de olhos fechados",
            rationale: "Feche os olhos por 30 segundos e observe as cores, manchas e formas que surgem no escuro.",
            achievement: PresetAchievement(
                title: "cinema interno",
                description: "você passou {tempo} vendo cores e formas de olhos fechados"
            )
        ),
        PresetChallenge(
            title: "descubra onde você respira",
            subTitle: "Peito ou barriga?",
            rationale: "Coloque uma mão no peito e outra na barriga. Respire normalmente e perceba qual delas se move mais.",
            achievement: PresetAchievement(
                title: "mapa do fôlego",
                description: "você passou {tempo} sentindo onde a sua respiração acontece"
            )
        ),
    ]
}
