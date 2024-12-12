#import "@preview/codly:1.0.0": *
#import "lib.typ": *
#import "@preview/fletcher:0.5.3": *

/* ************************************* CODLY SETTINGS ************************************* */

#set par(
  first-line-indent: 1em,
  spacing: 1.6em,
  justify: true,
  linebreaks: "optimized"
)

#show: codly-init.with()

#codly(
  languages: (
    c: (
      name: "C",
      color: rgb("#FED766")
    ),
    txt: (
      name: "text",
      color: rgb("#8C8A93")
    )
  )
)

#codly(
  zebra-fill: none,
  number-format: none
)

/* ************************************* GENERAL SETTINGS ************************************* */

#show outline.entry.where(
  level: 1
): it => {
  v(20pt, weak: true)
  strong(it)
  v(-5pt, weak: true)
}

#show: project.with(
  title: "Implementação de um Escalonador de Processos utilizando o Algoritmo Round-Robin com Feedback",
  subtitle: "Trabalho 1 - Relatório Técnico",
  authors: (
    "Pedro Saito : 122149392",
    "Milton Salgado : 122169279",
  ),
  mentors: (
    "Vinícius Gusmão Pereira de Sá",
  ),
  branch: "Modelagem e Avaliação de Desempenho",
  university: "Universidade Federal do Rio de Janeiro",
  academic-year: "2024",
  footer-text: "RELATÓRIO",
  school-logo: image("images/ufrj-logo.svg")
)

#set text(lang:"pt")

#set footnote(numbering: "1")

/* ************************************* GLOBAL VARS ************************************* */



/* ************************************* ESPECIFICAÇÃO ************************************* */

/*

O sistema é constituído por três servidores, S1, S2 e S3, cada qual dotado de
uma fila ilimitada. Cada job, ao chegar no sistema, precisa ser primeiramente
servido por S1. Após concluir o serviço em S1, o job segue com probabilidade 0.5
para o servidor S2, e com probabilidade 0.5 para o servidor S3. Um job que sai
do servidor S2 tem probabilidade 0.2 de retornar ao servidor S2 (voltando ao
final da fila de S2, se ela não estiver vazia) para receber um novo serviço,
independentemente de quantas vezes já tenha passado por S2. Ao sair
definitivamente de S2, o job sai do sistema. Da mesma forma, ao sair de S3
(deterministicamente), o job sai do sistema.

As chegadas de jobs ao sistema constituem um processo de Poisson com taxa lambda = 2 jobs por segundo. Ou seja, o tempo entre as chegadas de dois jobs consecutivos é uma V.A. exponencial com média 1/lambda = 0.5 segundos (isto é, uma exponencial com taxa lambda).

As métricas que você quer obter de forma experimental são:

- tempo médio no sistema
- desvio padrão do tempo no sistema

Você quer simular três situações.

Situação 1: os tempos de serviço são fixos, determinísticos, e iguais a 0.4s, 0.6s e 0.95s, respectivamente.

Situação 2: os tempos de serviço nos três servidores são V.A.s uniformes nos intervalos (0.1, 0.7), (0.1, 1.1) e (0.1, 1.8), respectivamente.

Situação 3: os tempos de serviço são V.A.s exponenciais com médias 0.4s, 0.6s e 0.95s, respectivamente.

Para colher as métricas em cada situação, descarte os primeiros 10mil jobs que chegarem ("warm up", dando tempo suficiente para que o sistema entre em seu estado estacionário), e só então colha as métricas observadas nos próximos 10mil jobs.

Disponibilize seu código (GitHub, ou Colab, ou o que preferir), e escreva um pequeno relatório dizendo o que foi observado.

O trabalho pode ser feito solo ou em dupla. Alguns alunos poderão ser escolhidos, individualmente, por sorteio, para explicarem trechos de seu código.
*/

/* ************************************* INTRODUÇÃO ************************************* */

= Introdução

A modelagem de redes de filas constitui uma abordagem analítica essencial para compreender o desempenho de sistemas computacionais complexos. Mediante simulação de fluxos de serviços através de múltiplos servidores, essa técnica permite avaliar métricas críticas como tempo de espera, utilização de recursos e throughput.

