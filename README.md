# ✂️ Barbú — App de Agendamento de Barbearia

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-orange?logo=firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" />
  <img src="https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow" />
</p>

> Protótipo de aplicativo mobile/web para organização e agendamento automatizado de cortes em uma barbearia local. Desenvolvido com Flutter + Firebase.

---

## 📱 Funcionalidades

| Funcionalidade | Status |
|---|---|
| Login e cadastro de clientes | ✅ Implementado |
| Agendamento de cortes (serviço, barbeiro, data e horário) | ✅ Implementado |
| Verificação de horários ocupados em tempo real | ✅ Implementado |
| Histórico de agendamentos do cliente | ✅ Implementado |
| Cancelamento de agendamentos | ✅ Implementado |
| Central de avisos / notificações in-app | ✅ Implementado |
| Lembretes locais agendados (1h antes do corte) | ✅ Implementado |
| Página de perfil do usuário | ✅ Implementado |
| Informações e contato da barbearia | ✅ Implementado |
| Programa de fidelidade (Loyalty) | 🚧 Em desenvolvimento |
| Produtos / Loja | 🚧 Em desenvolvimento |

---

## 🏗️ Arquitetura do Projeto

```
Tela_Home_Inicial/
└── lib/
    ├── core/
    │   └── theme/
    │       └── app_theme.dart          # Design system: cores, tipografia
    ├── models/
    │   └── service_model.dart          # Dados de serviços e barbeiros
    ├── screens/
    │   ├── auth/
    │   │   ├── login_page.dart         # Tela de login
    │   │   └── register_page.dart      # Tela de cadastro
    │   ├── bookings/
    │   │   └── booking_page.dart       # Fluxo de agendamento (3 etapas)
    │   ├── history/
    │   │   └── history_page.dart       # Histórico de cortes
    │   ├── home/
    │   │   ├── home_page.dart          # Tela principal (dashboard)
    │   │   ├── loyalty_page.dart       # Fidelidade
    │   │   └── products_page.dart      # Produtos
    │   ├── notifications/
    │   │   └── notifications_page.dart # Central de avisos
    │   ├── profile/
    │   │   └── profile_page.dart       # Perfil + infos da barbearia
    │   └── splash/
    │       └── splash_tela.dart        # Tela de carregamento inicial
    ├── services/
    │   └── notification_service.dart   # Serviço de notificações locais
    ├── firebase_options.dart            # Configuração Firebase
    └── main.dart                       # Entry point + rotas
```

---

## 🔥 Banco de Dados — Estrutura Firestore

```
firestore/
├── users/
│   └── {userId}/                  # Dados do cliente (nome, telefone)
├── bookings/
│   └── {bookingId}/               # Agendamentos
│       ├── userId: string
│       ├── service: string
│       ├── barber: string
│       ├── date: string           # "YYYY-MM-DD"
│       ├── time: string           # "HH:MM"
│       ├── status: string         # confirmado | cancelado
│       └── createdAt: timestamp
└── notifications/
    └── {userId}/
        └── items/
            └── {itemId}/          # Notificações do cliente
                ├── type: string   # booking | promo | info
                ├── titulo: string
                ├── msg: string
                ├── lida: bool
                └── createdAt: timestamp
```

---

## 🔐 Regras de Segurança do Firestore

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }

    match /bookings/{bookingId} {
      allow read, update, delete: if request.auth != null
                                  && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }

    match /notifications/{userId}/items/{itemId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## 🚀 Como rodar o projeto

### Pré-requisitos

- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0`
- Conta no [Firebase Console](https://console.firebase.google.com)
- Android Studio ou VS Code com extensão Flutter

### Configuração

```bash
# 1. Clone o repositório
git clone https://github.com/SantosGAlves/barbu_barbearia.git
cd barbu_barbearia/Tela_Home_Inicial

# 2. Instale as dependências
flutter pub get

# 3. Configure o Firebase
# - Crie um projeto no Firebase Console
# - Ative Authentication (E-mail/Senha) e Firestore
# - Baixe o google-services.json e coloque em android/app/
# - Atualize lib/firebase_options.dart com suas chaves

# 4. Rode o app
flutter run                          # dispositivo conectado
flutter run -d chrome --web-port 8080  # navegador web
```

---

## 📦 Dependências Principais

| Pacote | Versão | Finalidade |
|---|---|---|
| `cloud_firestore` | ^6.5.0 | Banco de dados em tempo real |
| `firebase_auth` | ^6.5.2 | Autenticação de usuários |
| `firebase_core` | ^4.10.0 | Core do Firebase |
| `flutter_local_notifications` | ^18.0.1 | Lembretes locais agendados |
| `timezone` | ^0.9.4 | Suporte a fusos horários |
| `url_launcher` | ^6.3.1 | Links externos (WhatsApp, Maps, Instagram) |
| `intl` | ^0.20.2 | Formatação de datas |
| `flutter_native_splash` | ^2.4.7 | Tela de splash nativa |

---

## 👥 Equipe

| Membro | Branch |
|---|---|
| Henrique | `branch_rique` |
| Santos G. Alves | `main` |

---

## 📄 Licença

Este projeto é um protótipo acadêmico/pessoal. Todos os direitos reservados à equipe.
