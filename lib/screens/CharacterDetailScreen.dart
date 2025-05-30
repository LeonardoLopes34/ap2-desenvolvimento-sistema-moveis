import 'package:flutter/material.dart';

import '../models/Character.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // estrutura basica para appBar
      appBar: AppBar(
        title: Text(character.name), // exbibe o nome do personagem na barra superior
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView( // permite rolagem da tela
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Hero( // animacao de transicao de uma tela para outra
                tag: 'characterImage-${character.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network( // carrega a imagem
                    character.image,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow("Name:", character.name),
            _buildDetailRow("Status:", character.status ?? "Não informado"), // cade detalhe do personagem é exibido em linhas
            _buildDetailRow("Vila principal:", character.village ?? "Não informado"),
            _buildDetailRow("Nº de Jutsus: ", character.jutsu.length.toString()),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) { // widger personalizado para exibir o personagem, usando expanded para evitar overflow de texto
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}