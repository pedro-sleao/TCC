import 'dart:convert';

import 'package:dashboard_flutter/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de HTTP para interações com a API.
///
/// Esta classe fornece métodos para realizar operações de rede, incluindo
/// login, logout, registro, e obtenção de dados de usuários e sensores. Ela
/// utiliza a biblioteca `http` para realizar requisições e `shared_preferences`
/// para armazenar e recuperar o token de autenticação.
class HttpService {
  final baseUrl = ipAddress;

  /// Recupera os dados do usuário autenticado.
  ///
  /// Faz uma requisição GET para o endpoint `/usuario` com o token de autenticação
  /// armazenado. Se o token for válido e a requisição for bem-sucedida, retorna
  /// um mapa com os dados do usuário e o token. Caso contrário, lança uma exceção.
  Future<Map<String, dynamic>> fetchUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? accessToken = prefs.getString('jwt');

      if (accessToken != null) {
        final String apiUrl = 'http://$baseUrl:5000/usuario';
        final response = await http.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $accessToken',
        });

        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = jsonDecode(response.body);
          responseBody['access_token'] = accessToken;
          return responseBody;
        } else {
          throw Exception('Erro na requisição: ${response.statusCode}');
        }
      }
      throw Exception('Login expirado');
    } catch (e) {
      throw Exception('Erro na conexão com o servidor: $e');
    }
  }

  /// Realiza o login do usuário.
  ///
  /// Faz uma requisição GET para o endpoint `/login` com credenciais básicas
  /// codificadas em Base64. Se o login for bem-sucedido, armazena o token de
  /// acesso e retorna os dados de resposta. Caso contrário, lança uma exceção.
  Future<Map<String, dynamic>> login(String username, String password) async { 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String apiUrl = 'http://$baseUrl:5000/login';

      String basicAuth =
          'Basic ${base64.encode(utf8.encode('$username:$password'))}';

      final response =
          await http.get(Uri.parse(apiUrl), headers: <String, String>{
        'authorization': basicAuth,
        'x-api-key': 'U2FsdGVkX1+/NFD9Q8L0gGIddIW+ULsOBvHi+LTQD3s='
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        prefs.setString('jwt', responseBody['access_token']);
        return responseBody;
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão com o servidor: $e');
    }
  }

  /// Realiza o logout do usuário.
  ///
  /// Remove o token de autenticação armazenado e retorna `false` para indicar
  /// sucesso. Se ocorrer um erro durante a operação, retorna `true`.
  Future<bool> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove('jwt');

      return false;
    } catch (e) {
      return true;
    }
  }

  /// Registra um novo usuário.
  ///
  /// Faz uma requisição POST para o endpoint `/usuarios/cadastro` com os dados
  /// do usuário. Se o registro for bem-sucedido, retorna os dados de resposta.
  /// Caso contrário, lança uma exceção.
  Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('jwt');

      final String apiUrl = 'http://$baseUrl:5000/usuarios/cadastro';

      final response = await http.post(Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(
              <String, String>{'username': username, 'password': password}));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Erro na requisição ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro na conexão com o servidor: ${e.toString()}");
    }
  }

  /// Obtém os dados dos locais.
  ///
  /// Faz uma requisição GET para o endpoint `/api/dados/placas` com parâmetros
  /// de consulta opcionais. Se a requisição for bem-sucedida, retorna os dados
  /// dos locais. Caso contrário, lança uma exceção.
  Future<List<dynamic>> fetchLocals([String queryParameters = '']) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final String? accessToken = prefs.getString('jwt');
      final String apiUrl =
          'http://$baseUrl:5000/api/dados/placas?$queryParameters';
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão com o servidor: $e');
    }
  }

  /// Obtém os dados dos sensores de um local específico.
  ///
  /// Faz uma requisição GET para o endpoint `/api/dados/local` com parâmetros
  /// de consulta para o local e dias passados. Se a requisição for bem-sucedida,
  /// retorna os dados dos sensores. Caso contrário, lança uma exceção.
  Future<Map<String, dynamic>> fetchSensorsData(
      String local, dynamic pastDays) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final String? accessToken = prefs.getString('jwt');
      final String apiUrl =
          'http://$baseUrl:5000/api/dados/local?local=$local${pastDays != '' ? '&dias_passados=$pastDays' : ''}';
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão com o servidor: $e');
    }
  }

  /// Obtém a lista de usuários.
  ///
  /// Faz uma requisição GET para o endpoint `/usuarios`. Se a requisição for
  /// bem-sucedida, retorna os dados dos usuários. Caso contrário, lança uma exceção.
  Future<Map<String, dynamic>> fecthUsers() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? accessToken = prefs.getString('jwt');
      final String apiUrl = 'http://$baseUrl:5000/usuarios';
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão com o servidor: $e');
    }
  }

  /// Deleta um usuário.
  ///
  /// Faz uma requisição DELETE para o endpoint `/usuarios/{username}`. Se a
  /// requisição for bem-sucedida, retorna os dados de resposta. Caso contrário,
  /// lança uma exceção.
  Future<Map<String, dynamic>> deleteUser(String username) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? accessToken = prefs.getString('jwt');
      final String apiUrl = 'http://$baseUrl:5000/usuarios/$username';
      final response = await http.delete(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão com o servidor: $e');
    }
  }

  /// Registra os dados de uma placa.
  ///
  /// Faz uma requisição POST para o endpoint `/api/dados/placas` com os dados de
  /// uma placa. Se a requisição for bem-sucedida, retorna os dados de resposta.
  /// Caso contrário, lança uma exceção.
  Future<Map<String, dynamic>> registerNodeData(
      String localName,
      String idPlaca,
      Map sensorStates) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? accessToken = prefs.getString('jwt');
      final String apiUrl = 'http://$baseUrl:5000/api/dados/placas';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'id_placa': idPlaca,
          'local': localName,
          'temperature': sensorStates['Temperatura'],
          'tds': sensorStates['TDS'],
          'turbidity': sensorStates['Turbidez'],
          'ph': sensorStates['pH'],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Erro na requisição ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro na conexão com o servidor: ${e.toString()}");
    }
  }
}
