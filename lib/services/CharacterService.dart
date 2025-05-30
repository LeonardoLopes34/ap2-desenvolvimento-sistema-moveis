import 'dart:convert';
import 'package:ap2/models/Character.dart';
import 'package:http/http.dart' as http;
import 'package:ap2/Constants.dart';

class CharacterService {
  Future<List<Character>> getCharacters({int page = 1, int limit = 20}) async {
    final String url = '$BASE_URL/characters?page=$page&limit=$limit';

    final http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (e) {
      throw Exception('Network error while fetching data for page $page: $e');
    }

    if (response.statusCode == 200) {
      try {
        // Decodifica o corpo da resposta
        final dynamic decodedBody = json.decode(response.body);
        print('CharacterService (page $page): Decoded body type: ${decodedBody.runtimeType}');
        // Verifica se o corpo decodificado é um Map (objeto JSON)
        if (decodedBody is Map<String, dynamic>) {
          final Map<String, dynamic> jsonResponse = decodedBody;
          // Verifica se a chave 'characters' existe e se seu valor é uma Lista
          if (jsonResponse.containsKey('characters') && jsonResponse['characters'] is List) {
            final List charactersData = jsonResponse['characters'];
            print('CharacterService (page $page): "characters" key found and is a List. Length: ${charactersData.length}');
            if (charactersData.isEmpty) {
              print('CharacterService (page $page): "characters" list is empty.');
              return []; // Retorna lista vazia se não houver personagens nesta página
            }
            // Mapeia os dados para objetos Character
            return charactersData.map((item) {
              if (item is Map<String, dynamic>) {
                return Character.fromJson(item);
              } else {
                print('CharacterService (page $page): ERROR - Item in "characters" list is not a Map. Item: $item, Type: ${item.runtimeType}');
                throw Exception('Invalid item format in "characters" list for page $page.');
              }
            }).toList();

          } else {
            String problem = "";
            if (!jsonResponse.containsKey('characters')) {
              problem = '"characters" key is missing.';
            } else {
              problem = '"characters" key is not a List, it is ${jsonResponse['characters'].runtimeType}.';
            }
            print('CharacterService (page $page): ERROR - $problem');
            print('CharacterService (page $page): Parsed JSON was: $jsonResponse');
            throw Exception('Invalid JSON structure from API for page $page ($problem)');
          }
        } else {
          // O corpo decodificado não é um Map (objeto JSON)
          print('CharacterService (page $page): ERROR - Decoded JSON is not a Map. Actual type: ${decodedBody.runtimeType}');
          print('CharacterService (page $page): Raw response body was: "${response.body}"');
          throw Exception('API did not return a valid JSON object for page $page.');
        }
      } catch (e) {
        // Erros durante json.decode, Character.fromJson ou as verificações de tipo
        print('CharacterService (page $page): ERROR parsing JSON or mapping to Character objects: $e');
        if (e is! Exception) { // Se não for uma Exception já lançada, logamos o corpo original
          print('CharacterService (page $page): Original problematic response body was: "${response.body}"');
        }
        throw Exception('Failed to parse API response or map data for page $page. Error: $e');
      }
    } else {
      // A API retornou um status code diferente de 200
      print('CharacterService (page $page): API request FAILED with status ${response.statusCode}.');
      print('CharacterService (page $page): Response body for error: "${response.body}"');
      throw Exception('API request failed for page $page. Status: ${response.statusCode}');
    }
  }
}