Este estudo propõe implementar um simulador de rede de filas aberta, explorando experimentalmente como diferentes distribuições probabilísticas de tempos de serviço impactam o comportamento sistêmico.

== Objetivos

O presente estudo tem como objetivo simular uma rede aberta de filas em diferentes condições de operação, avaliando métricas de desempenho relacionadas ao tempo de permanência dos jobs no sistema.

Especificamente, estamos interessados em:

#block(
  above: 0.5em,
  below: 0.5em,
  inset: 1em,
  [
    - Implementar um simulador de rede aberta de filas com três servidores, considerando filas ilimitadas, probabilidades de roteamento e diferentes distribuições de tempos de serviço.  
    - Coletar métricas dos _jobs_ no sistema de rede de filas, tal como o tempo médio no sistema e o desvio médio do tempo calculado.
    - Analisar o desenvolvimento do sistema de rede de filas em que os tempos de serviços dos _jobs_ são distribuídos de forma: *Determinística*, *uniforme* e, por fim, *exponencial*.
    - Explicar as estruturas e funções do código, abordando o tratamento de processos estocásticos e a coleta de métricas.
  ]
)

Ao final, espera-se demonstrar a eficácia do simulador em capturar as dinâmicas do sistema e facilitar a visualização de diferentes distribuições de tempos de serviço no desempenho global da rede.

/* ************************************* PREMISSAS ************************************* */

#pagebreak()

== Premissas

Para o desenvolvimento do simulador, foram estabelecidas algumas premissas, listadas a seguir:

  - *Três Servidores*: Conforme descrito no enunciado, há três servidores, identificados como "S1", "S2" e "S3". Os trabalhos chegam inicialmente ao servidor "S1" e, em seguida, têm probabilidade igual de serem direcionados para os demais servidores.
  
  - *Processo de Poisson e Exponencial*: As chegadas dos _jobs_ aos servidores constituem um *Processo de Poisson* com taxa $lambda = 2 "jobs/s"$. Portanto, o tempo entre a chegada de dois _jobs_ consecutivos pode ser descrito por uma *variável exponencial* com média de $0,5 "s"$.
  
  - *Distribuições do Tempo de Serviço*: Iremos analisar a distribuição do tempo de serviço sob diferentes circunstâncias, tal como:
  
      - Tempos de serviço fixos, isto é, determinísticos.
      - Tempos de serviço dados por uma variável uniforme.
      - Tempos de serviço distribuídos de forma exponencial.

  - *Espera até início do Estado Estacionário*: Antes de coletar as métricas, deve-se aguardar a chegada dos primeiros $1.000.000$ _jobs_, isto é, dando tempo o suficiente para que a cadeia entre no estado estacionário.

A representação do sistema que desejamos modelar está demonstrado abaixo:

#figure(
  diagram(
    node-stroke: .1em,
    node-fill: gradient.radial(blue.lighten(80%), gray, center: (30%, 20%), radius: 80%),
    spacing: 4em,
    node((0,0.4), `S1`, radius: 2em, name: <S1>),
    edge(<S1>, "-|>", <S2>, $0,5$),
    edge(<S1>, "-|>", <S3>, $0,5$),
    node((1.5,0), `S2`, radius: 2em, name: <S2>),
    edge((1.5,0), (1.5,0), $0,2$,"-|>", bend: 130deg),
    edge(<S2>, "-|>"),
    node((1.5,1), `S3`, radius: 2em, name: <S3>),
    edge(<S2>, "-|>", <S>),
    edge(<S3>, "-|>", <Sl>),
    node((2.5,0), radius: 0em, name: <S>),
    node((2.5,1.0), radius: 0em, name: <Sl>),
  ),
  caption: [Representação da Rede de Filas com os Servidores "S1", "S2" e "S3".]
)

/* ************************************* ALGORITMO ************************************* */

= Simulação

A simulação da cadeia de Markov aberta consiste em analisar um sistema de filas
em rede, no qual serviços (ou tarefas) chegam ao sistema, passam por diferentes
servidores, podendo seguir fluxos específicos ou deixar o sistema. Esse tipo de
simulação é amplamente empregado em estudos de teoria de filas, análise de
desempenho de sistemas e modelagem probabilística.

== Funcionamento

