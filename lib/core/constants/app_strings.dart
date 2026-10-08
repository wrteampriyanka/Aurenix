/// Every translation key, as a constant.
///
/// Use `AppStrings.loginTitle.tr` rather than `'login_title'.tr`: a typo in a
/// raw string fails silently — the key itself renders on screen and the
/// analyzer cannot see it. These are keys only; the text lives in
/// `assets/translations/*.json`.
///
/// Keys built at runtime (`'app_info_perm_$name'`) cannot be constants and
/// are still written out in full at their call site.
///
/// `test/core/localization/app_strings_test.dart` checks this list against
/// the JSON files, so the two cannot drift apart.
class AppStrings {
  AppStrings._();

  static const appName = 'app_name';
  static const appInfoConnect = 'app_info_connect';
  static const appInfoDisconnect = 'app_info_disconnect';
  static const appInfoPermComments = 'app_info_perm_comments';
  static const appInfoPermFiles = 'app_info_perm_files';
  static const appInfoPermTeam = 'app_info_perm_team';
  static const appInfoPermMessages = 'app_info_perm_messages';
  static const appInfoPermCanvas = 'app_info_perm_canvas';
  static const appInfoPermFolders = 'app_info_perm_folders';
  static const appInfoPermSharing = 'app_info_perm_sharing';
  static const appInfoPermPages = 'app_info_perm_pages';
  static const appInfoPermActivity = 'app_info_perm_activity';
  static const appInfoPermDatabase = 'app_info_perm_database';
  static const appInfoPermPush = 'app_info_perm_push';
  static const appInfoPermAuth = 'app_info_perm_auth';
  static const appInfoPermContent = 'app_info_perm_content';
  static const appInfoPermReply = 'app_info_perm_reply';
  static const appInfoPermSchedule = 'app_info_perm_schedule';
  static const appInfoPermChat = 'app_info_perm_chat';
  static const appInfoPermMeetings = 'app_info_perm_meetings';
  static const appInfoPermAutoReply = 'app_info_perm_auto_reply';
  static const appInfoPermProjects = 'app_info_perm_projects';
  static const appInfoPermTasks = 'app_info_perm_tasks';
  static const appInfoPermReports = 'app_info_perm_reports';
  static const appInfoPermCode = 'app_info_perm_code';
  static const appInfoPermPrReview = 'app_info_perm_pr_review';

  static const onboardingTitle = 'onboarding_title';
  static const onboardingSubtitle = 'onboarding_subtitle';

  static const getStarted = 'get_started';

  static const loginTitle = 'login_title';
  static const loginSubtitle = 'login_subtitle';

  static const emailHint = 'email_hint';

  static const passwordHint = 'password_hint';
  static const passwordShow = 'password_show';
  static const passwordHide = 'password_hide';

  static const forgotPassword = 'forgot_password';
  static const forgotPasswordTitle = 'forgot_password_title';
  static const forgotPasswordSubtitle = 'forgot_password_subtitle';

  static const startVerification = 'start_verification';

  static const resetPasswordTitle = 'reset_password_title';

  static const createPasswordHint = 'create_password_hint';
  static const createAccount = 'create_account';

  static const confirmPasswordHint = 'confirm_password_hint';

  static const submitNewPassword = 'submit_new_password';

  static const continueLogin = 'continue_login';
  static const continueWithGoogle = 'continue_with_google';
  static const continueWithGithub = 'continue_with_github';
  static const continueKey = 'continue';

  static const or = 'or';

  static const noAccount = 'no_account';

  static const registerNow = 'register_now';
  static const registerTitle = 'register_title';
  static const registerSubtitle = 'register_subtitle';

  static const termsPrefix = 'terms_prefix';
  static const termsAndConditions = 'terms_and_conditions';

  static const and = 'and';

  static const privacyPolicy = 'privacy_policy';
  static const privacyPolicyBody = 'privacy_policy_body';

  static const nameHint = 'name_hint';

  static const haveAccount = 'have_account';

  static const signIn = 'sign_in';

