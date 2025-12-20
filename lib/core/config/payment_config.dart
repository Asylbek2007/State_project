/// Payment configuration with recipient details.
class PaymentConfig {
  // Название получателя
  static const String recipientName = 'Колледж';
  
  // Номера телефонов для переводов
  static const String kaspiNumber = '+7 705 104 45 25'; // Номер для Kaspi перевода
  static const String halykNumber = '+7 705 104 45 25'; // Номер для Halyk перевода
  
  // Опциональные реквизиты (если есть)
  static const String? accountNumber = null; // IBAN (если есть)
  static const String? bankName = null; // Название банка (если есть)
  static const String? bin = null; // БИН (если есть)
  
  /// Generate QR code data for Kaspi transfer.
  /// Используем простой формат с номером телефона, который распознает камера Kaspi
  static String generateKaspiQR(double amount) {
    // Простой формат: номер телефона в международном формате
    // Камера Kaspi распознает номер и предложит перевод
    final phone = kaspiNumber.replaceAll(' ', '').replaceAll('-', '');
    
    // Формат для распознавания камерой Kaspi
    // Камера увидит номер телефона и предложит перевести деньги
    return phone;
  }
  
  /// Generate detailed QR code with payment information.
  /// Альтернативный формат с полной информацией
  static String generateDetailedQR(double amount) {
    final phone = kaspiNumber.replaceAll(' ', '').replaceAll('-', '');
    final amountStr = amount.toStringAsFixed(0);
    
    // Формат с информацией о переводе
    return 'Перевод на номер: $phone\n'
        'Сумма: $amountStr ₸\n'
        'Получатель: $recipientName';
  }
  
  /// Generate simple QR code with payment info (for manual transfer).
  static String generateSimpleQR(double amount) {
    // Простой QR-код с информацией для перевода
    return 'Пожертвование: $amount ₸\n'
        'Получатель: $recipientName\n'
        'Kaspi: $kaspiNumber\n'
        'Halyk: $halykNumber';
  }
  
  /// Check if bank details are available.
  static bool get hasBankDetails => accountNumber != null && bankName != null;
  
  /// Generate QR code data in NSB format for bank transfer (if bank details available).
  static String? generateBankQRData(double amount) {
    if (!hasBankDetails) return null;
    
    // Формат НСБ QR-кода для перевода в Казахстане
    return 'ST00012|'
        'Name=$recipientName|'
        'PersonalAcc=$accountNumber|'
        'BankName=$bankName|'
        'Sum=$amount|'
        'Purpose=Пожертвование на развитие колледжа';
  }
}

