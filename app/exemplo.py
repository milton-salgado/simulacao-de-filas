from numpy.random import default_rng

seed = 42
rng = default_rng(seed)

n = 30  # Numero de clientes
t = 0  # Variavel-relogio
tec_medio = 1.3  # Cliente chegam em media a cada 1.3 min
ta_medio = 1.0  # Tempo medio de atendimento
q = 0  # Estado da fila
b = 0  # Estado do servidor
eventos = []

for i in range(1, n+1):
    tec = rng.exponential(tec_medio)  # tec do cliente i
    c = t+tec  # Hora de chegada registrada no cronometro
    eventos.append([c, 'chegada'])
    t = c

while len(eventos) > 0:  # Loop de eventos

    eventos.sort()  # Ordena eventos crescentemente
    ev = eventos.pop(0)  # Retira da lista o evento mais cedo
    t = ev[0]  # Adianta a variavel relogio para o tempo do evento

    if ev[1] == 'chegada':
        print("Evento de chegada no tempo t = ", t)
        print("Tamanho da fila = ", q)
        if b == 1:  # Se servidor ocupado
            q = q+1  # Incrementa a fila

        else:  # Servidor desocupado
            b = 1  # Servidor fica ocupado
            ta = rng.exponential(ta_medio)  # Amostra o tempo de atendimento
            s = t+ta  # Momento de saida do cliente
            eventos.append([s, 'saida'])  # Agenda o eventos saida

    if ev[1] == 'saida':
        print("Evento de saída no tempo t = ", t)
        print("Tamanho da fila = ", q)
        if q == 0:  # Fila e zero?
            b = 0  # Servidor desocupa
        else:
            q = q-1  # Decrementa a fila
            ta = rng.exponential(ta_medio)  # Amostra o tempo de atendimento
            s = t+ta  # Computa Momento de saida do cliente
            eventos.append([s, 'saida'])  # Agenda o eventos saida
