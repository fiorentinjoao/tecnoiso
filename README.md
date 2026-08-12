# TecnoIso

App mobile (Flutter) para gestão de equipamentos de medição e calibração —
desenvolvido como Projeto Extensionista (PEX) do curso de Tecnologia em
Análise e Desenvolvimento de Sistemas, Centro Universitário Católica de
Santa Catarina, para uma empresa de calibração em Joinville/SC.

Ferramenta **interna** (não pública): cada técnico autentica com sua própria
conta para acompanhar o parque de equipamentos de cada cliente, prazos de
calibração e status (em dia / urgente / atrasado), conforme conformidade
ISO/IEC 17025.

## Funcionalidades

- **Autenticação local** — cadastro e login multiusuário, senha protegida
  com hash + salt, sem depender de backend.
- **Persistência real** — equipamentos armazenados localmente via Hive
  (CRUD completo: cadastrar, editar, excluir), substituindo os dados fixos
  da versão inicial.
- **Dashboard** — visão geral de equipamentos por status (em dia, urgente,
  atrasado) com estatísticas em tempo real.
- **Busca e filtros** — por nome, cliente, tipo, marca e status.
- **Detalhe do equipamento** — histórico de calibração, próxima calibração,
  edição e exclusão.
- **Clientes, agenda e notificações** — visão consolidada por cliente e
  alertas de calibrações pendentes.

## Stack

- [Flutter](https://flutter.dev) (SDK `^3.12.1`) / Dart
- [`hive_ce`](https://pub.dev/packages/hive_ce) — persistência local
- [`crypto`](https://pub.dev/packages/crypto) — hashing de senha (SHA-256 + salt)
- [`google_fonts`](https://pub.dev/packages/google_fonts) — tipografia (Inter)
- Tema dark customizado (`#09090B` / `#DC2626`)

## Rodando o projeto

```bash
flutter pub get
flutter run          # dispositivo/emulador conectado
flutter run -d linux # desktop Linux
```

## Testes

```bash
flutter analyze
flutter test
```

## Histórico do projeto

O relatório do PEX descreve o desenvolvimento completo (metodologia,
requisitos, wireframes, testes com usuários). A partir do feedback do
professor orientador — de que a ferramenta, sendo interna, precisava de
autenticação, e de que os dados exibidos eram fixos e precisavam de
persistência real — o app evoluiu de uma demo com dados mockados para uma
versão com login e armazenamento local funcionais (ver `.planning/` para o
histórico de decisões e planos de implementação).
