enum NutritionLevel {
  a('A'),
  b('B'),
  c('C'),
  d('D');

  const NutritionLevel(this.label);

  final String label;

  static NutritionLevel fromLabel(String value) {
    return NutritionLevel.values.firstWhere(
      (level) => level.label == value,
      orElse: () => NutritionLevel.c,
    );
  }
}

extension NutritionLevelDetails on NutritionLevel {
  String get title {
    return switch (this) {
      NutritionLevel.a => 'Pilihan terbaik',
      NutritionLevel.b => 'Masih aman',
      NutritionLevel.c => 'Jangan terlalu sering',
      NutritionLevel.d => 'Perlu dibatasi',
    };
  }

  String get description {
    return switch (this) {
      NutritionLevel.a =>
        'Cocok untuk konsumsi harian karena gula, garam, dan lemaknya rendah.',
      NutritionLevel.b =>
        'Masih aman buat rutinitas, tapi tetap perlu lihat porsi.',
      NutritionLevel.c =>
        'Boleh dikonsumsi, tapi lebih enak dijadikan pilihan sesekali.',
      NutritionLevel.d =>
        'Tinggi gula, garam, atau lemak. Lebih baik dibatasi.',
    };
  }

  String get criteria {
    return switch (this) {
      NutritionLevel.a => 'Gula < 1g • garam < 5mg • lemak jenuh rendah',
      NutritionLevel.b => 'Gula 1-5g • garam 5-120mg • lemak jenuh rendah',
      NutritionLevel.c => 'Gula 5-10g • garam 120-500mg • lemak jenuh sedang',
      NutritionLevel.d => 'Gula > 10g • garam > 500mg • lemak jenuh tinggi',
    };
  }

  String get examples {
    return switch (this) {
      NutritionLevel.a => 'Air mineral, teh tawar, americano',
      NutritionLevel.b => 'Susu low fat, kopi susu tanpa gula',
      NutritionLevel.c => 'Minuman isotonik, kopi instan, jus kemasan',
      NutritionLevel.d => 'Cola, boba tea, sirup, minuman manis',
    };
  }
}
