enum MedicalSpecialty {
  generalPractitioner,
  psychiatrist,
  psychologist,
  pediatrician,
  dermatologist,
  cardiologist,
  dentist,
  gynecologist,
  other,
}

extension MedicalSpecialtyLabel on MedicalSpecialty {
  String get label {
    switch (this) {
      case MedicalSpecialty.generalPractitioner:
        return "Pratisyen Hekim";
      case MedicalSpecialty.psychiatrist:
        return "Psikiyatrist";
      case MedicalSpecialty.psychologist:
        return "Psikolog";
      case MedicalSpecialty.pediatrician:
        return "Çocuk Doktoru";
      case MedicalSpecialty.dermatologist:
        return "Dermatolog";
      case MedicalSpecialty.cardiologist:
        return "Kardiyolog";
      case MedicalSpecialty.dentist:
        return "Diş Hekimi";
      case MedicalSpecialty.gynecologist:
        return "Kadın Doğum Uzmanı";
      case MedicalSpecialty.other:
        return "Diğer";
    }
  }
}
