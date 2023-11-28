part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Costs> costsData = [];
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
  dynamic calculatedCosts;
  dynamic calculatedCost;
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

  Future<List<Costs>> getCosts(var originId, var destinationId, var weight, var courier) async {
    dynamic costs;
    await MasterDataService.getCosts(originId, destinationId, weight, courier).then((value) {
      setState(() {
        costs = value;
        dataLength = costs.length;
        // print(costs);
      });
    });
    print(costs);
    return costs;
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
        title: Text("Home Page"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(20),
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
                                return UiLoading.loadingSmall();
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
                                return UiLoading.loadingSmall();
                              },
                            ),
                          ),
                        ],
                      ),
                      // End Row DESTINATION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                                    ),
                                onPressed: () {
                                  setState(() {
                                    // weight = weightTextController.text;
                                    dataReady = true;
                                    calculatedCosts = getCosts(selectedCityOrigin.cityId, selectedCityDestination.cityId, weightTextController.text, selectedCourier);
                                    // calculatedCost = getCost(selectedCityOrigin.cityId, selectedCityDestination.cityId, weightTextController.text, selectedCourier);
                                    
                                    // print(calculatedCost);
                                    // costsData = calculatedCost;
                                  });
                                },
                                child: Text(
                                  "Hitung Estimasi Harga",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: !dataReady
                      ? const Align(
                          alignment: Alignment.center,
                          child: Text("Data tidak ditemukan"),
                        )
                      : ListView.builder(
                          itemCount: dataLength,
                          itemBuilder: (context, index) {
                            return CardCosts(calculatedCost);
                          },
                  )
                ),
              ),
            ],
          ),
          isLoading == true ? UiLoading.loadingBlock() : Container(),
        ],
      ),
    );
  }
}