  static const otpTitle = 'otp_title';
  static const otpSubtitle = 'otp_subtitle';

  static const resendCodeIn = 'resend_code_in';
  static const resendCode = 'resend_code';

  static const homeModelName = 'home_model_name';
  static const homePrompt = 'home_prompt';
  static const homeInputHint = 'home_input_hint';
  static const homeCode = 'home_code';
  static const homeResearch = 'home_research';
  static const homeCanvas = 'home_canvas';
  static const homeGenerateImages = 'home_generate_images';
  static const homeIntegration = 'home_integration';

  static const sidebarSearchHint = 'sidebar_search_hint';
  static const sidebarNewChat = 'sidebar_new_chat';
  static const sidebarTemporaryChat = 'sidebar_temporary_chat';
  static const sidebarPresets = 'sidebar_presets';
  static const sidebarNewProject = 'sidebar_new_project';
  static const sidebarResearch = 'sidebar_research';
  static const sidebarEducation = 'sidebar_education';
  static const sidebarViewAll = 'sidebar_view_all';
  static const sidebarTemporaryChatOn = 'sidebar_temporary_chat_on';
  static const sidebarChats = 'sidebar_chats';
  static const sidebarNoChats = 'sidebar_no_chats';

  static const projectsTitle = 'projects_title';
  static const projectsCreateNew = 'projects_create_new';
  static const projectsChats = 'projects_chats';
  static const projectsEmpty = 'projects_empty';
  static const projectsNameHint = 'projects_name_hint';
  static const projectsNameRequired = 'projects_name_required';
  static const projectsCreate = 'projects_create';
  static const projectsNewChatIn = 'projects_new_chat_in';
  static const projectsNameLabel = 'projects_name_label';
  static const projectsMemoryLabel = 'projects_memory_label';
  static const projectsMemoryDefault = 'projects_memory_default';
  static const projectsMemoryDefaultDesc = 'projects_memory_default_desc';
  static const projectsMemoryOnly = 'projects_memory_only';
  static const projectsMemoryOnlyDesc = 'projects_memory_only_desc';
  static const projectsMenuEdit = 'projects_menu_edit';
  static const projectsMenuInstructions = 'projects_menu_instructions';
  static const projectsMenuImportChats = 'projects_menu_import_chats';
  static const projectsMenuDelete = 'projects_menu_delete';
  static const projectsInstructionsTitle = 'projects_instructions_title';
  static const projectsInstructionsDesc = 'projects_instructions_desc';
  static const projectsInstructionsHint = 'projects_instructions_hint';
  static const projectsInstructionsSave = 'projects_instructions_save';
  static const projectsImportComingSoon = 'projects_import_coming_soon';
  static const projectsDeleted = 'projects_deleted';

  static const projectDetailSearchHint = 'project_detail_search_hint';
  static const projectDetailShare = 'project_detail_share';
  static const projectDetailEmpty = 'project_detail_empty';
  static const projectFilesTitle = 'project_files_title';
  static const projectFilesUpload = 'project_files_upload';
  static const projectFilesEmpty = 'project_files_empty';
  static const projectFilesRemove = 'project_files_remove';
  static const projectFilesFailed = 'project_files_failed';

  static const collaborationTitle = 'collaboration_title';
  static const collaborationMenuTitle = 'collaboration_menu_title';
  static const collaborationOnlyInvited = 'collaboration_only_invited';
  static const collaborationAnyoneWithLink = 'collaboration_anyone_with_link';
  static const collaborationInviteLabel = 'collaboration_invite_label';
  static const collaborationEmailHint = 'collaboration_email_hint';
  static const collaborationMembersLabel = 'collaboration_members_label';
  static const collaborationYou = 'collaboration_you';
  static const collaborationRoleOwner = 'collaboration_role_owner';
  static const collaborationRoleCanEdit = 'collaboration_role_can_edit';
  static const collaborationRoleViewOnly = 'collaboration_role_view_only';
  static const collaborationRemove = 'collaboration_remove';
  static const collaborationRemoved = 'collaboration_removed';
  static const collaborationInvited = 'collaboration_invited';
  static const collaborationInvalidEmail = 'collaboration_invalid_email';
  static const collaborationAlreadyMember = 'collaboration_already_member';
  static const collaborationShareLink = 'collaboration_share_link';
  static const collaborationLinkCopied = 'collaboration_link_copied';