Para conduzir a simulação da cadeia de Markov aberta, estabelecemos as seguintes premissas:

    + O sistema é composto por múltiplos servidores (por exemplo, S1, S2 e S3).
    + Os serviços chegam ao sistema seguindo um processo estocástico (geralmente Poisson), o que garante uma chegada contínua e independente.
    + Cada servidor possui seu próprio tempo de serviço, que pode ser determinístico ou seguir distribuições de probabilidade (exponencial, uniforme, etc.).
    + O objetivo da simulação é analisar métricas como tempo médio de permanência no sistema, throughput e taxas de ocupação, sob diferentes cenários.

Com base nessas premissas, descrevemos a dinâmica da simulação:

- Serviços chegam inicialmente ao primeiro servidor (S1).
- Após o processamento em S1, os serviços podem ser roteados para outros servidores (por exemplo, S2 ou S3) de acordo com probabilidades pré-definidas.
- Alguns servidores podem apresentar realimentação interna: um serviço, após ser atendido, pode retornar ao mesmo servidor com certa probabilidade, antes de prosseguir para outro estágio ou deixar o sistema.
- Quando um serviço conclui o último estágio de atendimento, ele sai do sistema, permitindo analisar a distribuição dos tempos de permanência.

Na prática, para a simulação:

- Utiliza-se uma abordagem por eventos, na qual cada chegada e saída de serviço é um evento agendado.
- Ao processar um evento, o estado dos servidores, as filas e o tempo global da simulação são atualizados.
- A simulação é executada até que um número significativo de serviços seja processado, descartando-se um período inicial de aquecimento, a fim de se obter métricas estatisticamente estáveis.

== Exemplo

Considere um exemplo simples de um sistema com três servidores, S1, S2 e S3, no qual:

- Os serviços chegam ao S1 a uma taxa $lambda$.
- Após o atendimento em S1, um serviço pode ser encaminhado para S2 ou S3 com probabilidades p(S2) e p(S3).
- Em S2, existe a possibilidade de o serviço retornar ao mesmo servidor (feedback) com probabilidade $p_f$, prolongando seu tempo no sistema.
- Ao concluir o atendimento em S3 ou sair de S2 sem feedback, o serviço deixa o sistema.

As taxas de chegada, tempos médios de serviço e probabilidades de roteamento
podem ser ajustados para estudar diferentes cenários. Por exemplo, se
definirmos:

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.5pt + black)
  },
  align: (x, y) => (
    if x == 0 { center }
    else { center }
  )
)

#table(
  columns: 4,
  table.header(
    [*Servidor*],
    [*Distribuição de Serviço*],
    [*Próximo Servidor*],
    [*Probabilidade*]
  ),
  [S1],[Exponencial (média 0.4s)],[S2],[0.5],
  [S1],[Exponencial (média 0.4s)],[S3],[0.5],
  [S2],[Exponencial (média 0.6s)],[S2],[0.2],
  [S2],[Exponencial (média 0.6s)],[Saída],[0.8],
  [S3],[Exponencial (média 0.95s)],[Saída],[1.0]
)

Ao executar a simulação, podemos observar estatísticas como tempo médio que os serviços passam no sistema, a carga média de cada servidor e a eficiência do sistema para diferentes distribuições e parâmetros.

/* ************************************* CODING ************************************* */

= Código

Nesta seção, descrevemos a implementação do simulador de sistema de servidores,
incluindo as classes de dados, módulos e funções principais. O código em Python
foi desenvolvido seguindo práticas de modularidade e simplicidade, facilitando a
manutenção e a expansão do simulador.

== Organização do Projeto

O projeto tem quatro arquivos de cabeçalho, cada um com um arquivo `.c` correspondente, exceto o `main.c`. As funções estão declaradas nos arquivos de cabeçalho. Abaixo está a estrutura do projeto:

#codly-disable()
```txt
├── README.md
├── app
│   ├── exemplo.py
│   ├── modelos.py
│   ├── simulacao.ipynb
│   └── simulacao.py
└── utils
│   └── requirements.txt
└── docs
    └── relatorio.pdf
```
#codly-enable()

== Classes e Funções

Durante a implementação da simulação da cadeia de Markov aberta, foram definidas diversas classes e funções para representar servidores, serviços e eventos no sistema. Cada classe encapsula um aspecto fundamental da simulação, permitindo organizar e manipular o estado do sistema de forma estruturada.

