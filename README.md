# Simulação de Sistema de Servidores

## 📚 Tabela de Conteúdos

- [Simulação de Sistema de Servidores](#simulação-de-sistema-de-servidores)
  - [📚 Tabela de Conteúdos](#-tabela-de-conteúdos)
  - [📋 Descrição](#-descrição)
    - [🚀 Funcionalidades](#-funcionalidades)
    - [📸 Prévia](#-prévia)
  - [⚙️ Construção](#️-construção)
    - [💻 Tecnologias](#-tecnologias)
    - [🛠️ Ferramentas](#️-ferramentas)
    - [📌 Versão](#-versão)
  - [📥 Instalação e Execução](#-instalação-e-execução)
    - [Requisitos](#requisitos)
    - [Passos para Execução](#passos-para-execução)
  - [✏️ Aprendizados](#️-aprendizados)
  - [✒️ Autores](#️-autores)
  - [🎁 Agradecimentos](#-agradecimentos)

## 📋 Descrição

Este projeto implementa uma simulação de um sistema de servidores processando serviços. Ele utiliza eventos de chegada e saída para modelar o fluxo de serviços através de diferentes servidores, com base em tempos de serviço gerados aleatoriamente. O objetivo é analisar o desempenho do sistema, incluindo métricas como o tempo médio no sistema e o desvio padrão desse tempo.

### 🚀 Funcionalidades

- Modelagem de servidores processando serviços de forma concorrente.
- Geração de eventos de chegada e saída de serviços.
- Coleta de estatísticas como tempo médio no sistema e desvio padrão.
- Configuração flexível de parâmetros como aquecimento e total de serviços coletados.

### 📸 Prévia

<div align="center">
  <img src="./assets/preview/project_preview.webp" alt="Prévia do Projeto" width="500">
</div>s

## ⚙️ Construção

### 💻 Tecnologias


![Python](https://img.shields.io/badge/python-%2314354C.svg?style=for-the-badge&logo=python&logoColor=white)
![Jupyter](https://img.shields.io/badge/jupyter-%23F37626.svg?style=for-the-badge&logo=jupyter&logoColor=white)
![Random](https://img.shields.io/badge/random-%23013243.svg?style=for-the-badge&logo=random&logoColor=white)
![Matplotlib](https://img.shields.io/badge/matplotlib-%23ffffff.svg?style=for-the-badge&logo=matplotlib&logoColor=black)

### 🛠️ Ferramentas

![Visual Studio Code](https://img.shields.io/badge/VS%20Code-0078d7?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)

### 📌 Versão

Este é o projeto na versão 1.0.

## 📥 Instalação e Execução

### Requisitos
- Python 3.8 ou superior.
- Bibliotecass: `heapq`, `random`.

### Passos para Execução

1. Certifique-se de que todos os arquivos estão no mesmo diretório.
2. Clone o repositório:
   ```bash
   git clone <(https://github.com/milton-salgado/simulacao-de-filas)>
   cd <simulacao-de-filas>
   ```
3. Crie um ambiente virtual e ative-o:
   - **Linux/macOS**:
     ```bash
     python3 -m venv .venv
     source .venv/bin/activate
     ```
   - **Windows**:
     ```bash
     python -m venv .venv
     .venv\Scripts\activate
     ```
4. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
5. Execute o projeto:
   ```bash
   python simulacao.py
   ```

## ✏️ Aprendizados

Com este projeto, aprendi:
- Implementar simulações baseadas em eventos.
- Trabalhar com filas de prioridade para gerenciamento de eventos.
- Analisar estatísticas para medir o desempenho de sistemas simulados.

## ✒️ Autores

* **Milton Salgado** - *Construção do Código / Modelagem de Classes* - [milton-salgado](https://github.com/milton-salgado)
* **Pedro Saito** - *Geração e Análise de Gráficos / Construção do Relatório* - [saitoi](https://github.com/saitoi)

## 🎁 Agradecimentos

- Agradecemos ao professor Vinícius Gusmão pela orientação e suporte durante o desenvolvimento deste projeto e na disciplina de Modelagem e Análise de Desempenho.