# Check-in da AP2

Aplicativo desenvolvido em Flutter para geração de ingressos com QR Code e controle de check-in de participantes em um evento.

## Integrantes

- **Nome:** [Éduri Vinícius de Moraes Gonçalves]


## Objetivo

Desenvolver um aplicativo móvel que permita gerar ingressos identificados por QR Code, realizar a leitura dos códigos pela câmera e controlar a entrada dos participantes de um evento.

## Funcionalidades

- Cadastro do nome e e-mail do participante.
- Validação dos dados informados.
- Geração de ingresso com imagem, nome, e-mail e QR Code.
- Leitura de QR Codes utilizando a câmera.
- Confirmação de check-in para ingressos válidos.
- Identificação de ingressos já utilizados.
- Identificação de QR Codes inválidos.
- Contador de check-ins confirmados.
- Listagem dos participantes confirmados.

## Tecnologias utilizadas

- Flutter
- Dart
- `qr_flutter`: geração de QR Codes.
- `mobile_scanner`: leitura de QR Codes pela câmera.

## Formato do QR Code

O QR Code utiliza o seguinte formato:

`CHECKIN|nome|e-mail`

Exemplo:

`CHECKIN|Maria Silva|maria@email.com`

O aplicativo valida a estrutura do código e impede que o mesmo e-mail realize mais de um check-in durante a execução.

## Como executar o projeto

### Pré-requisitos

- Flutter SDK instalado.
- Android Studio configurado para Flutter.
- Dispositivo Android com câmera ou ambiente compatível.

### Passos

1. Clone ou baixe este repositório.
2. Abra a pasta do projeto no Android Studio.
3. Abra o terminal na pasta principal do projeto.
4. Execute:

   ```bash
   flutter pub get
   ```

5. Inicie o aplicativo com:

   ```bash
   flutter run
   ```

Para testar a leitura dos ingressos, permita o acesso à câmera quando solicitado.

## Capturas de tela

Acesse a pasta biblioteca navegue até a pasta prints. 

*camera_captura.png
*check_ja_realizado.png
*confirmacao_participante.png
*gerando_participante.png
*qrcode_invalido.png
*qrcode_participante_gerado.png
*tela_check.png

Foram testados os seguintes cenários:

- **Ingresso válido:** check-in confirmado e participante adicionado à lista.
- **Ingresso repetido:** aviso de que o participante já realizou o check-in.
- **QR Code inválido:** mensagem informando que o código é inválido.

## Armazenamento dos dados

Os participantes são armazenados em memória durante a execução do aplicativo. Não há persistência em banco de dados; os dados podem ser perdidos quando o aplicativo é reiniciado.

## Considerações finais

O projeto permitiu aplicar conceitos de desenvolvimento mobile com Flutter, gerenciamento de estado, validação de dados, geração e leitura de QR Codes e implementação de regras para controle de check-in.