Abaixo, detalhamos as classes e estruturas utilizadas, assim como suas funções mais relevantes.

#pagebreak()

=== Serviços

A classe `Servico` representa um trabalho que chega ao sistema, podendo passar
por um ou mais servidores antes de sair. Ela contém as seguintes variáveis como:

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  table.header([Variável], [Descrição]),
  [*`id`*], [Identificador único do serviço.],
  [*`tempo_chegada`*], [Tempo de chegada do serviço ao sistema.],
  [*`tempos_servico`*], [Dicionário contendo tempos gastos em cada servidor.],
  [*`tempo_saida`*], [Tempo em que o serviço saiu do sistema.],
)

=== Servidores

A classe `Servidor` representa um servidor dentro da rede de filas. Cada servidor possui:

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  table.header([Variável], [Descrição]),
  [*`nome`*], [Nome do servidor (por ex.: "S1", "S2", "S3").],
  [*`fila`*], [Lista de serviços aguardando processamento.],
  [*`ocupado_ate`*], [Tempo até o qual o servidor estará ocupado.],
  [*`funcao_tempo_servico`*], [Função que determina o tempo de serviço para novos atendimentos.],
  [*`servico_atual`*], [Serviço atualmente em processamento, se houver.],
)

=== Eventos

A classe `Evento` modela qualquer mudança de estado que ocorre na simulação. Há dois tipos de eventos principais: "chegada" e "saida". Cada `Evento` possui:

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  table.header([Variável], [Descrição]),
  [*`tempo`*], [Tempo no qual o evento ocorre.],
  [*`tipo`*], [Tipo do evento ("chegada" ou "saida").],
  [*`servico`*], [Serviço associado ao evento (se aplicável).],
  [*`servidor`*], [Servidor associado ao evento (se aplicável).],
)

=== Simulação

As funções que implementam a lógica da simulação são agregadas na classe `Simulacao`. Alguns dos principais métodos são:

+ `__init__(self, funcoes_tempo_servico: dict)`

  - Inicializa a simulação, criando os servidores e definindo funções de tempo de serviço para cada um.
  - Não possui valor de retorno.

+ `executar(self)`

  - Executa a simulação até que um determinado número de serviços seja coletado.
  - Processa eventos de forma cronológica, atualizando o estado do sistema (filas, servidores e métricas).
  - Ao final, calcula e exibe estatísticas (tempo médio no sistema, desvio padrão).
  - Não possui valor de retorno.

+ `agendar_evento(self, evento: Evento)`

  - Insere um evento na fila de eventos, ordenada pelo tempo.
  - Não possui valor de retorno.

+ `processar_chegada(self, evento: Evento)`

  - Trata a chegada de um novo serviço ou o repasse de um serviço já existente a um servidor específico.
  - Caso o servidor esteja livre, inicia o processamento imediatamente. Caso contrário, o serviço é inserido na fila de espera do servidor.
  - Agenda o próximo evento de chegada (se for um novo serviço externo) e o evento de saída deste serviço quando concluído.
  - Não possui valor de retorno.

+ `processar_saida(self, evento: Evento)`

  - Trata a conclusão do atendimento de um serviço em um servidor.
  - Caso haja serviços na fila de espera, inicia o próximo imediatamente.
  - Dependendo do servidor, o serviço pode ser encaminhado a outro servidor, voltar ao mesmo ou sair do sistema.
  - Registra o tempo total de permanência no sistema, se aplicável.
  - Não possui valor de retorno.

=== Distribuições de Tempo de Serviço

As funções responsáveis por gerar os tempos de serviço para cada servidor são fornecidas via dicionário no construtor da simulação. Podem ser determinísticas, uniformes ou exponenciais:

+ *Tempos Determinísticos:* Na situação 1, os tempos de serviço são constantes e específicos para cada servidor. Por exemplo, o servidor S1 sempre leva 0.4 segundos para processar um serviço.

+ *Distribuições Uniformes:* Na situação 2, os tempos de serviço seguem uma distribuição uniforme dentro de um intervalo específico. Por exemplo, o servidor S1 tem tempos de serviço entre 0.1 e 0.7 segundos, escolhidos aleatoriamente usando random.uniform.

