part of pawlink_admin;

class AdminDataProvider extends ChangeNotifier {
  AdminDataProvider() {
    _userService = AdminUserService();
    _petService = AdminPetService();
    _reportService = AdminReportService();
    _invitationService = AdminInvitationService();
    _supportService = AdminSupportService();
    _activityService = AdminActivityService();
    _notificationService = AdminNotificationService();
  }

  late final AdminUserService _userService;
  late final AdminPetService _petService;
  late final AdminReportService _reportService;
  late final AdminInvitationService _invitationService;
  late final AdminSupportService _supportService;
  late final AdminActivityService _activityService;
  late final AdminNotificationService _notificationService;

  Stream<List<PawUser>> get usersStream => _userService.getUsersStream();
  Stream<List<PawUser>> get residentsStream => _userService.getResidentsStream();
  Stream<List<PetRecord>> get petsStream => _petService.getPetsStream();
  Stream<List<AnimalReport>> get reportsStream => _reportService.getReportsStream();
  Stream<List<CoOwnerInvitation>> get invitationsStream => _invitationService.getInvitationsStream();
  Stream<List<SupportMessage>> get supportMessagesStream => _supportService.getSupportMessagesStream();
  Stream<List<AdminActivity>> get activitiesStream => _activityService.getActivitiesStream();
  Stream<List<AdminNotification>> get notificationsStream => _notificationService.getNotificationsStream();

  AdminUserService get userService => _userService;
  AdminPetService get petService => _petService;
  AdminReportService get reportService => _reportService;
  AdminInvitationService get invitationService => _invitationService;
  AdminSupportService get supportService => _supportService;
  AdminActivityService get activityService => _activityService;
  AdminNotificationService get notificationService => _notificationService;
}

final AdminDataProvider adminDataProvider = AdminDataProvider();

final ValueNotifier<int> adminPageRequest = ValueNotifier<int>(-1);
void requestAdminPage(int index) => adminPageRequest.value = index;

String currentAdminName = 'Administrator';
final Map<String, String> registeredAdmins = {
  'admin@pawlink.com': 'Administrator Sanchez',
};