# MyFinances - App de Controle Financeiro Pessoal

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Um aplicativo completo e multiplataforma (Android, iOS & Web) para gestão de finanças pessoais, desenvolvido em Flutter e integrado com os serviços da Firebase. Permite o controle de despesas, receitas e metas de forma intuitiva, segura e em tempo real.

<!-- ![Capa do App](https://i.imgur.com/G5gJ81V.png) -->

---

## 🚀 Funcionalidades Principais

O aplicativo foi construído com uma série de funcionalidades robustas para garantir uma experiência de usuário completa:

#### 👤 **Autenticação e Segurança**
* **Login e Cadastro:** Sistema de autenticação completo via E-mail e Senha.
* **Sessão Persistente:** O usuário entra automaticamente no app se já estiver logado.
* **Separação de Dados:** Todas as informações são atreladas ao `userId` do usuário, garantindo total privacidade e segurança dos dados.

#### 📊 **Dashboard (Tela Home)**
* **Visão Mensal:** O dashboard exibe um balanço (receitas vs. despesas) filtrado pelo mês corrente.
* **Navegação entre Meses:** O usuário pode navegar para meses anteriores e futuros para visualizar o histórico financeiro.
* **Gráfico de Despesas:** Um gráfico de pizza (`PieChart`) mostra a distribuição das despesas por categoria.
* **Acompanhamento de Meta:** Um card de progresso exibe o quão perto o usuário está de atingir sua meta financeira principal.
* **Lançamentos Recentes:** Uma lista com as últimas despesas do mês selecionado.

#### 💸 **Gerenciamento de Transações**
* **CRUD Completo:** Adicione, edite e exclua despesas e receitas.
* **Definição de Meta:** O usuário pode definir uma única meta principal, com opção de edição.
* **Formulários Inteligentes:**
    * **Seletores de Data:** Um calendário nativo (`DatePicker`) para uma seleção de data fácil e sem erros.
    * **Máscara de Moeda:** Campos de valor formatam o número no padrão brasileiro (R$ 1.200,99) automaticamente durante a digitação.

#### 📜 **Histórico e Pesquisa**
* **Histórico Unificado:** Uma tela dedicada com abas para visualizar a lista completa de todas as despesas e receitas em tempo real.
* **Pesquisa Avançada:** Uma tela de relatórios poderosa que permite:
    * Buscar despesas por nome (case-insensitive).
    * Ordenar os resultados por Data, Valor ou Ordem Alfabética (A-Z).

#### ⚙️ **Configurações e Sobre**
* **Layout Responsivo:** As telas foram construídas para se adaptar a diferentes tamanhos de dispositivos.
* **Feedback do Usuário:** Uma seção de "Sugestões" com um formulário que abre o cliente de e-mail padrão do usuário para enviar feedback.
* **Informações do App:** Tela "Sobre" com detalhes, versão e informações do desenvolvedor.

---

## 🛠️ Tecnologias Utilizadas

* **Framework:** [Flutter](https://flutter.dev/)
* **Linguagem:** [Dart](https://dart.dev/)
* **Backend & Banco de Dados:**
    * **Firebase Authentication:** Para gerenciamento de usuários.
    * **Cloud Firestore:** Banco de dados NoSQL para armazenar transações e metas em tempo real.
    * **Firebase Hosting:** Para publicação da versão web.
* **Principais Pacotes:**
    * `cloud_firestore` & `firebase_auth`
    * `fl_chart` (Gráficos)
    * `intl` & `flutter_localizations` (Formatação de data e moeda)
    * `url_launcher` (Abrir links externos, como o e-mail)
    * `flutter_speed_dial` (Botão flutuante com múltiplas ações)
    * `rxdart` (Combinação de streams de dados)
    * `flutter_multi_formatter` (Máscara de input para valores monetários)

---

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura limpa, separando as responsabilidades em diferentes pastas dentro de `lib/`:

* **`screens/`**: Contém as telas (UI), organizadas em subpastas por funcionalidade (auth, home, transactions, etc.).
* **`models/`**: Definição das classes de modelo (ex: `Transaction`).
* **`widgets/`**: Widgets reutilizáveis em todo o app.
* **`services/`**: Lógica de comunicação com serviços externos, como o Firebase.

---

## ⚙️ Configuração do Ambiente

Para rodar este projeto localmente, siga os passos abaixo:

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/seu-usuario/seu-repositorio.git](https://github.com/seu-usuario/seu-repositorio.git)
    cd seu-repositorio
    ```

2.  **Configure o Firebase:**
    * Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
    * Adicione o suporte para **Android, iOS e Web**.
    * Siga as instruções para gerar e adicionar o arquivo `firebase_options.dart` na pasta `lib/` do projeto.
    * No console do Firebase, habilite os serviços:
        * **Authentication** (com o provedor "E-mail/senha").
        * **Firestore Database**.
        * **Hosting**.

3.  **Instale as dependências do Flutter:**
    ```bash
    flutter pub get
    ```

4.  **Rode o aplicativo:**
    ```bash
    flutter run
    ```

---

## 🌐 Build e Deploy (Web)

Para publicar uma nova versão na web:

1.  **Compile o projeto para a web:**
    ```bash
    flutter build web
    ```
2.  **Publique no Firebase Hosting:**
    ```bash
    firebase deploy --only hosting
    ```
---

## 👨‍💻 Autor

Feito com ❤️ por **Lorenzo Janota**.

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