  static const presetsTitle = 'presets_title';
  static const presetsSearchHint = 'presets_search_hint';
  static const presetsFilterHandPicked = 'presets_filter_hand_picked';
  static const presetsFilterTrending = 'presets_filter_trending';
  static const presetsFilterFeatures = 'presets_filter_features';
  static const presetsFilterBusiness = 'presets_filter_business';
  static const presetsFilterEducation = 'presets_filter_education';
  static const presetsSectionCoding = 'presets_section_coding';
  static const presetsSectionTrendingWeek = 'presets_section_trending_week';
  static const presetsBy = 'presets_by';
  static const presetsEmpty = 'presets_empty';
  static const presetsCategoryRank = 'presets_category_rank';
  static const presetsVisitSite = 'presets_visit_site';
  static const presetsConversations = 'presets_conversations';
  static const presetsRatingsReviews = 'presets_ratings_reviews';
  static const presetsReviewsCount = 'presets_reviews_count';
  static const presetsCapabilities = 'presets_capabilities';
  static const presetsQuickStarters = 'presets_quick_starters';
  static const presetsStartChat = 'presets_start_chat';

  static const presetChatNotice = 'preset_chat_notice';

  static const chatDisclaimer = 'chat_disclaimer';
  static const chatThinking = 'chat_thinking';
  static const chatSearchingWeb = 'chat_searching_web';
  static const chatCopied = 'chat_copied';
  static const chatCopyText = 'chat_copy_text';
  static const chatSelectText = 'chat_select_text';
  static const chatEditMessage = 'chat_edit_message';
  static const chatShare = 'chat_share';
  static const chatMenuRename = 'chat_menu_rename';
  static const chatMenuArchive = 'chat_menu_archive';
  static const chatMenuMove = 'chat_menu_move';
  static const chatMenuDelete = 'chat_menu_delete';
  static const chatMenuRenameTitle = 'chat_menu_rename_title';
  static const chatMenuRenameHint = 'chat_menu_rename_hint';
  static const chatMenuRenameSave = 'chat_menu_rename_save';
  static const chatMenuArchived = 'chat_menu_archived';
  static const chatMenuMoved = 'chat_menu_moved';
  static const chatMenuDeleted = 'chat_menu_deleted';
  static const chatMenuNoProjects = 'chat_menu_no_projects';
  static const chatMenuUnsaved = 'chat_menu_unsaved';
  static const chatError = 'chat_error';
  static const chatSources = 'chat_sources';
  static const chatOpenFailed = 'chat_open_failed';
  static const chatMicUnavailable = 'chat_mic_unavailable';
  static const chatListeningHint = 'chat_listening_hint';
  static const chatVoiceEmpty = 'chat_voice_empty';
  static const chatSpeakFailed = 'chat_speak_failed';
  static const chatGeneratingImage = 'chat_generating_image';
  static const chatFileUnsupported = 'chat_file_unsupported';
  static const chatFileFailed = 'chat_file_failed';
  static const chatFileTooLarge = 'chat_file_too_large';
  static const chatCameraUnavailable = 'chat_camera_unavailable';
  static const chatUpgradeLimit = 'chat_upgrade_limit';
  static const chatUpgradeLimitUntil = 'chat_upgrade_limit_until';
  static const chatLimitHint = 'chat_limit_hint';

