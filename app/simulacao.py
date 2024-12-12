# simulacao.py

import heapq
import random
from modelos import Servico, Servidor, Evento
import matplotlib.pyplot as plt


class Simulacao:
    """
    Representa a simulação de um sistema de servidores processando serviços.

    Atributos:
        fila_eventos (list): Fila de eventos ordenada por tempo.
        tempo_atual (float): Tempo atual na simulação.
        servidores (dict): Dicionário contendo os servidores.
        contador_servicos (int): Contador de serviços criados.
        servicos_completados (int): Número de serviços completados.
        servicos_coletados (int): Número de serviços coletados após o aquecimento.
        tempos_no_sistema (list): Tempos que os serviços passaram no sistema.
        servicos_aquecimento (int): Quantidade de serviços a ignorar no início.
        total_servicos_para_coleta (int): Total de serviços a coletar.
        duracoes_jobs (list): Lista das durações dos jobs no sistema.
    """

    def __init__(self, funcoes_tempo_servico: dict):
        """
        Inicializa a simulação com funções de tempo de serviço para os servidores.

        Args:
            funcoes_tempo_servico (dict): Mapeamento dos servidores para suas funções de tempo de serviço.
        """
        self.fila_eventos = []
        self.tempo_atual = 0
        self.servidores = {}
        self.contador_servicos = 0
        self.servicos_completados = 0
        self.servicos_coletados = 0
        self.tempos_no_sistema = []
        self.servicos_aquecimento = 1000000
        self.total_servicos_para_coleta = 1000000

        self.duracoes_jobs = []

        for nome, funcao in funcoes_tempo_servico.items():
            self.servidores[nome] = Servidor(nome, funcao)

    def executar(self):
        """
        Executa a simulação até que todos os serviços necessários sejam coletados.

        Calcula estatísticas ao final da simulação, como tempo médio no sistema e desvio padrão.
        """
        tempo_primeira_chegada = random.expovariate(2)  # 2 jobs por segundo
        self.agendar_evento(Evento(tempo_primeira_chegada, 'chegada'))

        while self.servicos_coletados < self.total_servicos_para_coleta:
            evento = heapq.heappop(self.fila_eventos)
            self.tempo_atual = evento.tempo

            if evento.tipo == 'chegada':
                self.processar_chegada(evento)
            elif evento.tipo == 'saida':
                self.processar_saida(evento)

        self.gerar_graficos()

    def agendar_evento(self, evento: Evento):
        """
        Agenda um evento adicionando-o à fila de eventos.

        Args:
            evento (Evento): Evento a ser adicionado à fila.
        """
        heapq.heappush(self.fila_eventos, evento)

    def processar_chegada(self, evento: Evento):
        """
        Processa um evento de chegada, encaminhando o serviço para o servidor apropriado.

        Args:
            evento (Evento): Evento de chegada a ser processado.
        """
        if evento.servico is None:
            self.contador_servicos += 1
            servico = Servico(self.contador_servicos, self.tempo_atual)
            servidor = self.servidores['S1']
            evento.servico = servico
            evento.servidor = servidor

            tempo_proxima_chegada = self.tempo_atual + random.expovariate(2)
            self.agendar_evento(Evento(tempo_proxima_chegada, 'chegada'))

        else:
            servico = evento.servico
            servidor = evento.servidor

        if servidor.ocupado_ate <= self.tempo_atual:
            tempo_servico = servidor.funcao_tempo_servico()
            servidor.tempo_ocupado += tempo_servico
            servidor.ocupado_ate = self.tempo_atual + tempo_servico
            servidor.servico_atual = servico

            self.agendar_evento(
                Evento(servidor.ocupado_ate, 'saida', servico, servidor))
        else:
            servidor.fila.append(servico)

    def processar_saida(self, evento: Evento):
        """
        Processa um evento de saída, movendo o serviço para o próximo estágio ou finalizando-o.

        Args:
            evento (Evento): Evento de saída a ser processado.
        """
        servico = evento.servico
        servidor = evento.servidor

        if servidor.fila:
            proximo_servico = servidor.fila.pop(0)
            tempo_servico = servidor.funcao_tempo_servico()
            servidor.tempo_ocupado += tempo_servico
            servidor.ocupado_ate = self.tempo_atual + tempo_servico
            servidor.servico_atual = proximo_servico

            self.agendar_evento(
                Evento(servidor.ocupado_ate, 'saida', proximo_servico, servidor))
        else:
            servidor.ocupado_ate = self.tempo_atual
            servidor.servico_atual = None

        if servidor.nome == 'S1':
            nome_proximo_servidor = random.choice(['S2', 'S3'])
            proximo_servidor = self.servidores[nome_proximo_servidor]
            self.agendar_evento(
                Evento(self.tempo_atual, 'chegada', servico, proximo_servidor))

        elif servidor.nome in ['S2', 'S3']:
            servico.tempo_saida = self.tempo_atual
            self.servicos_completados += 1
            if servico.id > self.servicos_aquecimento:
                self.servicos_coletados += 1
                tempo_no_sistema = servico.tempo_saida - servico.tempo_chegada
                self.tempos_no_sistema.append(tempo_no_sistema)

                self.duracoes_jobs.append(tempo_no_sistema)

    def gerar_graficos(self):
        """
        Gera os gráficos de duração dos jobs e utilização dos servidores.
        """
        plt.figure(figsize=(14, 10))

        # 1. Duração dos Jobs no Sistema
        plt.subplot(2, 1, 1)
        plt.hist(self.duracoes_jobs, bins=30, color='skyblue', edgecolor='black')
        plt.title('Duração dos Jobs no Sistema')
        plt.xlabel('Duração (s)')
        plt.ylabel('Frequência')
        plt.grid(True)

        # 2. Utilização Média dos Servidores
        plt.subplot(2, 1, 2)
        utilizacoes = {nome: (servidor.tempo_ocupado / self.tempo_atual) * 100
                      for nome, servidor in self.servidores.items()}
        cores_barras = ['blue', 'green', 'red', 'orange', 'purple']  # Consistência com as filas
        plt.bar(utilizacoes.keys(), utilizacoes.values(),
                color=cores_barras[:len(utilizacoes)], edgecolor='black')
        plt.title('Utilização Média dos Servidores')
        plt.xlabel('Servidor')
        plt.ylabel('Utilização (%)')
        plt.ylim(0, 100)  # Supondo que a utilização não ultrapasse 100%
        for index, (nome, utilizacao) in enumerate(utilizacoes.items()):
            plt.text(index, utilizacao + 1, f'{utilizacao:.2f}%', ha='center', va='bottom')
        plt.grid(axis='y')

        plt.tight_layout()
        plt.show()