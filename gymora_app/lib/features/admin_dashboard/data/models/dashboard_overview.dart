class DashboardOverview {
  final int totalGyms;
  final int totalTrainers;
  final int totalCustomers;
  final int activeMembers;
  final double totalRevenue;
  final double monthlyRevenue;
  final int pendingGyms;
  final int expiringMemberships;

  DashboardOverview({
    required this.totalGyms,
    required this.totalTrainers,
    required this.totalCustomers,
    required this.activeMembers,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.pendingGyms,
    required this.expiringMemberships,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalGyms: json['totalGyms'] ?? 0,
      totalTrainers: json['totalTrainers'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      pendingGyms: json['pendingGyms'] ?? 0,
      expiringMemberships: json['expiringMemberships'] ?? 0,
    );
  }
}
