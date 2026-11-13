//
//  PresetCatalog+Mind.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 12/11/26.
//

import Foundation

/// Desafios pré-prontos da categoria mente.
extension PresetCatalog {
    static let mind: [PresetChallenge] = [
        PresetChallenge(
            title: "matemática sem pressa",
            subTitle: "Conte de 7 em 7",
            rationale: "Conte mentalmente de 7 em 7 a partir do zero, até passar de 100. Se errar, volte ao último número certo.",
            achievement: PresetAchievement(
                title: "de 7 em 7",
                description: "você passou {tempo} contando de 7 em 7 até passar de 100"
            )
        ),
        PresetChallenge(
            title: "palavras do avesso",
            subTitle: "Soletre de trás para frente",
            rationale: "Escolha seu nome completo e soletre de trás para frente, só de cabeça.",
            achievement: PresetAchievement(
                title: "nome do avesso",
                description: "você passou {tempo} soletrando o próprio nome de trás para frente"
            )
        ),
        PresetChallenge(
            title: "confie na sua cabeça",
            subTitle: "Quanto é 23 × 4?",
            rationale: "Resolva 23 × 4 mentalmente antes de pensar em calculadora. Decompor a conta vale.",
            achievement: PresetAchievement(
                title: "cálculo raiz",
                description: "você passou {tempo} calculando 23 × 4 só de cabeça"
            )
        ),
        PresetChallenge(
            title: "batize o momento",
            subTitle: "Invente um nome para o dia",
            rationale: "Dê ao seu dia um título criativo, como um episódio de série, e pense numa frase que o justifique.",
            achievement: PresetAchievement(
                title: "episódio do dia",
                description: "você passou {tempo} criando um título de série para o seu dia"
            )
        ),
        PresetChallenge(
            title: "pensamento em categorias",
            subTitle: "Liste 10 coisas redondas",
            rationale: "Sem pesquisar, pense em 10 coisas redondas. Depois tente com 10 coisas que começam com a mesma letra.",
            achievement: PresetAchievement(
                title: "tudo redondo",
                description: "você passou {tempo} listando 10 coisas redondas de cabeça"
            )
        ),
        PresetChallenge(
            title: "a memória escorrega",
            subTitle: "Lembre do seu último sonho",
            rationale: "Tente lembrar um sonho recente e reconstrua o máximo de detalhes. Se não vier nenhum, pense no último.",
            achievement: PresetAchievement(
                title: "sonho resgatado",
                description: "você passou {tempo} reconstruindo um sonho com detalhes surpreendentes"
            )
        ),
        PresetChallenge(
            title: "vocabulário em ação",
            subTitle: "Descreva sem usar a palavra",
            rationale: "Escolha um objeto perto de você e descreva-o em voz alta, sem usar o nome dele.",
            achievement: PresetAchievement(
                title: "nome proibido",
                description: "você passou {tempo} descrevendo um objeto sem dizer o nome dele"
            )
        ),
        PresetChallenge(
            title: "teste de memória rápida",
            subTitle: "Memorize uma sequência",
            rationale: "Memorize esta sequência: 4, 9, 2, 7, 1, 6. Feche os olhos e repita. Depois tente de trás para frente.",
            achievement: PresetAchievement(
                title: "memória reversa",
                description: "você passou {tempo} memorizando uma sequência e repetiu ao contrário"
            )
        ),
        PresetChallenge(
            title: "clareza se treina",
            subTitle: "Se você tivesse que explicar...",
            rationale: "Escolha o que você fez hoje de manhã e explique em uma frase só. Depois tente em cinco palavras.",
            achievement: PresetAchievement(
                title: "clareza total",
                description: "você passou {tempo} resumindo a sua manhã em cinco palavras"
            )
        ),
        PresetChallenge(
            title: "criatividade sob demanda",
            subTitle: "Pense em um final diferente",
            rationale: "Pense em um filme ou série que você conhece e invente um final diferente do original, em 3 frases.",
            achievement: PresetAchievement(
                title: "roteirista",
                description: "você passou {tempo} inventando um final alternativo para uma história"
            )
        ),
        PresetChallenge(
            title: "sua cabeça também calcula",
            subTitle: "Quanto é 37 × 7?",
            rationale: "Resolva 37 × 7 mentalmente antes de conferir na calculadora. Vale decompor a conta do seu jeito.",
            achievement: PresetAchievement(
                title: "calculadora viva",
                description: "você passou {tempo} resolvendo 37 × 7 de cabeça, antes da calculadora"
            )
        ),
        PresetChallenge(
            title: "confie no seu raciocínio",
            subTitle: "Quanto é 91 × 3?",
            rationale: "Tente calcular 91 × 3 de cabeça e só use a calculadora depois de chegar à sua resposta.",
            achievement: PresetAchievement(
                title: "lógica afiada",
                description: "você passou {tempo} calculando 91 × 3 de cabeça e depois conferiu"
            )
        ),
        PresetChallenge(
            title: "cálculo em partes",
            subTitle: "Quanto é 48 × 6?",
            rationale: "Resolva 48 × 6 de cabeça, quebrando em partes se ajudar, antes de usar a calculadora.",
            achievement: PresetAchievement(
                title: "conta fatiada",
                description: "você passou {tempo} calculando 48 × 6 em partes, só de cabeça"
            )
        ),
        PresetChallenge(
            title: "criatividade em modo manual",
            subTitle: "Três objetos, uma história",
            rationale: "Escolha três objetos da sua mesa e invente uma história curta que conecte os três. Só precisa existir.",
            achievement: PresetAchievement(
                title: "história de mesa",
                description: "você passou {tempo} criando uma história com 3 objetos da sua mesa"
            )
        ),
        PresetChallenge(
            title: "o cérebro adora desafio",
            subTitle: "Alfabeto de trás para frente",
            rationale: "Recite o alfabeto de Z até A, sem pressa. Se errar, recomece do ponto em que parou.",
            achievement: PresetAchievement(
                title: "abc invertido",
                description: "você passou {tempo} recitando o alfabeto de trás para frente"
            )
        ),
        PresetChallenge(
            title: "simples é difícil",
            subTitle: "Explique para uma criança",
            rationale: "Escolha algo que você sabe bem e explique para alguém de 10 anos, em voz alta ou por escrito.",
            achievement: PresetAchievement(
                title: "simples assim",
                description: "você passou {tempo} explicando algo complexo de um jeito simples"
            )
        ),
        PresetChallenge(
            title: "memória do cotidiano",
            subTitle: "O que você comeu?",
            rationale: "Tente lembrar tudo o que comeu nos últimos 3 dias, sem consultar fotos. Escreva e veja o quanto lembra.",
            achievement: PresetAchievement(
                title: "diário do prato",
                description: "você passou {tempo} lembrando o que comeu nos últimos 3 dias"
            )
        ),
        PresetChallenge(
            title: "contas que desaceleram",
            subTitle: "Subtraia de 9 em 9",
            rationale: "Comece em 100 e vá subtraindo 9, mentalmente: 91, 82, 73... Veja até onde consegue chegar sem errar.",
            achievement: PresetAchievement(
                title: "nove a menos",
                description: "você passou {tempo} subtraindo de 9 em 9 a partir de 100"
            )
        ),
        PresetChallenge(
            title: "além da tabuada de escola",
            subTitle: "Tabuada do 13",
            rationale: "Recite de cabeça a tabuada do 13, de 13 × 1 até 13 × 10. Se travar, decomponha em 10 + 3.",
            achievement: PresetAchievement(
                title: "tabuada do 13",
                description: "você passou {tempo} recitando a tabuada do 13 de cabeça"
            )
        ),
        PresetChallenge(
            title: "criatividade sem limites",
            subTitle: "Cinco usos para um clipe",
            rationale: "Pense em 5 usos criativos para um clipe de papel, além de prender folhas. Vale o improvável.",
            achievement: PresetAchievement(
                title: "clipe criativo",
                description: "você passou {tempo} inventando usos diferentes para um clipe de papel"
            )
        ),
        PresetChallenge(
            title: "sua memória em treino",
            subTitle: "Cinco palavras para memorizar",
            rationale: "Memorize: janela, tigre, ponte, limão, mochila. Feche os olhos e repita. Teste de novo em alguns minutos.",
            achievement: PresetAchievement(
                title: "cinco de cinco",
                description: "você passou {tempo} memorizando 5 palavras e lembrou todas depois"
            )
        ),
        PresetChallenge(
            title: "o óbvio ao contrário",
            subTitle: "Meses de trás pra frente",
            rationale: "Recite os meses do ano de dezembro a janeiro, sem pressa. Se errar, comece de novo do ponto em que parou.",
            achievement: PresetAchievement(
                title: "ano ao contrário",
                description: "você passou {tempo} recitando os meses de dezembro a janeiro"
            )
        ),
        PresetChallenge(
            title: "sua memória é um arquivo",
            subTitle: "Ontem, hora por hora",
            rationale: "Tente lembrar o que fez ontem, hora por hora, desde que acordou. Quantas partes consegue preencher?",
            achievement: PresetAchievement(
                title: "arquivo de ontem",
                description: "você passou {tempo} reconstruindo o seu dia de ontem, hora por hora"
            )
        ),
        PresetChallenge(
            title: "memórias de escola",
            subTitle: "Nomes de professores",
            rationale: "Tente lembrar o nome de 5 professores que você teve na vida. Se vier o rosto antes do nome, tudo bem.",
            achievement: PresetAchievement(
                title: "volta às aulas",
                description: "você passou {tempo} lembrando o nome de professores de antigamente"
            )
        ),
        PresetChallenge(
            title: "linguagem é criação",
            subTitle: "Invente uma palavra",
            rationale: "Invente uma palavra para algo sem nome, como abrir o celular sem saber por quê. Defina em uma frase.",
            achievement: PresetAchievement(
                title: "neologismo",
                description: "você passou {tempo} inventando uma palavra nova que já faz sentido"
            )
        ),
        PresetChallenge(
            title: "a memória tem planta",
            subTitle: "Sua primeira casa de memória",
            rationale: "Feche os olhos e percorra a primeira casa de que você se lembra. Quantos cômodos e detalhes aparecem?",
            achievement: PresetAchievement(
                title: "casa da infância",
                description: "você passou {tempo} passeando pela primeira casa de que se lembra"
            )
        ),
        PresetChallenge(
            title: "sintetizar é pensar",
            subTitle: "Resuma em 3 frases",
            rationale: "Pense no último filme, série ou vídeo longo que você viu e conte a história em 3 frases.",
            achievement: PresetAchievement(
                title: "poder de síntese",
                description: "você passou {tempo} resumindo o último filme que viu em 3 frases"
            )
        ),
        PresetChallenge(
            title: "perguntar também é criar",
            subTitle: "Faça uma pergunta “e se”",
            rationale: "Invente um “e se” sobre seu dia, como “e se ninguém tivesse celular hoje?”, e pense em 3 consequências.",
            achievement: PresetAchievement(
                title: "imaginação solta",
                description: "você passou {tempo} imaginando as consequências de um “e se”"
            )
        ),
        PresetChallenge(
            title: "conselho que atravessa o tempo",
            subTitle: "Três frases para você de 10 anos atrás",
            rationale: "Pense no que você diria para si mesmo há 10 anos. Escolha 3 frases curtas, só de cabeça ou por escrito.",
            achievement: PresetAchievement(
                title: "carta ao passado",
                description: "você passou {tempo} aconselhando o você de 10 anos atrás"
            )
        ),
        PresetChallenge(
            title: "cálculo em camadas",
            subTitle: "Quanto é 15 × 14?",
            rationale: "Resolva 15 × 14 mentalmente, antes de pensar em calculadora. Vale fazer 15 × 10 e depois 15 × 4.",
            achievement: PresetAchievement(
                title: "camada a camada",
                description: "você passou {tempo} resolvendo 15 × 14 de cabeça, em duas etapas"
            )
        ),
        PresetChallenge(
            title: "sua memória tem mapa",
            subTitle: "Dez países em 1 minuto",
            rationale: "Cite 10 países, sem pesquisar. Depois tente com 10 capitais.",
            achievement: PresetAchievement(
                title: "atlas ambulante",
                description: "você passou {tempo} listando 10 países de cabeça, sem pesquisar"
            )
        ),
        PresetChallenge(
            title: "menos é mais",
            subTitle: "História em 6 palavras",
            rationale: "Escreva ou pense em uma história completa com apenas 6 palavras. Ela precisa ter começo, meio e fim.",
            achievement: PresetAchievement(
                title: "menos é mais",
                description: "você passou {tempo} contando uma história inteira em 6 palavras"
            )
        ),
        PresetChallenge(
            title: "atalhos também valem",
            subTitle: "Quanto é 64 × 5?",
            rationale: "Resolva 64 × 5 de cabeça. Dica: multiplique por 10 e divida por 2. Só depois confira.",
            achievement: PresetAchievement(
                title: "atalho esperto",
                description: "você passou {tempo} calculando 64 × 5 de cabeça com um atalho"
            )
        ),
        PresetChallenge(
            title: "criatividade com regras",
            subTitle: "Uma letra, uma frase",
            rationale: "Crie uma frase em que todas as palavras comecem com a mesma letra, como “Paulo pintou paredes pretas”.",
            achievement: PresetAchievement(
                title: "aliteração",
                description: "você passou {tempo} criando uma frase com palavras da mesma letra"
            )
        ),
        PresetChallenge(
            title: "o cérebro brinca com sons",
            subTitle: "Rimas em 1 minuto",
            rationale: "Escolha uma palavra, como “mão”, e pense no máximo de rimas que conseguir em 1 minuto.",
            achievement: PresetAchievement(
                title: "rima rica",
                description: "você passou {tempo} encontrando o máximo de rimas que conseguiu"
            )
        ),
        PresetChallenge(
            title: "pense no oposto",
            subTitle: "Diga o contrário",
            rationale: "Pense em 10 palavras e diga o contrário de cada uma o mais rápido que conseguir.",
            achievement: PresetAchievement(
                title: "do contra",
                description: "você passou {tempo} achando o oposto de 10 palavras de cabeça"
            )
        ),
        PresetChallenge(
            title: "contas com o calendário",
            subTitle: "Some a data de hoje",
            rationale: "Some todos os algarismos da data de hoje: dia, mês e ano. Depois some os dígitos do resultado.",
            achievement: PresetAchievement(
                title: "soma do dia",
                description: "você passou {tempo} somando os números da data de hoje de cabeça"
            )
        ),
        PresetChallenge(
            title: "organização mental",
            subTitle: "Planeje o jantar de cabeça",
            rationale: "Pense no que dá para fazer no jantar com o que tem em casa. Liste os ingredientes sem abrir a geladeira.",
            achievement: PresetAchievement(
                title: "chef de cabeça",
                description: "você passou {tempo} planejando o jantar só de memória"
            )
        ),
        PresetChallenge(
            title: "aprender também é lembrar",
            subTitle: "O que aprendi esta semana",
            rationale: "Pense em 3 coisas novas que você aprendeu nesta semana, por menores que sejam.",
            achievement: PresetAchievement(
                title: "lição da semana",
                description: "você passou {tempo} lembrando 3 coisas que aprendeu nesta semana"
            )
        ),
        PresetChallenge(
            title: "um mapa na cabeça",
            subTitle: "Descreva um caminho",
            rationale: "Descreva mentalmente o caminho de casa até um lugar que você frequenta, com ruas e referências.",
            achievement: PresetAchievement(
                title: "gps mental",
                description: "você passou {tempo} refazendo um caminho inteiro só de memória"
            )
        ),
        PresetChallenge(
            title: "letras que viram outras",
            subTitle: "Palavras escondidas",
            rationale: "Forme o máximo de palavras menores usando as letras de “PARALELEPÍPEDO”.",
            achievement: PresetAchievement(
                title: "caça-palavras",
                description: "você passou {tempo} caçando palavras dentro de “paralelepípedo”"
            )
        ),
        PresetChallenge(
            title: "organize sem papel",
            subTitle: "Ordem alfabética de cabeça",
            rationale: "Pense em 6 frutas e coloque-as em ordem alfabética sem escrever. Depois tente com 6 animais.",
            achievement: PresetAchievement(
                title: "tudo em ordem",
                description: "você passou {tempo} colocando 6 frutas em ordem alfabética de cabeça"
            )
        ),
        PresetChallenge(
            title: "números redondos ajudam",
            subTitle: "Quanto é 125 × 8?",
            rationale: "Resolva 125 × 8 de cabeça. Dica: 125 × 4 é 500. Só depois confira na calculadora.",
            achievement: PresetAchievement(
                title: "número redondo",
                description: "você passou {tempo} resolvendo 125 × 8 de cabeça, sem calculadora"
            )
        ),
        PresetChallenge(
            title: "palavras que se transformam",
            subTitle: "Troque uma letra",
            rationale: "Comece com “gato” e mude uma letra por vez para criar novas palavras: rato, pato, pata... Até onde vai?",
            achievement: PresetAchievement(
                title: "gato, rato, pato",
                description: "você passou {tempo} trocando letras e transformando palavras"
            )
        ),
        PresetChallenge(
            title: "alfabeto em categorias",
            subTitle: "Animais de A a J",
            rationale: "Pense em um animal para cada letra de A até J. Se travar numa letra, siga e volte nela depois.",
            achievement: PresetAchievement(
                title: "zoológico mental",
                description: "você passou {tempo} achando um animal para cada letra de A até J"
            )
        ),
        PresetChallenge(
            title: "explique o inexplicável",
            subTitle: "Descreva uma cor",
            rationale: "Explique a cor azul para alguém que nunca enxergou, usando sons, temperaturas ou sensações.",
            achievement: PresetAchievement(
                title: "azul em palavras",
                description: "você passou {tempo} descrevendo o azul sem poder mostrá-lo"
            )
        ),
        PresetChallenge(
            title: "imaginar também é planejar",
            subTitle: "Seu dia perfeito",
            rationale: "Imagine como seria um dia perfeito para você, do acordar ao dormir. Pense em 5 momentos.",
            achievement: PresetAchievement(
                title: "dia dos sonhos",
                description: "você passou {tempo} imaginando o seu dia perfeito em 5 momentos"
            )
        ),
        PresetChallenge(
            title: "contas do dia a dia",
            subTitle: "Quanto é 15% de 80?",
            rationale: "Calcule 15% de 80 de cabeça. Dica: 10% é 8, e 5% é a metade disso.",
            achievement: PresetAchievement(
                title: "conta de padaria",
                description: "você passou {tempo} descobrindo 15% de 80 sem calculadora"
            )
        ),
        PresetChallenge(
            title: "decidir com calma",
            subTitle: "Três prós, três contras",
            rationale: "Pense numa decisão pequena que precisa tomar e liste 3 prós e 3 contras, só de cabeça.",
            achievement: PresetAchievement(
                title: "prós e contras",
                description: "você passou {tempo} pesando prós e contras de uma decisão"
            )
        ),
        PresetChallenge(
            title: "volte no tempo",
            subTitle: "Sua lembrança mais antiga",
            rationale: "Tente encontrar sua memória mais antiga. Quantos anos você tinha? Que detalhes aparecem?",
            achievement: PresetAchievement(
                title: "máquina do tempo",
                description: "você passou {tempo} visitando a sua lembrança mais antiga"
            )
        ),
        PresetChallenge(
            title: "venda o que está perto",
            subTitle: "Invente um slogan",
            rationale: "Escolha um objeto ao seu redor e crie um slogan publicitário para ele com até 6 palavras.",
            achievement: PresetAchievement(
                title: "slogan de ouro",
                description: "você passou {tempo} criando um slogan para um objeto qualquer"
            )
        ),
        PresetChallenge(
            title: "atenção que não pula",
            subTitle: "Pares de trás para frente",
            rationale: "Conte só os números pares de 60 até 0, de cabeça e sem pressa.",
            achievement: PresetAchievement(
                title: "só os pares",
                description: "você passou {tempo} contando os pares de 60 até 0 sem errar"
            )
        ),
    ]
}
