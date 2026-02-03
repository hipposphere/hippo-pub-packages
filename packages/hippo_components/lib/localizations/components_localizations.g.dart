import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'components_localizations_de.g.dart';
import 'components_localizations_en.g.dart';
import 'components_localizations_zh.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ComponentsLocalizations
/// returned by `ComponentsLocalizations.of(context)`.
///
/// Applications need to include `ComponentsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localizations/components_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ComponentsLocalizations.localizationsDelegates,
///   supportedLocales: ComponentsLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ComponentsLocalizations.supportedLocales
/// property.
abstract class ComponentsLocalizations {
  ComponentsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ComponentsLocalizations? of(BuildContext context) {
    return Localizations.of<ComponentsLocalizations>(context, ComponentsLocalizations);
  }

  static const LocalizationsDelegate<ComponentsLocalizations> delegate =
      _ComponentsLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en'), Locale('zh')];

  /// No description provided for @language_name.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_name;

  /// No description provided for @actions_ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get actions_ok;

  /// No description provided for @actions_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actions_open;

  /// No description provided for @actions_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actions_close;

  /// No description provided for @actions_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actions_save;

  /// No description provided for @actions_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actions_create;

  /// No description provided for @actions_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actions_cancel;

  /// No description provided for @actions_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actions_delete;

  /// No description provided for @actions_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actions_edit;

  /// No description provided for @actions_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actions_add;

  /// No description provided for @actions_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actions_back;

  /// No description provided for @actions_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actions_next;

  /// No description provided for @actions_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actions_skip;

  /// No description provided for @actions_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get actions_finish;

  /// No description provided for @actions_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actions_continue;

  /// No description provided for @actions_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actions_confirm;

  /// No description provided for @actions_confirm_action.
  ///
  /// In en, this message translates to:
  /// **'Confirm action'**
  String get actions_confirm_action;

  /// No description provided for @actions_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actions_search;

  /// No description provided for @actions_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actions_reset;

  /// No description provided for @actions_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get actions_select;

  /// No description provided for @actions_select_all.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get actions_select_all;

  /// No description provided for @actions_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actions_filter;

  /// No description provided for @actions_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actions_clear;

  /// No description provided for @actions_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get actions_upload;

  /// No description provided for @actions_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actions_download;

  /// No description provided for @actions_view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get actions_view;

  /// No description provided for @actions_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actions_copy;

  /// No description provided for @actions_paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get actions_paste;

  /// No description provided for @actions_cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get actions_cut;

  /// No description provided for @actions_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actions_undo;

  /// No description provided for @actions_redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get actions_redo;

  /// No description provided for @actions_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actions_refresh;

  /// No description provided for @actions_expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get actions_expand;

  /// No description provided for @actions_collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get actions_collapse;

  /// No description provided for @actions_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actions_more;

  /// No description provided for @actions_show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get actions_show;

  /// No description provided for @actions_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get actions_hide;

  /// No description provided for @actions_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get actions_submit;

  /// No description provided for @actions_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get actions_manage;

  /// No description provided for @actions_enter_text.
  ///
  /// In en, this message translates to:
  /// **'Enter text'**
  String get actions_enter_text;

  /// No description provided for @actions_enter_value.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get actions_enter_value;

  /// No description provided for @actions_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actions_share;

  /// No description provided for @actions_print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get actions_print;

  /// No description provided for @actions_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actions_done;

  /// No description provided for @actions_import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actions_import;

  /// No description provided for @actions_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actions_export;

  /// No description provided for @actions_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get actions_send;

  /// No description provided for @actions_receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get actions_receive;

  /// No description provided for @actions_or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get actions_or;

  /// No description provided for @common_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get common_overview;

  /// No description provided for @common_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get common_new;

  /// No description provided for @common_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get common_default;

  /// No description provided for @common_text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get common_text;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get common_warning;

  /// No description provided for @common_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get common_info;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get common_loading;

  /// No description provided for @common_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get common_update;

  /// No description provided for @common_options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get common_options;

  /// No description provided for @common_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get common_selected;

  /// No description provided for @common_miscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get common_miscellaneous;

  /// No description provided for @common_eg.
  ///
  /// In en, this message translates to:
  /// **'e.g.'**
  String get common_eg;

  /// No description provided for @common_sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get common_sync;

  /// No description provided for @common_syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get common_syncing;

  /// No description provided for @common_synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get common_synced;

  /// No description provided for @common_sync_failed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get common_sync_failed;

  /// No description provided for @common_sync_error.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get common_sync_error;

  /// No description provided for @common_configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get common_configuration;

  /// No description provided for @common_recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get common_recommended;

  /// No description provided for @common_dates_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_dates_today;

  /// No description provided for @common_dates_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get common_dates_tomorrow;

  /// No description provided for @common_dates_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_dates_yesterday;

  /// No description provided for @common_dates_last_week.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get common_dates_last_week;

  /// No description provided for @common_dates_last_month.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get common_dates_last_month;

  /// No description provided for @common_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_name;

  /// No description provided for @common_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get common_description;

  /// No description provided for @common_menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get common_menu;

  /// No description provided for @common_whats_new.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get common_whats_new;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_account;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// No description provided for @settings_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settings_security;

  /// No description provided for @settings_help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settings_help;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get settings_terms;

