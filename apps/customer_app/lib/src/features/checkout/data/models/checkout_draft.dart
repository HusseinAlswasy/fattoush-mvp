class CheckoutDraft {
  const CheckoutDraft({
    required this.addressText,
    this.lat,
    this.lng,
    this.deliveryDate,
    this.deliveryTime,
    this.comment,
  });

  final String addressText;
  final double? lat;
  final double? lng;
  final String? deliveryDate;
  final String? deliveryTime;
  final String? comment;
}
