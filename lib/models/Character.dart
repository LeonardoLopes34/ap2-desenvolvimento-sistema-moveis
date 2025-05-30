class Character {
  final int id;
  final String name;
  final String image;
  final String? status;
  final String? village;
  final List<String> jutsu;

  const Character({
    required this.id,
    required this.name,
    required this.image,
    this.status,
    this.village,
    required this.jutsu,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    String mainImage = 'https://via.placeholder.com/150?text=No+Image'; // imagem placeholder caso o personagem nao possui imagem
    if (json['images'] != null) {
      if (json['images'] is List && (json['images'] as List).isNotEmpty) {
        var firstImage = (json['images'] as List).first;
        if (firstImage is String) {
          mainImage = firstImage;
        }
      } else if (json['images'] is String) {
        mainImage = json['images'] as String;
      }
    }

    String? currentStatus;
    String? mainAffiliation;

    if (json['personal'] != null && json['personal'] is Map<String, dynamic>) { // extrai dados da lista 'personal' como status, affilitaion
      final personalData = json['personal'] as Map<String, dynamic>;
      currentStatus = personalData['status'] as String?;
      if (personalData['affiliation'] != null) {
        if (personalData['affiliation'] is List && (personalData['affiliation'] as List).isNotEmpty) {
          var firstAffiliation = (personalData['affiliation'] as List).first;
          if (firstAffiliation is String) {
            mainAffiliation = firstAffiliation;
          }
        } else if (personalData['affiliation'] is String) {
          mainAffiliation = personalData['affiliation'] as String;
        }
      }
    }
    List<String> jutsuList = []; // converte a lista de jutsus para uma lista de strings
    if (json['jutsu'] != null) {
      if (json['jutsu'] is List) {
        try {
          jutsuList = (json['jutsu'] as List).map((j) {
            if (j is String) {
              return j;
            } else if (j != null) {
              return j.toString();
            }
            return "";
          }).where((s) => s.isNotEmpty).toList();
        } catch (e) {
          jutsuList = [];
        }
      } else if (json['jutsu'] is String) {
        jutsuList.add(json['jutsu'] as String);
      }
    }
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      image: mainImage,
      status: currentStatus,
      village: mainAffiliation,
      jutsu: jutsuList,
    );
  }
}