  static const servicesAttachDocument = 'services_attach_document';
  static const servicesCaptureImage = 'services_capture_image';
  static const servicesGenerateCode = 'services_generate_code';
  static const servicesIntegration = 'services_integration';
  static const servicesAiResearch = 'services_ai_research';
  static const servicesGenerateImage = 'services_generate_image';
  static const servicesIntegratedApps = 'services_integrated_apps';
  static const servicesFigma = 'services_figma';
  static const servicesFigmaDesc = 'services_figma_desc';
  static const servicesZync = 'services_zync';
  static const servicesZyncDesc = 'services_zync_desc';
  static const servicesGoogleDrive = 'services_google_drive';
  static const servicesGoogleDriveDesc = 'services_google_drive_desc';

  static const connectedAppsTitle = 'connected_apps_title';
  static const connectedAppsSearchHint = 'connected_apps_search_hint';
  static const connectedAppsConnected = 'connected_apps_connected';
  static const connectedAppsMore = 'connected_apps_more';
  static const connectedAppsEmpty = 'connected_apps_empty';
  static const connectedAppsNotion = 'connected_apps_notion';
  static const connectedAppsNotionDesc = 'connected_apps_notion_desc';
  static const connectedAppsFirebase = 'connected_apps_firebase';
  static const connectedAppsFirebaseDesc = 'connected_apps_firebase_desc';
  static const connectedAppsSlack = 'connected_apps_slack';
  static const connectedAppsSlackDesc = 'connected_apps_slack_desc';
  static const connectedAppsTeams = 'connected_apps_teams';
  static const connectedAppsTeamsDesc = 'connected_apps_teams_desc';
  static const connectedAppsGitlab = 'connected_apps_gitlab';
  static const connectedAppsGitlabDesc = 'connected_apps_gitlab_desc';
  static const connectedAppsGithub = 'connected_apps_github';
  static const connectedAppsGithubDesc = 'connected_apps_github_desc';

  static const profilePlanFree = 'profile_plan_free';
  static const profilePlanPrice = 'profile_plan_price';
  static const profileUpgradeNow = 'profile_upgrade_now';
  static const profileCustomizeAi = 'profile_customize_ai';
  static const profileArchiveChats = 'profile_archive_chats';
  static const profileLanguage = 'profile_language';
  static const profileVoiceSettings = 'profile_voice_settings';
  static const profileConnectedApps = 'profile_connected_apps';
  static const profileDataControl = 'profile_data_control';
  static const profilePrivacyPolicy = 'profile_privacy_policy';
  static const profileAboutUs = 'profile_about_us';
  static const profileLogout = 'profile_logout';

  static const upgradeTo = 'upgrade_to';
  static const upgradeLiteName = 'upgrade_lite_name';
  static const upgradeProName = 'upgrade_pro_name';
  static const upgradeFeatureUnlimitedPrompts =
      'upgrade_feature_unlimited_prompts';
  static const upgradeFeatureCode60 = 'upgrade_feature_code_60';
  static const upgradeFeatureCodeUnlimited = 'upgrade_feature_code_unlimited';
  static const upgradeFeatureImages8 = 'upgrade_feature_images_8';
  static const upgradeFeatureImages15 = 'upgrade_feature_images_15';
  static const upgradeFeatureVideos5 = 'upgrade_feature_videos_5';
  static const upgradeFeatureWebSearch8h = 'upgrade_feature_web_search_8h';
  static const upgradePriceFree = 'upgrade_price_free';
  static const upgradeLiteRenewal = 'upgrade_lite_renewal';
  static const upgradeProRenewal = 'upgrade_pro_renewal';
  static const upgradeLiteCheckoutNote = 'upgrade_lite_checkout_note';
  static const upgradeProCheckoutNote = 'upgrade_pro_checkout_note';
  static const upgradeLiteAutoCharge = 'upgrade_lite_auto_charge';
  static const upgradeProAutoCharge = 'upgrade_pro_auto_charge';
  static const upgradeActivate = 'upgrade_activate';
  static const upgradeChangePlan = 'upgrade_change_plan';
  static const upgradePaymentAddress = 'upgrade_payment_address';
  static const upgradeSelectState = 'upgrade_select_state';
  static const upgradePinCode = 'upgrade_pin_code';
  static const upgradeStateRequired = 'upgrade_state_required';
  static const upgradePinRequired = 'upgrade_pin_required';
  static const upgradePinInvalid = 'upgrade_pin_invalid';
  static const upgradeSelectCountry = 'upgrade_select_country';
  static const upgradeSearchCountry = 'upgrade_search_country';
  static const upgradeSearchState = 'upgrade_search_state';
  static const upgradeState = 'upgrade_state';
  static const upgradePostalCode = 'upgrade_postal_code';
  static const upgradePostalRequired = 'upgrade_postal_required';
  static const upgradePostalInvalid = 'upgrade_postal_invalid';
  static const upgradePaymentMethod = 'upgrade_payment_method';
  static const upgradePayPlay = 'upgrade_pay_play';
  static const upgradePayRazorpay = 'upgrade_pay_razorpay';
  static const upgradePayPhonepe = 'upgrade_pay_phonepe';
  static const upgradePayPaytm = 'upgrade_pay_paytm';
  static const upgradePayNow = 'upgrade_pay_now';
  static const upgradePaymentTitle = 'upgrade_payment_title';
  static const upgradePaymentPending = 'upgrade_payment_pending';