+ *Distribuições Exponenciais:* Na situação 3, os tempos de serviço seguem uma distribuição exponencial. Para gerar tempos de serviço exponenciais, utilizamos random.expovariate. A função expovariate(1/λ) gera tempos de serviço exponenciais com média λ.

=== Filas de Prioridade com Heap

A fila de eventos é implementada como uma fila de prioridade usando um heap. Em Python, a biblioteca heapq é utilizada para manter a fila ordenada por tempo, permitindo que os eventos sejam processados em ordem cronológica. O heap é eficiente para inserir elementos e extrair o menor elemento, ambos em tempo O(log n).

=== Métricas e Ajustes

Para análise de desempenho, a simulação ignora um conjunto inicial de serviços (período de aquecimento) e, posteriormente, coleta estatísticas dos serviços seguintes. Essas métricas incluem:

- *Tempo médio no sistema:* Média do tempo que cada serviço dura no sistema.
- *Desvio padrão:* Variação do tempo de permanência, permitindo medir a dispersão.

Ao término da execução, o simulador imprime os resultados obtidos, permitindo a análise do comportamento do sistema sob diferentes parâmetros de chegada, roteamento e tempo de serviço.


= Saída

```txt
Simulação - Situação 1
Tempo médio no sistema: 7.091735829777251
Desvio padrão do tempo no sistema: 8.543577938831138

# Exibição do gráfico com tempo de serviço determinístico

Simulação - Situação 2
Tempo médio no sistema: 8.768989782193337
Desvio padrão do tempo no sistema: 10.966880115767493

# Exibição do gráfico com tempo de serviço uniforme

Simulação - Situação 3
Tempo médio no sistema: 12.594940058080958
Desvio padrão do tempo no sistema: 15.260461154376697

# Exibição do gráfico com tempo de serviço exponencial
```

= Resultados

#v(-4pt)

O primeiro gráfico ilustra a dinâmica do tempo de serviço sob um modelo
determinístico, revelando o comportamento temporal dos processos em um contexto
de variação controlada.

#figure(
  scale(94%, image("images/graph_deterministic.png")),
  caption: [Resultado para tempos de serviços determinísticos]
)

#v(11pt)

O gráfico do tempo médio mostra uma progressão inicial de 4.5 para 7.0, com
flutuações que sugerem variações no processamento de serviços. O desvio padrão
segue trajetória similar, aumentando de 4 para 8.5, indicando maior
variabilidade nos tempos de serviço à medida que o sistema evolui. Essas
oscilações refletem a complexidade operacional e as nuances do processamento do
sistema.

#pagebreak()

O gráfico subsequente apresenta a dinâmica do tempo de serviço segundo um modelo
uniforme, evidenciando a distribuição equitativa dos intervalos de processamento
em um espectro de variação padronizada.

#figure(
  scale(94%, image("images/graph_uniform.png")),
  caption: [Resultado para tempos de serviços uniformes]
)

#v(14pt)

A análise dos gráficos revela uma tendência decrescente tanto no tempo médio
quanto no desvio padrão dos serviços. Essa redução sugere uma melhoria
progressiva na eficiência do sistema, com processamentos mais rápidos e
consistentes. Os resultados indicam um possível equilíbrio operacional, onde os
tempos de serviço se tornam mais previsíveis e ágeis ao longo da simulação.

#figure(
  image("images/graph_exponential.png"),
  caption: [Resultado para tempos de serviços exponenciais]
)

No primeiro gráfico observa-se que a linha começa em torno de 8, atinge um pico
em torno de 16 e depois diminui gradualmente para cerca de 12. Isso indica que,
no início, os tempos médios no sistema aumentaram significativamente,
possivelmente devido ao aquecimento do sistema e à chegada inicial de muitos
serviços. Com o tempo, o sistema começou a processar os serviços de forma mais
eficiente, resultando na diminuição do tempo médio. Já no segundo gráfico, a
linha começa em torno de 6, atinge um pico em torno de 20 e depois diminui
gradualmente para cerca de 14. Esse aumento inicial no desvio padrão sugere uma
maior variabilidade nos tempos de serviço no início da simulação. À medida que a
simulação avança, essa variabilidade diminui, indicando que o sistema se
estabiliza com tempos de serviço mais consistentes.

