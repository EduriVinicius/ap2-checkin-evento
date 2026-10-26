
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Check-in da AP2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        scaffoldBackgroundColor: Colors.green.shade50,
        useMaterial3: true,
      ),
      home: const PaginaCheckin(),
    );
  }
}

class PaginaCheckin extends StatefulWidget {
  const PaginaCheckin({super.key});

  @override
  State<PaginaCheckin> createState() => _PaginaCheckinState();
}

class _PaginaCheckinState extends State<PaginaCheckin> {
  final TextEditingController nomeController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  bool nomePreenchido = false;
  bool lendoIngresso = false;
  bool processandoLeitura = false;

  String nomeConfirmado = '';
  String emailConfirmado = '';

  // E-mails e nomes dos participantes que fizeram check-in.
  final List<String> participantesConfirmados = [];
  final List<String> nomesParticipantes = [];

  // Verifica se o e-mail possui um formato válido.
  bool emailValido(String email) {
    return RegExp(
      r'^[^@\s|]+@[^@\s|]+\.[^@\s|]+$',
    ).hasMatch(email.trim());
  }

  // Exibe mensagens na tela.
  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
  }

  // Gera o ingresso depois de validar os campos.
  void gerarIngresso() {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();

    if (nome.isEmpty) {
      mostrarMensagem('✖ Informe o nome do participante.');
      return;
    }

    if (!emailValido(email)) {
      mostrarMensagem('✖ Informe um e-mail válido.');
      return;
    }

    setState(() {
      nomeConfirmado = nome;
      emailConfirmado = email;
      nomePreenchido = false;
    });

    nomeController.clear();
    emailController.clear();
  }

  // Inicia a leitura do QR Code.
  void iniciarLeitura() {
    setState(() {
      lendoIngresso = true;
      processandoLeitura = false;
    });
  }

  // Cancela a leitura e volta ao formulário.
  void cancelarLeitura() {
    setState(() {
      lendoIngresso = false;
      processandoLeitura = false;
    });
  }

  // Valida e processa o QR Code lido pela câmera.
  void processarQRCode(BarcodeCapture captura) {
    if (!lendoIngresso || processandoLeitura) {
      return;
    }

    if (captura.barcodes.isEmpty) {
      return;
    }

    final conteudo = captura.barcodes.first.rawValue;

    if (conteudo == null) {
      return;
    }

    // Bloqueia novas leituras durante o processamento.
    processandoLeitura = true;

    final partes = conteudo.split('|');

    // O QR precisa seguir exatamente:
    // CHECKIN|nome|e-mail
    final formatoValido =
        partes.length == 3 &&
            partes[0] == 'CHECKIN' &&
            partes[1].trim().isNotEmpty &&
            emailValido(partes[2]);

    if (!formatoValido) {
      setState(() {
        lendoIngresso = false;
      });

      mostrarMensagem('✖ QR Code inválido!');
      return;
    }

    final nome = partes[1].trim();
    final email = partes[2].trim().toLowerCase();

    // Compara os e-mails sem diferenciar maiúsculas
    // e minúsculas.
    if (participantesConfirmados.contains(email)) {
      setState(() {
        lendoIngresso = false;
      });

      mostrarMensagem(
        '⚠ Este participante já realizou o check-in!',
      );
      return;
    }

    // Registra o participante confirmado.
    setState(() {
      participantesConfirmados.add(email);
      nomesParticipantes.add(nome);
      lendoIngresso = false;
    });

    mostrarMensagem('✔ Check-in confirmado para $nome!');
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in da AP2'),
        backgroundColor: Colors.green.shade200,
      ),

      body: lendoIngresso
          ? Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aponte a câmera para o QR Code do ingresso.',
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: MobileScanner(
              onDetect: processarQRCode,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: cancelarLeitura,
              child: const Text('Cancelar'),
            ),
          ),
        ],
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo do nome.
            TextField(
              controller: nomeController,
              onChanged: (valor) {
                setState(() {
                  nomePreenchido =
                      valor.trim().isNotEmpty;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Nome do participante',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Campo do e-mail.
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail do participante',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Botão azul-claro: gerar ingresso.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade200,
                foregroundColor: Colors.black,
              ),
              onPressed:
              nomePreenchido ? gerarIngresso : null,
              child: const Text('Gerar Ingresso'),
            ),

            const SizedBox(height: 8),

            // Botão verde: ler ingresso.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: iniciarLeitura,
              child: const Text('Ler ingresso'),
            ),

            const SizedBox(height: 16),

            // Área rolável com contador, lista e ingresso.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    // Contador de check-ins.
                    Text(
                      'Participantes confirmados: '
                          '${participantesConfirmados.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Lista de participantes.
                    if (nomesParticipantes.isNotEmpty) ...[
                      const Text(
                        'Participantes:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ...nomesParticipantes.map(
                            (nome) => Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            nome,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Cartão do ingresso gerado.
                    if (nomeConfirmado.isNotEmpty)
                      Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Imagem do evento.
                              Image.network(
                                'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=900&q=80',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                    ) {
                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return const SizedBox(
                                    height: 160,
                                    child: Center(
                                      child:
                                      CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return const SizedBox(
                                    height: 160,
                                    child: Center(
                                      child: Icon(
                                        Icons.computer,
                                        size: 64,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              Text(
                                nomeConfirmado,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(emailConfirmado),

                              const SizedBox(height: 16),

                              // QR Code no formato exigido.
                              QrImageView(
                                data:
                                'CHECKIN|$nomeConfirmado|$emailConfirmado',
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


