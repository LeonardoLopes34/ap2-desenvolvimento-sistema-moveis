// main.dart
import 'package:ap2/screens/CharacterDetailScreen.dart';
import 'package:ap2/services/CharacterService.dart';
import 'package:flutter/material.dart';
import 'models/Character.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget { // stateful para gerenciar estados, como lista, rolagem, busca, etc
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CharacterService service = CharacterService(); // variavel para acessar os dados da API
  late Future<List<Character>> _personagensFuture;
  List<Character> _personagens = []; // todos os personagens
  List<Character> _personagensFiltrados = []; // personagens depois de filtrar

  int _currentPage = 1; // paginacao e controle do scroll
  bool _isLoadingMore = false; // controlar se mais personagens estao sendo carregados
  final ScrollController _scrollController = ScrollController(); // scroll controller permite controler o comportamento de widgets rolaveis, para controlar o scroll
  bool _hasMoreCharacters = true;

  @override
  void initState() {
    super.initState();
    _personagensFuture = _getCharacters(page: _currentPage); // carrega a pagina 1 da API
    _scrollController.addListener(_onScroll); // add um listener para detectar scroll
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // remove o listener
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Character>> _getCharacters({required int page, bool loadMore = false}) async { // retornar a lista de personagens  com o numero da pagina, e um boolean para indicar se a chamada é para carregar mais personagens
    if (_isLoadingMore && loadMore) {
      return _personagens; // retorna a lista de personagens, caso retorner true nos booleans de loading
    }
    if (loadMore && !_hasMoreCharacters) { // verifica se a chamada é para retornar mais personagens
      if (_isLoadingMore && mounted) {
        setState(() { // para reconstruir a UI
          _isLoadingMore = false;
        });
      }
      return _personagens; // retorna a lista atual
    }

    if (loadMore) {
      if(mounted) { // verificar se o widget esta montado
        setState(() {
          _isLoadingMore = true; // indicar que o carregamento esta em andamento
        });
      }
    }

    try {
      List<Character> fetchedCharacters = await service.getCharacters(page: page); // tenta chamar o metodo para retornar a lista de personagens
      if (!mounted) return _personagens; // verifica se o widget esta montado, para evitar chamar a UI

      if (loadMore && fetchedCharacters.isEmpty) { // verifica se estava carregando mais, mas a API retornou uma lista vazia
        if (mounted) {
          setState(() {
            _hasMoreCharacters = false; // define que nao ha mais personagens para carregar
            _isLoadingMore = false; // define o indicador de carregamento
          });
        }
        return _personagens;
      }
      if (!loadMore && fetchedCharacters.isEmpty) {
        if (mounted) {
          setState(() {
            _hasMoreCharacters = false;
          });
        }
      }

      final int previousCount = _personagens.length;

      if (mounted) {
        setState(() {
          if (loadMore) { // verifica se estava carregando
            _personagens.addAll(fetchedCharacters); // adiciona os novos personagens a lista de personagens
          } else {
            _personagens = fetchedCharacters; // se nao estava carregando, substitui a lista de personagens pelos personagens buscados
          }
          _applyFilterToList(); // aplica o filtro da lista
        });
      }
      return _personagens;
    } catch (e) {
      if (!mounted) return _personagens; // verifica se o widget nao esta montado, para retornar a lista de personagens

      if (loadMore && mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao carregar mais personagens: ${e.toString()}'), backgroundColor: Colors.red) // erro caso estava carregando mais e a UI ja estava montada (snackBar é uma mensagem temporaria)
          );
        } catch (smError) {
          print("Erro ao mostrar SnackBar: $smError. Contexto pode não ter ScaffoldMessenger.");
        }
      }
      rethrow; // relanca o erro original para o futurebuilder mostrar na UI
    } finally {
      if (loadMore && _isLoadingMore && mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }
  String _currentFilter = "";
  void _applyFilterToList() { // funcao para o filtro de busca
    if(!mounted) return;
    setState(() {
      if (_currentFilter.isEmpty) { // se a lista é vazia, copia todos os personagens da lista original
        _personagensFiltrados = List.from(_personagens);
      } else {
        _personagensFiltrados = _personagens
            .where((item) =>
            item.name.toLowerCase().contains(_currentFilter.toLowerCase())) // se nao filtra a lista verificando cada personagem, e adicionar a lista filtrada
            .toList();
      }
    });
  }

  _filtroPersonagens(String filtro) { // chamada da funcao caso o texto do campo muda
    _currentFilter = filtro;
    _applyFilterToList();
  }

  void _onScroll() {
    if (_hasMoreCharacters &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && // funcao para verificar a posicao atual da rolagem, se esta perto do final da lista, com o maxScrollExtente que define o maximo que pode rolar a tela
        !_isLoadingMore) {
      _currentPage++; // atualiza a paga atual
      _getCharacters(page: _currentPage, loadMore: true); // chama a funcao para retornar os personagens da nova lista
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // widget principal
      title: 'Naruto Characters',
      theme: ThemeData( // tema visual do app
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.black87,
          )),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Personagens de Naruto"),
        ),
        body: Column( // organizar os elementos verticalmente
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) { // chama a funcao de filtro toda vez que o campo de filtro muda passando o novo valor
                  _filtroPersonagens(value);
                },
                decoration: InputDecoration( // estilos da barra de filtro
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: "Filtrar por nome",
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Ex: Naruto Uzumaki",
                ),
              ),
            ),
            Expanded( // para o futurebuilder ocupar o espacao disponivel
              child: FutureBuilder<List<Character>>( // widger para construir a UI baseado no estado mais recente
                future: _personagensFuture, // observa a chamada inicial para buscar personagens
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && // verifica se o future ainda esta em execucao e se a lista de personagens esta vazia
                      _personagens.isEmpty) {
                    return const Center(child: CircularProgressIndicator()); // mostra um indicador de progressao
                  }

                  if (snapshot.hasError && _personagens.isEmpty) { // verifica se o future resultou em um erro
                    return Center(
                        child: Text(
                          "Erro ao carregar personagens: ${snapshot.error.toString()}", // retorna uma mensagem de erro
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ));
                  }

                  if (_personagensFiltrados.isEmpty && _currentFilter.isNotEmpty) { // verifica se a lista filtrada esta vazia e o filtro foi aplicado
                    return const Center(
                        child: Text("Nenhum personagem corresponde ao filtro.")); // retorna uma mensagem informando que nenhum personagem corresponde ao filtro
                  }

                  if (_personagens.isEmpty && snapshot.connectionState != ConnectionState.waiting) { // verifica se a lista inicial esta vazia e o future nao esta mais esperando
                    return const Center(
                        child: Text("Nenhum personagem encontrado."));
                  }

                  if (_personagensFiltrados.isEmpty && _isLoadingMore) { // verifica se a lista filtrada esta vazia e se o app esta carregando mais
                    return const Center(child: CircularProgressIndicator()); // indicador de progresso se a lista está vazia mas carregando mais
                  }

                  return ListView.separated( // retorna uma lista que permite adicionar separadores, caso nenhum condicao for atentida
                    controller: _scrollController, // associa o scrollcontroller a lista
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    itemBuilder: (context, index) { // funcao para construir cada item da lista
                      if (index == _personagensFiltrados.length) { // verifica se o index atual é igual ao tamanho da lista, para o indicador de carrengado mais
                        return _isLoadingMore
                            ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ))
                            : const SizedBox.shrink(); // nao mostra nada se nao estiver carregando mais
                      }
                      // Personagem normal
                      final character = _personagensFiltrados[index]; // pega o personagem filtrado
                      return Card( // retorna cada item da lista como um card
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile( // widget para exibir linhas com texto
                          title: Text(character.name,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)), // titulo do card é o nome do personagem
                          subtitle:
                          Text(character.village ?? 'Vila desconhecida'), // subtitulo do card, a vila do personagem
                          leading: Hero( // widget com animacao de transicao
                            tag: 'characterImage-${character.id}', // tag do hero para a animacao funcionar
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(character.image), // carrega a imagem do personagem
                              radius: 30,
                              onBackgroundImageError: (exception, stackTrace) {}, // funcao caso tenha erro ao carregar imagem
                              backgroundColor: Colors.grey[200],
                              child: character.image.contains('placeholder')
                                  ? const Icon(Icons.person_outline, // caso o card utilizar o placeholder, mostra um icone de pessoa
                                  color: Colors.grey)
                                  : null,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // indica que o item é clicavel
                          onTap: () { // funcao quando o listtitle é clicado
                            Navigator.push( // navega para a tela de detalhes do personagem
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CharacterDetailScreen(character: character),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) { // widget para construir um separador entre cada item
                      return const SizedBox(height: 0); // retorna um separador nao visivel, pois o margin de cada card ja cria um espacamento
                    },
                    itemCount: // definite o total de itens na listview
                    _personagensFiltrados.length + (_isLoadingMore && _hasMoreCharacters ? 1 : 0), // o numero de itens é o tamanho da lista filtrada
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}