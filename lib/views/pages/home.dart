part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Costs> calculatedCosts = [];
  bool dataReady = false;
  bool isFirstLoad = true;
  bool isLoading = false;
  bool isLoadingCityOrigin = false;
  bool isLoadingCityDestination = false;
  dynamic selectedProvinceOrigin;
  dynamic provinceData;
  dynamic selectedProvinceDestination;
  dynamic cityDataOrigin;
  dynamic cityIdOrigin;
  dynamic cityDataDestination;
  dynamic cityIdDestination;
  dynamic selectedCityOrigin;
  dynamic selectedCityDestination;
  dynamic selectedCourier;
  dynamic weight;
  // dynamic calculatedCosts;
  dynamic dataLength;

  TextEditingController weightTextController = TextEditingController();

  Future<List<Province>> getProvinces() async {
    dynamic prov;
    await MasterDataService.getProvince().then((value) {
      setState(() {
        prov = value;
        isLoading = false;
      });
    });
    return prov;
  }

  Future<List<City>> getCities(var provId) async {
    dynamic city;
    await MasterDataService.getCity(provId).then((value) {
      setState(() {
        city = value;
      });
    });
    return city;
  }

  Future<List<Costs>> getCosts(
      var originId, var destinationId, var weight, var courier) async {
    try {
      List<Costs> costs = await MasterDataService.getCosts(
        originId,
        destinationId,
        weight,
        courier,
      );
      // print(costs);
      return costs;
    } catch (error) {
      // Handle error, misalnya dengan menampilkan pesan atau melakukan logging
      print('Error fetching costs: $error');
      return []; // Atau return nilai default jika terjadi error
    }
  }

  @override
  void initState() {
    super.initState();
    getProvinces();
    setState(() {
      isLoading = true;
    });

    provinceData = getProvinces();

    // selectedProvinceOrigin = provinceDataOrigin['1'].province;
    // selectedProvinceDestination = provinceDataOrigin['1'].province;
    // for(Province p in provinceData){
    //   if(p.province == 'Kepulauan Riau'){
    //     selectedProvinceOrigin = p.province;
    //     selectedCityDestination = p.province;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Hitung Ongkir",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      //START ROW COURIER
                      // ROW COURIER
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: DropdownButton<String>(
                                value: selectedCourier,
                                hint: selectedCourier == null
                                    ? Text("Pilih Jasa")
                                    : Text(selectedCourier),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCourier = newValue!;
                                  });
                                },
                                items: <String>['JNE', 'TIKI', 'POS']
                                    .map<DropdownMenuItem<String>>(
                                        (String newValue) {
                                  return DropdownMenuItem<String>(
                                    value: newValue.toLowerCase(),
                                    child: Text(newValue),
                                  );
                                }).toList(),
                              )),
                          // Spacer(flex: 1),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                              child: TextField(
                                controller: weightTextController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Berat (gr)',
                                    labelStyle:
                                        TextStyle(color: Colors.grey.shade500)),
                              ),
                            ),
                          )
                        ],
                      ),
                      // End Row COURIER
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Origin",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )),
                      //START ROW ORIGIN
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: FutureBuilder<List<Province>>(
                              future: provinceData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  // isi dengan dropdown button
                                  return DropdownButton(
                                      isExpanded: true,
                                      value: selectedProvinceOrigin,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      style: TextStyle(color: Colors.black),
                                      hint: selectedProvinceOrigin == null
                                          ? Text("Pilih Provinsi")
                                          : Text(
                                              selectedProvinceOrigin.province),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<Province>>(
                                              (Province value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                                value.province.toString()));
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCityOrigin = null;
                                          selectedProvinceOrigin = newValue;
                                          isLoadingCityOrigin = true;
                                          cityDataOrigin = getCities(
                                              selectedProvinceOrigin.provinceId
                                                  .toString());
                                          isLoadingCityOrigin = false;
                                        });
                                      });
                                } else if (snapshot.hasError) {
                                  return Text("Tidak ada data");
                                }
                                return UiLoading.loadingSmall();
                              },
                            ),
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            flex: 3,
                            child: FutureBuilder<List<City>>(
                              future: cityDataOrigin,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    isLoadingCityOrigin) {
                                  // Menampilkan loading indicator
                                  return UiLoading.loadingSmall();
                                }
                                if (snapshot.hasData) {
                                  // isi dengan dropdown button
                                  return DropdownButton(
                                      isExpanded: true,
                                      value: selectedCityOrigin,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      style: TextStyle(color: Colors.black),
                                      hint: selectedCityOrigin == null
                                          ? Text("Pilih kota")
                                          : Text(selectedCityOrigin.cityName),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<City>>(
                                              (City value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                                value.cityName.toString()));
                                      }).toList(),
                                      onChanged: (newValue) {
                                        // UiLoading.loadingSmall();
                                        setState(() {
                                          selectedCityOrigin = newValue;
                                          cityIdOrigin =
                                              selectedCityOrigin.cityId;
                                        });
                                      });
                                } else if (snapshot.hasError) {
                                  return Text("Tidak ada data");
                                }
                                return DropdownButton(
                                  isExpanded: true,
                                  value: selectedCityOrigin,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 30,
                                  elevation: 4,
                                  style: TextStyle(color: Colors.black),
                                  items: [],
                                  onChanged: (value) {
                                    Null;
                                  },
                                  isDense: false,
                                  hint: Text('Select an item'),
                                  disabledHint: Text('Pilih kota'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // End Row ORIGIN
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Destination",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )),
                      // Start Row DESTINATION
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: FutureBuilder<List<Province>>(
                              future: provinceData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  // isi dengan dropdown button
                                  return DropdownButton(
                                      isExpanded: true,
                                      value: selectedProvinceDestination,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      style: TextStyle(color: Colors.black),
                                      hint: selectedProvinceDestination == null
                                          ? Text("Pilih Provinsi")
                                          : Text(selectedProvinceDestination
                                              .province),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<Province>>(
                                              (Province value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                                value.province.toString()));
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCityDestination = null;
                                          selectedProvinceDestination =
                                              newValue;
                                          isLoadingCityDestination = true;
                                          cityDataDestination = getCities(
                                              selectedProvinceDestination
                                                  .provinceId
                                                  .toString());
                                          isLoadingCityDestination = false;
                                        });
                                      });
                                } else if (snapshot.hasError) {
                                  return Text("Tidak ada data");
                                }
                                return UiLoading.loadingSmall();
                              },
                            ),
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            flex: 3,
                            child: FutureBuilder<List<City>>(
                              future: cityDataDestination,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    isLoadingCityOrigin) {
                                  // Menampilkan loading indicator
                                  return UiLoading.loadingSmall();
                                }
                                if (snapshot.hasData) {
                                  // isi dengan dropdown button
                                  return DropdownButton(
                                      isExpanded: true,
                                      value: selectedCityDestination,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      style: TextStyle(color: Colors.black),
                                      hint: selectedCityDestination == null
                                          ? Text("Pilih kota")
                                          : Text(
                                              selectedCityDestination.cityName),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<City>>(
                                              (City value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                                value.cityName.toString()));
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCityDestination = newValue;
                                          cityIdDestination =
                                              selectedCityDestination.cityId;
                                        });
                                      });
                                } else if (snapshot.hasError) {
                                  return Text("Tidak ada data");
                                }
                                return DropdownButton(
                                  isExpanded: true,
                                  value: selectedCityDestination,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 30,
                                  elevation: 4,
                                  style: TextStyle(color: Colors.black),
                                  items: [],
                                  onChanged: (value) {
                                    Null;
                                  },
                                  isDense: false,
                                  hint: Text('Select an item'),
                                  disabledHint: Text('Pilih kota'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Spacer(flex: 1),
                      // End Row DESTINATION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                onPressed: () async {
                                  setState(() {
                                    // dataReady = true;
                                    isLoading = true;
                                  });
                                  List<Costs> updatedCosts = await getCosts(
                                    selectedCityOrigin.cityId,
                                    selectedCityDestination.cityId,
                                    weightTextController.text,
                                    selectedCourier,
                                  );

                                  setState(() {
                                    calculatedCosts = updatedCosts;
                                    isLoading = false;
                                  });
                                },
                                child: Text(
                                  "Hitung Estimasi Harga",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: calculatedCosts.isEmpty
                        ? const Align(
                            alignment: Alignment.center,
                            child: Text("Data tidak ditemukan"),
                          )
                        : ListView.builder(
                            itemCount: calculatedCosts.length,
                            itemBuilder: (context, index) {
                              return CardCosts(calculatedCosts[index]);
                            },
                          )),
              ),
            ],
          ),
          isLoading == true ? UiLoading.loadingBlock() : Container(),
        ],
      ),
    );
  }
}
