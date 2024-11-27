import heapq
import random
from modelos import Servico, Servidor, Evento


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
    """

    def __init__(self, funcoes_tempo_servico):
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
        self.servicos_aquecimento = 10000
        self.total_servicos_para_coleta = 10000

        self.servidores['S1'] = Servidor('S1', funcoes_tempo_servico['S1'])
        self.servidores['S2'] = Servidor('S2', funcoes_tempo_servico['S2'])
        self.servidores['S3'] = Servidor('S3', funcoes_tempo_servico['S3'])

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

        tempo_medio_no_sistema = sum(
            self.tempos_no_sistema) / len(self.tempos_no_sistema)
        variancia = sum((x - tempo_medio_no_sistema) **
                        2 for x in self.tempos_no_sistema) / len(self.tempos_no_sistema)
        desvio_padrao_no_sistema = variancia ** 0.5
        print(f'Tempo médio no sistema: {tempo_medio_no_sistema}')
        print(f'Desvio padrão do tempo no sistema: {desvio_padrao_no_sistema}')

    def agendar_evento(self, evento):
        """
        Agenda um evento adicionando-o à fila de eventos.

        Args:
            evento (Evento): Evento a ser adicionado à fila.
        """
        heapq.heappush(self.fila_eventos, evento)

    def processar_chegada(self, evento):
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
            servidor.ocupado_ate = self.tempo_atual + tempo_servico
            servidor.servico_atual = servico
            servico.tempos_servico[servidor.nome] = tempo_servico

            self.agendar_evento(
                Evento(servidor.ocupado_ate, 'saida', servico, servidor))
        else:
            servidor.fila.append(servico)

    def processar_saida(self, evento):
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
            servidor.ocupado_ate = self.tempo_atual + tempo_servico
            servidor.servico_atual = proximo_servico
            proximo_servico.tempos_servico[servidor.nome] = tempo_servico

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

        elif servidor.nome == 'S2':
            if random.random() < 0.2:
                self.agendar_evento(
                    Evento(self.tempo_atual, 'chegada', servico, servidor))
            else:
                servico.tempo_saida = self.tempo_atual
                self.servicos_completados += 1
                if servico.id > self.servicos_aquecimento:
                    self.servicos_coletados += 1
                    tempo_no_sistema = servico.tempo_saida - servico.tempo_chegada
                    self.tempos_no_sistema.append(tempo_no_sistema)

        elif servidor.nome == 'S3':
            servico.tempo_saida = self.tempo_atual
            self.servicos_completados += 1
            if servico.id > self.servicos_aquecimento:
                self.servicos_coletados += 1
                tempo_no_sistema = servico.tempo_saida - servico.tempo_chegada
                self.tempos_no_sistema.append(tempo_no_sistema)
