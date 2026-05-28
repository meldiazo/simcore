import 'dart:convert';
import 'package:http/http.dart' as http;

class ModuleProgressRemoteDatasource {
  final String baseUrl = 'https://simcore-production.up.railway.app/api/v1/simulation/companies';

  Future<Map<String, dynamic>> patchModuleAction(String companyId, String module, String action) async {
    final url = Uri.parse('$baseUrl/$companyId/modules/$module/$action');
    
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return {}; 
    } else {
      throw Exception('Error en la acción $action para el módulo $module. Código: ${response.statusCode}');
    }
  }
}