  static const pickerSearchHint = 'picker_search_hint';
  static const pickerNoResults = 'picker_no_results';

  static const languageTitle = 'language_title';
  static const languageEnglish = 'language_english';
  static const languageHindi = 'language_hindi';
  static const languageArabic = 'language_arabic';

  static const editProfileTitle = 'edit_profile_title';
  static const editProfileGenderHint = 'edit_profile_gender_hint';
  static const editProfileAgeHint = 'edit_profile_age_hint';
  static const editProfileDataNotice = 'edit_profile_data_notice';
  static const editProfileSave = 'edit_profile_save';

  static const genderMale = 'gender_male';
  static const genderFemale = 'gender_female';
  static const genderOther = 'gender_other';

  static const archiveChatsTitle = 'archive_chats_title';
  static const archiveChatsSearchHint = 'archive_chats_search_hint';
  static const archiveChatsEmpty = 'archive_chats_empty';
  static const archiveChatsUnarchive = 'archive_chats_unarchive';
  static const archiveChatsDelete = 'archive_chats_delete';

  static const customizeAiTitle = 'customize_ai_title';
  static const customizeAiToggleTitle = 'customize_ai_toggle_title';
  static const customizeAiToggleSubtitle = 'customize_ai_toggle_subtitle';
  static const customizeAiPersonality = 'customize_ai_personality';
  static const customizeAiInstructionsHint = 'customize_ai_instructions_hint';
  static const customizeAiYourInfo = 'customize_ai_your_info';
  static const customizeAiNicknameHint = 'customize_ai_nickname_hint';
  static const customizeAiOccupationHint = 'customize_ai_occupation_hint';
  static const customizeAiAboutHint = 'customize_ai_about_hint';
  static const customizeAiMemories = 'customize_ai_memories';
  static const customizeAiMemoriesSubtitle = 'customize_ai_memories_subtitle';
  static const customizeAiSave = 'customize_ai_save';
  static const customizeAiInstructionsLabel = 'customize_ai_instructions_label';
  static const customizeAiNicknameLabel = 'customize_ai_nickname_label';
  static const customizeAiOccupationLabel = 'customize_ai_occupation_label';
  static const customizeAiAboutLabel = 'customize_ai_about_label';

  static const memoriesTitle = 'memories_title';
  static const memoriesSavedTitle = 'memories_saved_title';
  static const memoriesSavedSubtitle = 'memories_saved_subtitle';
  static const memoriesHistoryTitle = 'memories_history_title';
  static const memoriesHistorySubtitle = 'memories_history_subtitle';
  static const memoriesSearchHint = 'memories_search_hint';
  static const memoriesAll = 'memories_all';
  static const memoriesEmpty = 'memories_empty';
  static const memoriesNoResults = 'memories_no_results';
  static const memoriesRemoveAll = 'memories_remove_all';