  /// No description provided for @settings_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settings_privacy_policy;

  /// No description provided for @settings_imprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get settings_imprint;

  /// No description provided for @settings_contactus.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get settings_contactus;

  /// No description provided for @settings_feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settings_feedback;

  /// No description provided for @settings_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settings_support;

  /// No description provided for @settings_faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get settings_faq;

  /// No description provided for @settings_tutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get settings_tutorials;

  /// No description provided for @settings_documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get settings_documentation;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get settings_light_mode;

  /// No description provided for @settings_system_mode.
  ///
  /// In en, this message translates to:
  /// **'System mode'**
  String get settings_system_mode;

  /// No description provided for @user_profile.
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get user_profile;

  /// No description provided for @user_profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get user_profile_email;

  /// No description provided for @user_profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get user_profile_name;

  /// No description provided for @user_profile_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get user_profile_username;

  /// No description provided for @user_profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get user_profile_edit;

  /// No description provided for @user_profile_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get user_profile_change_password;

  /// No description provided for @user_profile_change_name.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get user_profile_change_name;

  /// No description provided for @user_profile_change_username.
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get user_profile_change_username;

  /// No description provided for @user_profile_change_profile_picture.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get user_profile_change_profile_picture;

  /// No description provided for @user_profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get user_profile_logout;

  /// No description provided for @user_profile_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get user_profile_login;

  /// No description provided for @user_profile_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get user_profile_sign_up;

  /// No description provided for @user_profile_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get user_profile_forgot_password;

  /// No description provided for @user_profile_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get user_profile_reset_password;

  /// No description provided for @user_profile_view_account_data.
  ///
  /// In en, this message translates to:
  /// **'View account data'**
  String get user_profile_view_account_data;

  /// No description provided for @user_profile_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get user_profile_delete_account;

  /// No description provided for @dashboard_menu_collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get dashboard_menu_collapse;

  /// No description provided for @dashboard_menu_expand.
  ///
  /// In en, this message translates to:
  /// **'Expand menu'**
  String get dashboard_menu_expand;

  /// No description provided for @toast_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get toast_loading;

  /// No description provided for @toast_loading_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully loaded'**
  String get toast_loading_success;

  /// No description provided for @toast_loading_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get toast_loading_error;

  /// No description provided for @toast_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully loaded'**
  String get toast_success;

  /// No description provided for @toast_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get toast_error;

  /// No description provided for @toast_update_loading.
  ///
  /// In en, this message translates to:
  /// **'Aktualisiere...'**
  String get toast_update_loading;

  /// No description provided for @toast_update_success.
  ///
  /// In en, this message translates to:
  /// **'Erfolgreich aktualisiert'**
  String get toast_update_success;

  /// No description provided for @toast_update_error.
  ///
  /// In en, this message translates to:
  /// **'Beim Aktualisieren ist ein Fehler aufgetreten'**
  String get toast_update_error;

  /// No description provided for @generic_no_entries_available.
  ///
  /// In en, this message translates to:
  /// **'No entries available'**
  String get generic_no_entries_available;

  /// No description provided for @viewer_unsupported_file_type.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type'**
  String get viewer_unsupported_file_type;

  /// No description provided for @viewer_unknown_file_type.
  ///
  /// In en, this message translates to:
  /// **'Unknown file type'**
  String get viewer_unknown_file_type;

  /// No description provided for @viewer_download_file_to_preview.
  ///
  /// In en, this message translates to:
  /// **'Download file to preview'**
  String get viewer_download_file_to_preview;

  /// No description provided for @viewer_no_file_data.
  ///
  /// In en, this message translates to:
  /// **'No file data'**
  String get viewer_no_file_data;

  /// No description provided for @main_detail_select_item.
  ///
  /// In en, this message translates to:
  /// **'Please select an item'**
  String get main_detail_select_item;

  /// No description provided for @editor_tap_to_copy_reference.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy the reference string'**
  String get editor_tap_to_copy_reference;

  /// No description provided for @statistics_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics_title;

  /// No description provided for @statistics_total_events.
  ///
  /// In en, this message translates to:
  /// **'Times crossed: {count}'**
  String statistics_total_events(Object count);

  /// No description provided for @statistics_coverage_rate.
  ///
  /// In en, this message translates to:
  /// **'Coverage rate: {percent}%'**
  String statistics_coverage_rate(Object percent);

  /// A message indicating the minimum length requirement for the text input, with pluralization support.
  ///
  /// In en, this message translates to:
  /// **'{letters, plural, =0 {The text must be at least {letters} letters long.} =1 {The text must be at least 1 letter long.} other {The text must be at least {letters} letters long.}}'**
  String editor_requires_text_min_length(int letters);
}

class _ComponentsLocalizationsDelegate extends LocalizationsDelegate<ComponentsLocalizations> {
  const _ComponentsLocalizationsDelegate();

  @override
  Future<ComponentsLocalizations> load(Locale locale) {
    return SynchronousFuture<ComponentsLocalizations>(lookupComponentsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_ComponentsLocalizationsDelegate old) => false;
}

ComponentsLocalizations lookupComponentsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ComponentsLocalizationsDe();
    case 'en':
      return ComponentsLocalizationsEn();
    case 'zh':
      return ComponentsLocalizationsZh();
  }

  throw FlutterError(
    'ComponentsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