#v(15pt)

#pagebreak()

#let scale-size = 96%

=== Caso Determinístico

No caso determinístico, todos os tempos de serviço têm valores fixos e iguais.
Isso resulta em um comportamento altamente previsível, onde os tempos de
resposta e a ocupação dos servidores refletem diretamente as diferenças nas
taxas de chegada e distribuição do trabalho.

+ Gráfico de Duração dos Jobs no Sistema:

    - O histograma apresenta um pico único em torno de um valor fixo. Isso reflete a natureza determinística, onde todos os serviços levam o mesmo tempo para serem processados.
    - A fila se mantém pequena, já que o tempo é previsível e os servidores processam os jobs de maneira uniforme.

2.	Utilização Média dos Servidores:

    - Os valores de utilização variam de acordo com a carga de trabalho distribuída para cada servidor. Um servidor pode ter alta utilização (ex.: 95% em S3) se for mais frequentemente escolhido, enquanto outros, como S2, podem apresentar menor carga.

#scale(
  scale-size,
figure(
  image("images/other-deterministic.png"),
  caption: [Resultado para tempos de serviços determinísticos]
)
)

#v(-46pt)

=== Caso Uniforme

No caso uniforme, os tempos de serviço são distribuídos aleatoriamente dentro de um intervalo fixo (ex.: 2 a 5 segundos). Isso introduz uma variabilidade moderada no sistema, influenciando os tempos de espera e a ocupação dos servidores.

+ Gráfico de Duração dos Jobs no Sistema:

    - O histograma apresenta uma distribuição uniforme, com frequências aproximadamente iguais para os tempos de serviço dentro do intervalo definido.
	  -	A maior variabilidade nos tempos de serviço pode levar a flutuações no tamanho das filas.
   
+ Utilização Média dos Servidores:

    - A utilização dos servidores será mais balanceada em comparação ao caso determinístico, devido à maior distribuição aleatória dos tempos de serviço.
    - Pequenas diferenças podem surgir devido a eventos de alta carga momentânea.


#scale(
  scale-size,
figure(
  image("images/other-uniform.png"),
  caption: [Resultado para tempos de serviços determinísticos]
)
)

#v(-46pt)

#pagebreak() 

=== Caso Exponencial

No caso exponencial, os tempos de serviço são distribuídos de forma assimétrica, com muitos serviços rápidos e alguns significativamente mais longos. Essa é uma distribuição comum em sistemas reais, como redes e filas.

+ Gráfico de Duração dos Jobs no Sistema:

    - O histograma apresenta uma concentração de serviços com duração curta, mas uma “cauda longa” de serviços com tempos elevados.
	 - Esse comportamento pode levar ao acúmulo de filas em momentos de maior carga, principalmente para serviços de longa duração.
  
+ Utilização Média dos Servidores:

    - A utilização será mais imprevisível, com picos elevados em servidores que recebem serviços longos. Isso pode levar a desequilíbrios temporários na carga dos servidores.
    - Em média, a utilização pode ser similar ao caso uniforme, mas com maior variância entre os servidores.
#scale(
  scale-size,
figure(
  image("images/other-exponential.png"),
  caption: [Resultado para tempos de serviços determinísticos]
)
)

#pagebreak(weak: true)


= Conclusão

Analiticamente, esperávamos que o servidor 2 tivesse uma utilização maior por conta do "self-loop", garantindo que mais serviços chegassem na fila e fossem processados, mas aparentemente, a tendência do tamanho médio de fila maior se concentrou no servidor 3,
aumentando drasticamente sua utilização, deixando o servidor 2 ocioso por mais tempo. 

Além disso, ao calcularmos analiticamente o tempo médio (essencialmente para a primeira situação), percebemos que o tempo na fila influencia em praticamente 90% o tamanho do tempo médio no sistema, dado que o tempo médio no servidor (não contando a fila) foi de aproximadamente 1.25.

Também notamos que a amostragem pela inversa das distribuições probabilísticas utilizadas revela as variâncias no comportamento do sistema ao se adaptar às naturezas dos eventos e seus serviços, em cada uma das situações.

#pagebreak()

#bibliography(
  "resources/referencias.bib",
  full: true, 
  style: "thieme"
)
