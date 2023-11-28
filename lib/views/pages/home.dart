part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> provinceData = [];
  bool isLoading = false;

  Future<dynamic> getProvinces() async {
    dynamic prov;
    await MasterDataService.getProvince().then((value) {
      setState(() {
        provinceData = value;
        isLoading = false;
      });
    });
    return prov;
  }

  @override
  void initState() {
    super.initState();
    getProvinces();
    setState(() {
      isLoading = true;
    });
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
          Container(
              width: double.infinity,
              height: double.infinity,
              child: provinceData.isEmpty
                  ? const Align(
                      alignment: Alignment.center,
                      child: Text("Data tidak ditemukan"),
                    )
                  : ListView.builder(
                      itemCount: provinceData.length,
                      itemBuilder: (context, index) {
                        return CardProvince(provinceData[index]);
                      },
                    )),
          isLoading == true ? UiLoading.loadingBlock() : Container(),
        ],
      ),
    );
  }
}
