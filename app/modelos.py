class Servico:
    """
    Representa um serviço a ser processado pelos servidores.

    Atributos:
        id (int): Identificador único do serviço.
        tempo_chegada (float): Tempo em que o serviço chegou ao sistema.
        tempos_servico (dict): Dicionário com tempos de serviço por servidor.
        tempo_saida (float): Tempo em que o serviço saiu do sistema (se aplicável).
    """

    def __init__(self, id: int, tempo_chegada: float):
        """
        Inicializa um serviço com identificador e tempo de chegada.

        Args:
            id (int): Identificador único do serviço.
            tempo_chegada (float): Tempo em que o serviço chegou ao sistema.
        """
        self.id = id
        self.tempo_chegada = tempo_chegada
        self.tempo_saida = None


class Servidor:
    """
    Representa um servidor que processa serviços.

    Atributos:
        nome (str): Nome do servidor.
        fila (list): Fila de serviços esperando para serem processados.
        ocupado_ate (float): Tempo até o qual o servidor está ocupado.
        funcao_tempo_servico (callable): Função que determina o tempo de serviço para o servidor.
        servico_atual (Servico): Serviço que está sendo processado atualmente (se aplicável).
    """

    def __init__(self, nome: str, funcao_tempo_servico: callable):
        """
        Inicializa um servidor com nome e função de tempo de serviço.

        Args:
            nome (str): Nome do servidor.
            funcao_tempo_servico (callable): Função que gera o tempo de serviço para o servidor.
            servico_atual: Recebe id serviço atual
        """
        self.nome = nome
        self.fila = []
        self.ocupado_ate = 0
        self.funcao_tempo_servico = funcao_tempo_servico
        self.servico_atual = None


class Evento:
    """
    Representa um evento na simulação.

    Atributos:
        tempo (float): Tempo em que o evento ocorre.
        tipo (str): Tipo do evento ('chegada' ou 'saida').
        servico (Servico): Serviço associado ao evento (se aplicável).
        servidor (Servidor): Servidor associado ao evento (se aplicável).
    """

    def __init__(self, tempo: float, tipo: str, servico: Servico = None, servidor: Servidor = None):
        """
        Inicializa um evento com tempo, tipo e entidades relacionadas.

        Args:
            tempo (float): Tempo em que o evento ocorre.
            tipo (str): Tipo do evento ('chegada' ou 'saida').
            servico (Servico, opcional): Serviço associado ao evento.
            servidor (Servidor, opcional): Servidor associado ao evento.
        """
        self.tempo = tempo
        self.tipo = tipo
        self.servico = servico
        self.servidor = servidor

    def __lt__(self, outro_evento):
        """
        Compara eventos para ordenação por tempo.

        Args:
            outro_evento (Evento): Outro evento para comparação.

        Returns:
            bool: True se o evento atual ocorre antes do outro evento.
        """
        return self.tempo < outro_evento.tempo
