import 'package:flutter/material.dart';
import 'package:mvvm_12/model/costs/cost.dart';
import 'package:mvvm_12/model/model.dart';
import 'package:mvvm_12/repository/home_repository.dart';
import 'package:mvvm_12/response/api_response.dart';

class HomeViewmodel with ChangeNotifier {
  final _homeRepo = HomeRepository();

  // State untuk Provinsi
  ApiResponse<List<Province>> provinceList = ApiResponse.loading();

  // State untuk Kota Asal
  ApiResponse<List<City>> cityListForOrigin = ApiResponse.loading();

  // State untuk Kota Tujuan
  ApiResponse<List<City>> cityListForDestination = ApiResponse.loading();

  // State untuk biaya pengiriman (hasil dari POST)
  ApiResponse<List<Cost>> shippingCostList = ApiResponse.loading();

  // Set state untuk provinsi
  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners(); // Memberitahukan perubahan ke UI
  }

  // Ambil daftar provinsi dari repository
  Future<void> getProvinceList() async {
    setProvinceList(ApiResponse.loading()); // Set state loading saat request dilakukan
    _homeRepo.fetchProvinceList().then((value) {
      setProvinceList(ApiResponse.completed(value)); // Set state completed setelah data diterima
    }).onError((error, stackTrace) {
      setProvinceList(ApiResponse.error(error.toString())); // Set state error jika terjadi kesalahan
    });
  }

  // Set state untuk kota asal
  setCityListForOrigin(ApiResponse<List<City>> response) {
    cityListForOrigin = response;
    notifyListeners(); // Memberitahukan perubahan ke UI
  }

  // Ambil daftar kota untuk asal berdasarkan provinsi
  Future<void> getCityListForOrigin(String provinceId) async {
    setCityListForOrigin(ApiResponse.loading()); // Set state loading saat request dilakukan
    _homeRepo.fetchCityList(provinceId).then((value) {
      setCityListForOrigin(ApiResponse.completed(value)); // Set state completed setelah data diterima
    }).catchError((error) {
      setCityListForOrigin(ApiResponse.error(error.toString())); // Set state error jika terjadi kesalahan
    });
  }

  // Set state untuk kota tujuan
  setCityListForDestination(ApiResponse<List<City>> response) {
    cityListForDestination = response;
    notifyListeners(); // Memberitahukan perubahan ke UI
  }

  // Ambil daftar kota untuk tujuan berdasarkan provinsi
  Future<void> getCityListForDestination(String provinceId) async {
    setCityListForDestination(ApiResponse.loading()); // Set state loading saat request dilakukan
    _homeRepo.fetchCityList(provinceId).then((value) {
      setCityListForDestination(ApiResponse.completed(value)); // Set state completed setelah data diterima
    }).catchError((error) {
      setCityListForDestination(ApiResponse.error(error.toString())); // Set state error jika terjadi kesalahan
    });
  }

  // Set state untuk biaya pengiriman
  setShippingCostList(ApiResponse<List<Cost>> response) {
    shippingCostList = response;
    notifyListeners(); // Memberitahukan perubahan ke UI
  }

  // Ambil biaya pengiriman
  Future<void> getShippingCost(String origin, String destination, String weight, String courier) async {
    setShippingCostList(ApiResponse.loading()); // Set state loading saat request dilakukan
    _homeRepo.postShippingData(origin, destination, weight, courier).then((value) {
      setShippingCostList(ApiResponse.completed(value)); // Set state completed setelah data diterima
    }).onError((error, stackTrace) {
      setShippingCostList(ApiResponse.error(error.toString())); // Set state error jika terjadi kesalahan
    });
  }
}
