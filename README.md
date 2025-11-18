# Someone Talking

Uma rede social simples desenvolvida em Flutter para fins de estudo, com funcionalidades de feed e chat básico.

## 📱 Sobre o Projeto

O **Someone Talking** é o front-end mobile de uma aplicação de rede social que permite aos usuários:

- Criar conta e fazer login
- Visualizar e editar perfil
- Navegar pelo feed de publicações
- Interagir socialmente de forma simples

Este projeto foi desenvolvido como estudo de caso para aprender desenvolvimento mobile com Flutter e integração com APIs REST.

## 🛠 Tecnologias Utilizadas

- **Flutter** - Framework para desenvolvimento mobile
- **Dart** - Linguagem de programação
- **HTTP** - Comunicação com API REST
- **Provider** - Gerenciamento de estado
- **SharedPreferences** - Persistência local de dados
- **JWT Decoder** - Decodificação de tokens JWT
- **Mask Text Input Formatter** - Máscaras para campos de texto
- **Image Picker** - Upload de imagens da galeria/câmera

## 📋 Funcionalidades

### Autenticação

- [x] Cadastro de usuários
- [x] Login com JWT
- [x] Persistência de sessão
- [x] Logout

### Perfil

- [x] Visualização de dados do usuário
- [x] Edição de perfil (nome, email, telefone, data de nascimento)
- [x] Interface moderna e responsiva

### Navegação

- [x] Bottom Navigation Bar
- [x] Transições animadas entre telas
- [x] Verificação automática de login

### Feed

- [x] Feed dinâmico com publicações reais
- [x] Postagem de texto e imagem (estilo Facebook/Instagram)
- [x] Upload de imagens
- [x] Visualização de imagens do backend
- [ ] Sistema de curtidas e comentários

## 🏗 Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com a seguinte estrutura:

```
lib/
├── config/           # Configurações globais (API)
├── models/          # Modelos de dados
├── viewmodels/      # Lógica de negócio e estado
│   └── auth/        # ViewModels de autenticação
├── views/           # Interfaces de usuário
│   ├── auth/        # Telas de autenticação
│   └── feed/        # Telas do feed
└── main.dart        # Ponto de entrada da aplicação
```

## 🔧 Configuração da API

A aplicação se conecta com um backend NestJS através das seguintes rotas:

- `POST /auth/registration` - Cadastro de usuários
- `POST /auth/login` - Login e geração de JWT
- `GET /auth/{id}` - Buscar dados do usuário
- `PUT /auth/{id}` - Atualizar dados do usuário
- `GET /feeds` - Listar publicações
- `POST /feeds` - Criar publicação (texto/imagem)
- `GET /feeds/{id}` - Buscar publicação por id

### Configuração do Endpoint

Edite o arquivo `lib/config/api_config.dart` com o endereço da sua API:

```dart
const String apiUrl = 'http://SEU_IP:PORTA';
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK instalado
- Dart SDK instalado
- Android Studio ou VS Code
- Emulador Android ou dispositivo físico

### Passos

1. Clone o repositório:

```bash
git clone https://github.com/JCZerf/app_someone_talking.git
cd someone_talking_app
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Configure o endereço da API em `lib/config/api_config.dart`

4. Execute a aplicação:

```bash
flutter run
```

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.6.0
  provider: ^6.1.5+1
  shared_preferences: ^2.1.1
  jwt_decoder: ^2.0.1
  mask_text_input_formatter: ^2.9.0
  image_picker: ^1.2.1
```

## 🎯 Roadmap

- [x] Feed dinâmico com publicações reais
- [x] Upload de imagens
- [x] Logo e ícone personalizados
- [x] Postagem estilo Facebook/Instagram
- [ ] Sistema de curtidas e comentários
- [ ] Chat básico entre usuários
- [ ] Notificações push
- [ ] Modo escuro

## 👨‍💻 Desenvolvedor

Desenvolvido por [JCZerf](https://github.com/JCZerf).

## 📄 Licença

Este projeto é apenas para fins educacionais e de estudo.
