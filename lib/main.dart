library pawlink_admin;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Theme
part 'theme/app_colors.dart';

// App Root
part 'app/pawlink_app.dart';

// Models
part 'models/paw_user.dart';
part 'models/pet_record.dart';
part 'models/animal_report.dart';
part 'models/co_owner_invitation.dart';
part 'models/support_message.dart';
part 'models/admin_notification.dart';
part 'models/admin_activity.dart';

// Data and Utils
part 'data/app_data.dart';
part 'utils/helpers.dart';

// Login Feature
part 'features/login/pages/admin_login_page.dart';
part 'features/login/dialogs/admin_auth_dialog.dart';
part 'features/login/widgets/login_widgets.dart';

// Layout
part 'layout/admin_shell/admin_shell.dart';
part 'layout/sidebar/admin_sidebar.dart';
part 'shared/animation/pawlink_animated_background.dart';
part 'shared/pages/admin_page.dart';

// Dashboard
part 'features/dashboard/pages/dashboard_page.dart';
part 'features/dashboard/widgets/dashboard_stat_card.dart';
part 'features/dashboard/widgets/quick_action_card.dart';

// Residents
part 'features/residents/pages/residents_page.dart';
part 'features/residents/widgets/resident_card.dart';
part 'features/residents/dialogs/delete_user_dialog.dart';
part 'features/residents/dialogs/user_details_dialog.dart';

// Legacy Barangay
part 'features/legacy_barangay/pages/barangay_officials_page.dart';
part 'features/legacy_barangay/pages/official_details_page.dart';

// Pet Registry & Registration
part 'features/pet_registry/pages/pet_registry_page.dart';
part 'features/pet_registry/widgets/pet_card.dart';
part 'features/pet_registry/dialogs/pet_details_dialog.dart';
part 'features/pet_registry/dialogs/mark_deceased_dialog.dart';
part 'features/pet_registry/dialogs/delete_pet_dialog.dart';
part 'features/pet_registration/dialogs/register_pet_dialog.dart';
part 'features/pet_registration/dialogs/registration_success_dialog.dart';

// Pet Categories
part 'features/pet_categories/pages/pet_categories_page.dart';
part 'features/pet_categories/widgets/category_summary.dart';
part 'features/pet_categories/widgets/category_card.dart';
part 'features/pet_categories/pages/category_details_page.dart';

// Ownerships & Invitations
part 'features/ownership/pages/ownership_page.dart';
part 'features/invitations/pages/invitations_page.dart';
part 'features/invitations/dialogs/create_invitation_dialog.dart';
part 'features/ownership/dialogs/manage_co_owner_dialog.dart';

// Reports
part 'features/reports/pages/reports_page.dart';
part 'features/reports/widgets/report_card.dart';
part 'features/reports/dialogs/compare_report_dialog.dart';
part 'features/reports/widgets/compare_column.dart';
part 'features/reports/dialogs/report_details_dialog.dart';

// QR Registry & Scan
part 'features/qr_registry/pages/qr_registry_page.dart';
part 'features/qr_registry/dialogs/pet_qr_dialog.dart';
part 'features/qr_registry/pages/pet_scan_preview_page.dart';
part 'features/qr_registry/pages/qr_found_pet_page.dart';

// Activity Log
part 'features/activity_log/pages/activity_log_page.dart';

// Admin Account
part 'features/admin_account/pages/admin_account_page.dart';

// Barangay Support
part 'features/barangay_support/pages/barangay_support_page.dart';
part 'features/barangay_support/widgets/barangay_support_action.dart';

// Notifications
part 'features/notifications/widgets/notification_bell.dart';
part 'features/notifications/dialogs/notifications_dialog.dart';

// Support Inbox
part 'features/support_inbox/pages/support_inbox_page.dart';
part 'features/support_inbox/dialogs/support_request_dialog.dart';

// Help Center
part 'features/help_center/pages/help_center_standalone_page.dart';
part 'features/help_center/pages/help_center_page.dart';
part 'features/help_center/widgets/help_center_content.dart';
part 'features/help_center/widgets/help_topic_card.dart';

// Shared Widgets
part 'shared/widgets/app_card.dart';
part 'shared/widgets/small_pet_card.dart';
part 'shared/widgets/small_report_card.dart';
part 'shared/widgets/photo_placeholder.dart';
part 'shared/widgets/search_field.dart';
part 'shared/widgets/form_label.dart';
part 'shared/widgets/section_title.dart';
part 'shared/widgets/info_box.dart';
part 'shared/widgets/detail_line.dart';
part 'shared/widgets/empty_card.dart';
part 'shared/widgets/status_chip.dart';

void main() {
  runApp(const PawLinkApp());
}