  static const dataControlTitle = 'data_control_title';
  static const dataControlImproveTitle = 'data_control_improve_title';
  static const dataControlImproveSubtitle = 'data_control_improve_subtitle';
  static const dataControlExportTitle = 'data_control_export_title';
  static const dataControlExportSubtitle = 'data_control_export_subtitle';
  static const dataControlDeleteConversations =
      'data_control_delete_conversations';
  static const dataControlVoiceSection = 'data_control_voice_section';
  static const dataControlVoiceTitle = 'data_control_voice_title';
  static const dataControlVoiceSubtitle = 'data_control_voice_subtitle';
  static const dataControlDeleteVoice = 'data_control_delete_voice';
  static const dataControlHistorySection = 'data_control_history_section';
  static const dataControlArchiveAll = 'data_control_archive_all';
  static const dataControlDeleteAllChats = 'data_control_delete_all_chats';
  static const dataControlDeleteAccount = 'data_control_delete_account';

  static const aiPersonalityDefault = 'ai_personality_default';
  static const aiPersonalityFriendly = 'ai_personality_friendly';
  static const aiPersonalityProfessional = 'ai_personality_professional';
  static const aiPersonalityConcise = 'ai_personality_concise';

  static const liveListening = 'live_listening';
  static const liveThinking = 'live_thinking';
  static const liveMuted = 'live_muted';
  static const liveShareTitle = 'live_share_title';
  static const liveShareHint = 'live_share_hint';
  static const liveShareHintIos = 'live_share_hint_ios';
  static const liveShareUnavailable = 'live_share_unavailable';
  static const liveShareChannel = 'live_share_channel';
  static const liveShareNotificationTitle = 'live_share_notification_title';
  static const liveShareNotificationText = 'live_share_notification_text';
  static const liveCameraUnavailable = 'live_camera_unavailable';
  static const liveOutputSpeaker = 'live_output_speaker';
  static const liveOutputDefault = 'live_output_default';
  static const liveOutputConnected = 'live_output_connected';
  static const liveOutputConnecting = 'live_output_connecting';
  static const liveOutputNotConnected = 'live_output_not_connected';
  static const liveOutputUnavailable = 'live_output_unavailable';
  static const liveOutputSearching = 'live_output_searching';
  static const liveOutputSearchAgain = 'live_output_search_again';
  static const liveBluetoothDenied = 'live_bluetooth_denied';
  static const liveBluetoothOff = 'live_bluetooth_off';
  static const liveBluetoothReconnect = 'live_bluetooth_reconnect';
  static const liveBluetoothFailed = 'live_bluetooth_failed';
  static const liveCameraDenied = 'live_camera_denied';

  static const voiceTitle = 'voice_title';
  static const voiceGreeting = 'voice_greeting';
  static const voiceSample = 'voice_sample';
  static const voiceSave = 'voice_save';
  static const voiceSaved = 'voice_saved';
  static const voiceTaglineVictor = 'voice_tagline_victor';
  static const voiceTaglineAria = 'voice_tagline_aria';
  static const voiceTaglineOrion = 'voice_tagline_orion';
  static const voiceTaglineLuna = 'voice_tagline_luna';

  static const aboutUsBody = 'about_us_body';

  static const validationRequired = 'validation_required';
  static const validationEmailRequired = 'validation_email_required';
  static const validationEmailInvalid = 'validation_email_invalid';
  static const validationPasswordRequired = 'validation_password_required';
  static const validationPasswordShort = 'validation_password_short';
  static const validationConfirmRequired = 'validation_confirm_required';
  static const validationPasswordMismatch = 'validation_password_mismatch';

  static const fieldNameLabel = 'field_name_label';
  static const fieldEmailLabel = 'field_email_label';
  static const fieldPasswordLabel = 'field_password_label';
  static const fieldNewPasswordLabel = 'field_new_password_label';
  static const fieldConfirmPasswordLabel = 'field_confirm_password_label';
  static const fieldAgeLabel = 'field_age_label';
}
