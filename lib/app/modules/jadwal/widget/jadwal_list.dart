import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/jadwal.dart';
import 'package:siawi_app/utils/colors.dart';

class JadwalList extends StatelessWidget {
  final String scrollKey;
  final List<Jadwal> jadwalList;
  const JadwalList(this.scrollKey, this.jadwalList, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
        key: PageStorageKey(scrollKey),
        padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
        // itemBuilder: (_, index) => BidderCard(jadwalList[index]),
        itemBuilder: (_, index) => Container(
          child: ListTile(
            shape: RoundedRectangleBorder(
              // side: BorderSide(width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            tileColor: AppColors.thirdColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Image.asset(
              'assets/icon/jadwal.png',
              width: 25,
              height: 25,
            ),
            title: Text(
                "Jam ke ${jadwalList[index].awalJam} s/d ${jadwalList[index].akhirJam}"),
            titleTextStyle: TextStyle(
                fontSize: 10,
                color: AppColors.sixColor,
                fontWeight: FontWeight.w500),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${jadwalList[index].namaMapel}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${jadwalList[index].namaGuru}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${jadwalList[index].jamMulai} s/d ${jadwalList[index].jamSelesai}",
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.mainColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
            // leading: Image.asset(
            //   'assets/icon/absen.png',
            //   width: 25,
            //   height: 25,
            // ),
            // title: Text(
            //     "Jam ke ${jadwalList[index].awalJam} s/d ${jadwalList[index].akhirJam}"),
            // titleTextStyle: TextStyle(
            //     fontSize: 10,
            //     color: AppColors.sixColor,
            //     fontWeight: FontWeight.w500),
            // subtitle: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text("${jadwalList[index].namaMapel}"),
            //     Text("${jadwalList[index].namaMapel}")
            //   ],
            // ),
            // trailing: Container(
            //   width: 15, // Lebar lingkaran
            //   height: 15, // Tinggi lingkaran
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle, // Mengatur bentuk lingkaran
            //     color: Colors.red, // Mengatur warna lingkaran
            //   ),
            // ),
          ),
        ),
        separatorBuilder: (_, index) => SizedBox(height: 15),
        itemCount: jadwalList.length,
      ),
    );
  }
}
