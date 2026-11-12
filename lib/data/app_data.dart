part of pawlink_admin;

final List<PawUser> users = [];

final List<PetRecord> pets = [];

final List<AnimalReport> reports = [];

final List<CoOwnerInvitation> invitations = [];

final List<SupportMessage> supportMessages = [];
final List<AdminNotification> adminNotifications = [];
final ValueNotifier<int> adminPageRequest = ValueNotifier<int>(-1);
void requestAdminPage(int index) => adminPageRequest.value = index;

final List<AdminActivity> activities = [];

String currentAdminName = 'Administrator';
final Map<String, String> registeredAdmins = {
  'admin@pawlink.com': 'Administrator Sanchez',
};
