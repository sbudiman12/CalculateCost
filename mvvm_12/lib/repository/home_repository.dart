import 'package:mvvm_12/model/costs/cost.dart';
import 'package:mvvm_12/model/model.dart';
import 'package:mvvm_12/network/network_api_services.dart';

class HomeRepository {
  final _apiServices = NetworkApiServices();

  // Fungsi untuk fetch daftar provinsi
  Future<List<Province>> fetchProvinceList() async {
    try {
      dynamic response = await _apiServices.getApiResponse('/starter/province');
      List<Province> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        result = (response['rajaongkir']['results'] as List)
            .map((e) => Province.fromJson(e))
            .toList();
      } else {
        print('Error: ${response['rajaongkir']['status']['description']}');
      }
      return result;
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to fetch province list');
    }
  }

  // Fungsi untuk fetch daftar kota berdasarkan provinsi
  Future<List<City>> fetchCityList(String provinceId) async {
    try {
      final Map<String, String> queryParams = {
        'province': provinceId,  // Menambahkan parameter province
      };

      dynamic response = await _apiServices.getApiResponse('/starter/city', queryParams: queryParams);
      List<City> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        result = (response['rajaongkir']['results'] as List)
            .map((e) => City.fromJson(e))
            .toList();
      } else {
        print('Error: ${response['rajaongkir']['status']['description']}');
      }
      return result;
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to fetch city list');
    }
  }

  // Fungsi untuk mengirim data dan mendapatkan biaya pengiriman
  Future<List<Cost>> postShippingData(String origin, String destination, String weight, String courier) async {
    try {
      // Data yang akan dikirim dalam body POST request
      Map<String, String> data = {
        'origin': origin,
        'destination': destination,
        'weight': weight,
        'courier': courier,
      };

      // Mengirim data POST dan menerima respons
      dynamic response = await _apiServices.postApiResponse('/starter/cost', data);

      // Debugging response
      print('Response: $response');

      List<Cost> costList = [];

      // Mengecek jika status code adalah 200 (sukses)
      if (response['rajaongkir']['status']['code'] == 200) {
        var results = response['rajaongkir']['results'];
        if (results != null && results.isNotEmpty) {
          print('Results: $results'); // Cetak bagian results
          // Memproses biaya (cost) untuk setiap layanan yang tersedia
          for (var result in results) {
            var costs = result['costs'];
            if (costs != null) {
              print('Costs: $costs');
              // Peta data costs menjadi List<Cost>
              costList.addAll(costs.map<Cost>((cost) => Cost.fromJson(cost)).toList());
            } else {
              print('No costs data available for this result');
            }
          }
        } else {
          print('No results found');
        }
      } else {
        print('Error: ${response['rajaongkir']['status']['description']}');
      }

      return costList; // Mengembalikan List<Cost>
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('No Service For This Parameter');
    }
  }
}
