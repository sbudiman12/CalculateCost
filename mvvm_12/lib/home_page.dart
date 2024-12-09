import 'package:flutter/material.dart';
import 'package:mvvm_12/model/model.dart';
import 'package:mvvm_12/response/api_response.dart';
import 'package:mvvm_12/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'response/status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedOriginProvince;
  String? selectedOriginCityId;
  String? selectedDestinationProvince;
  String? selectedDestinationCityId;
  String? selectedCourier;
  String? weightInGrams;
  bool isLoading = false; // Track loading status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewmodel>(context, listen: false);
      homeViewModel.getProvinceList(); // Fetch province list on load
    });
  }

  // Check if all required fields are filled
  bool _isFormValid() {
    return selectedOriginProvince != null &&
        selectedOriginCityId != null &&
        selectedDestinationProvince != null &&
        selectedDestinationCityId != null &&
        selectedCourier != null &&
        weightInGrams != null &&
        weightInGrams!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalkulator Ongkir"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        // Wrap the body with Stack to overlay loading indicator
        children: [
          SingleChildScrollView(
            // The content is still scrollable
            child: Consumer<HomeViewmodel>(
              builder: (context, homeViewModel, _) {
                switch (homeViewModel.provinceList.status) {
                  case Status.loading:
                    return const Center(child: CircularProgressIndicator());
                  case Status.error:
                    return Center(
                        child: Text(homeViewModel.provinceList.message ??
                            'Error occurred'));
                  case Status.completed:
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropdown(
                            label: 'Provinsi Asal',
                            value: selectedOriginProvince,
                            onChanged: (newValue) {
                              setState(() {
                                selectedOriginProvince = newValue;
                                selectedOriginCityId = null;
                              });
                              final homeViewModel = Provider.of<HomeViewmodel>(
                                  context,
                                  listen: false);
                              final province = homeViewModel.provinceList.data
                                  ?.firstWhere((p) => p.province == newValue);
                              if (province != null) {
                                homeViewModel
                                    .getCityListForOrigin(province.provinceId!);
                              }
                            },
                            items: homeViewModel.provinceList.data!
                                .map((province) {
                              return DropdownMenuItem<String>(
                                value: province.province,
                                child: Text(province.province ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Kota Asal',
                            value: selectedOriginCityId,
                            onChanged: (newValue) {
                              setState(() {
                                selectedOriginCityId = newValue;
                              });
                            },
                            items: _getCitiesForOrigin(
                                homeViewModel.cityListForOrigin),
                            enabled: selectedOriginProvince != null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Provinsi Tujuan',
                            value: selectedDestinationProvince,
                            onChanged: (newValue) {
                              setState(() {
                                selectedDestinationProvince = newValue;
                                selectedDestinationCityId = null;
                              });
                              final homeViewModel = Provider.of<HomeViewmodel>(
                                  context,
                                  listen: false);
                              final province = homeViewModel.provinceList.data
                                  ?.firstWhere((p) => p.province == newValue);
                              if (province != null) {
                                homeViewModel.getCityListForDestination(
                                    province.provinceId!);
                              }
                            },
                            items: homeViewModel.provinceList.data!
                                .map((province) {
                              return DropdownMenuItem<String>(
                                value: province.province,
                                child: Text(province.province ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Kota Tujuan',
                            value: selectedDestinationCityId,
                            onChanged: (newValue) {
                              setState(() {
                                selectedDestinationCityId = newValue;
                              });
                            },
                            items: _getCitiesForDestination(
                                homeViewModel.cityListForDestination),
                            enabled: selectedDestinationProvince != null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Jasa Ongkir',
                            value: selectedCourier,
                            onChanged: (newValue) {
                              setState(() {
                                selectedCourier = newValue;
                              });
                            },
                            items: [
                              'jne',
                              'tiki',
                              'pos',
                            ].map((courier) {
                              return DropdownMenuItem<String>(
                                value: courier,
                                child: Text(courier,
                                    style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Berat (gram)',
                              labelStyle: const TextStyle(
                                  color: Colors.deepPurple, fontSize: 16),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 17, 17, 17),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            onChanged: (value) {
                              setState(() {
                                weightInGrams = value;
                              });
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
  onPressed: _isFormValid()
      ? () {
          setState(() {
            isLoading = true; // Set loading state to true when submitting
          });
          final homeViewModel =
              Provider.of<HomeViewmodel>(context, listen: false);
          homeViewModel
              .getShippingCost(
                  selectedOriginCityId!,
                  selectedDestinationCityId!,
                  weightInGrams!,
                  selectedCourier!)
              .then((_) {
            setState(() {
              isLoading = false; // Set loading state to false once the request is complete
            });
          });
        }
      : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    padding: const EdgeInsets.symmetric(
        vertical: 16.0, horizontal: 40.0), // Add sufficient padding
    textStyle: const TextStyle(fontSize: 16), // Consistent font size
  ),
  child: isLoading
      ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
      : const Text(
          'Kirim',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
),


                          const SizedBox(height: 32),
                          if (homeViewModel.shippingCostList.status ==
                              Status.loading)
                            if (homeViewModel.shippingCostList.status ==
                                Status.error)
                              Center(
                                  child: Text(
                                      homeViewModel.shippingCostList.message ??
                                          'Error occurred')),
                          if (homeViewModel.shippingCostList.status ==
                              Status.completed)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daftar Ongkir:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...homeViewModel.shippingCostList.data!
                                    .map((cost) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Service: ${cost.service ?? 'Unknown'}',
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          Text('Value: Rp ${cost.value}',
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          Text('ETD: ${cost.etd ?? 'Unknown'}',
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                        ],
                      ),
                    );
                  default:
                    return const Center(child: Text('Unknown State'));
                }
              },
            ),
          ),
          if (isLoading) // Overlay loading indicator when isLoading is true
            IgnorePointer(
              // Prevent user interactions when loading
              ignoring: true,
              child: Container(
                color: Colors.white
                    .withOpacity(0.5), // Semi-transparent background
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dropdown widget to reduce redundancy
  Widget _buildDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<DropdownMenuItem<String>> items,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: enabled ? onChanged : null,
      items: items,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurple, fontSize: 16),
        filled: true,
        fillColor: const Color.fromARGB(255, 17, 17, 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  // Fetch cities for origin
  List<DropdownMenuItem<String>> _getCitiesForOrigin(
      ApiResponse<List<City>> cityResponse) {
    if (cityResponse.status == Status.loading &&
        selectedOriginProvince != null) {
      // Menampilkan indikator loading ketika data sedang dimuat
      return [
        const DropdownMenuItem<String>(
          value: null,
          child: Row(
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
      ];
    }

    if (cityResponse.status == Status.completed) {
      // Jika statusnya completed, menampilkan data kota yang sudah dimuat
      if (cityResponse.data?.isEmpty ?? true) {
        // Jika data kota kosong, tampilkan pesan 'Isi Provinsi Dahulu'
        return [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('dwajfhaiuga', style: TextStyle(fontSize: 16)),
          ),
        ];
      }

      // Menampilkan daftar kota jika data ada
      return cityResponse.data?.map((city) {
            return DropdownMenuItem<String>(
              value: city.cityId.toString(),
              child: Text(city.cityName ?? '',
                  style: const TextStyle(fontSize: 16)),
            );
          }).toList() ??
          [];
    }

    // Menampilkan pesan 'No cities available' jika ada masalah memuat data
    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Pilih Provinsi Asal', style: TextStyle(fontSize: 16)),
      ),
    ];
  }

  // Fetch cities for destination
  List<DropdownMenuItem<String>> _getCitiesForDestination(
      ApiResponse<List<City>> cityResponse) {
    if (cityResponse.status == Status.loading &&
        selectedDestinationProvince != null) {
      return [
        const DropdownMenuItem<String>(
          value: null,
          child: Row(
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
              SizedBox(width: 8),
            ],
          ),
        )
      ];
    }

    if (cityResponse.status == Status.completed) {
      return cityResponse.data?.map((city) {
            return DropdownMenuItem<String>(
              value: city.cityId.toString(),
              child: Text(city.cityName ?? '',
                  style: const TextStyle(fontSize: 16)),
            );
          }).toList() ??
          [];
    }

    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Pilih Provinsi Tujuan', style: TextStyle(fontSize: 16)),
      ),
    ];
  }
}
