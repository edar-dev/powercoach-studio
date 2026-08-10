// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PowerCoach Studio';

  @override
  String get landingHeroBadge => 'Il futuro del coaching è qui';

  @override
  String get landingTitlePrefix => 'Power';

  @override
  String get landingTitleSuffix => 'Coach Studio';

  @override
  String get landingSubtitle =>
      'Crea e gestisci le schede allenamento per i tuoi clienti.';

  @override
  String get landingCtaPrimary => 'Inizia ora';

  @override
  String get landingCtaSecondary => 'Scopri di più';

  @override
  String get notImplementedMessage => 'Funzionalità non ancora implementata.';

  @override
  String get landingFeaturesTitle => 'Funzionalità Premium';

  @override
  String get landingFeaturesHeadline => 'Tutto ciò che serve per crescere.';

  @override
  String get landingFeaturesDesc =>
      'Concentrati su ciò che fai meglio: il coaching. Noi ci occupiamo di logistica e monitoraggio.';

  @override
  String get landingFeaturesCustomers => 'Gestione clienti';

  @override
  String get landingFeaturesEditor => 'Editor visuale per le schede';

  @override
  String get landingFeaturesClientData => 'Dati cliente e libreria';

  @override
  String get landingFeaturesExport => 'Esportazione in PDF';

  @override
  String get landingHowItWorksLabel => 'Il processo';

  @override
  String get landingHowItWorksTitle => 'Come funziona PowerCoach Studio';

  @override
  String get landingHowItWorksStep1 => 'Crea un profilo cliente';

  @override
  String get landingHowItWorksStep2 => 'Crea le schede allenamento';

  @override
  String get landingHowItWorksStep3 => 'Aggiungi esercizi, serie e ripetizioni';

  @override
  String get landingHowItWorksStep4 => 'Esporta in PDF';

  @override
  String get landingCtaSectionTitle => 'Pronto a trasformare il tuo coaching?';

  @override
  String get landingCtaSectionSubtext => 'Accedi per iniziare.';

  @override
  String get landingCtaSectionButton => 'Accedi';

  @override
  String get landingCtaSectionSubtextLoggedIn => 'Vai al profilo per iniziare.';

  @override
  String get landingCtaSectionButtonLoggedIn => 'Profilo';

  @override
  String get landingNavPricing => 'Prezzi';

  @override
  String get landingBetaBadge => 'Accesso anticipato — beta coach';

  @override
  String get landingCtaStartFree => 'Inizia gratis';

  @override
  String get landingCtaSeePricing => 'Vedi prezzi';

  @override
  String get landingPricingLabel => 'Piani';

  @override
  String get landingPricingTitle => 'Scegli il piano giusto per te';

  @override
  String get landingPricingSubtitle =>
      'Inizia gratis con fino a 5 clienti. Passa a Pro quando cresci.';

  @override
  String get landingPricingFreeTitle => 'Gratuito';

  @override
  String get landingPricingFreePrice => '0 €';

  @override
  String get landingPricingFreePeriod => 'per sempre';

  @override
  String get landingPricingFreeCta => 'Crea account gratis';

  @override
  String get landingPricingProTitle => 'Pro';

  @override
  String get landingPricingProPriceMonthly => '12 €/mese';

  @override
  String get landingPricingProPriceYearly => '99 €/anno';

  @override
  String get landingPricingProCta => 'Passa a Pro';

  @override
  String get landingPricingProCtaLoggedIn => 'Gestisci abbonamento';

  @override
  String get landingPricingBetaNote =>
      'Durante la beta chiusa puoi attivare Pro gratis con un codice invito dopo la registrazione.';

  @override
  String landingPricingFeatureCustomersFree(int max) {
    return 'Fino a $max clienti attivi';
  }

  @override
  String get landingPricingFeatureCustomersPro => 'Clienti illimitati';

  @override
  String get landingPricingFeatureBuilder => 'Builder schede completo';

  @override
  String get landingPricingFeatureExportPro => 'Export PDF, Excel e CSV';

  @override
  String get landingPricingFeatureHevy => 'Integrazione Hevy';

  @override
  String get landingFaqLabel => 'FAQ';

  @override
  String get landingFaqTitle => 'Domande frequenti';

  @override
  String get landingFaqLocalDataQ => 'Dove sono salvati i dati?';

  @override
  String get landingFaqLocalDataA =>
      'Sul tuo dispositivo o browser (local-first) — i tuoi dati restano tuoi. Nessun sync automatico: puoi esportare un backup JSON o salvare uno snapshot opzionale sul cloud account.';

  @override
  String get landingFaqDeskGymQ =>
      'Posso programmare da desktop e allenarmi in sala?';

  @override
  String get landingFaqDeskGymA =>
      'Sì. Costruisci la scheda da desktop, poi apri lo stesso account dal telefono in sala per registrare serie, RPE e dolore — nessuna app separata, nessuna configurazione di sync.';

  @override
  String get landingFaqFreeProQ => 'Qual è la differenza tra Gratuito e Pro?';

  @override
  String get landingFaqFreeProA =>
      'Gratuito include fino a 5 clienti e tutte le funzioni base del builder. Pro sblocca clienti illimitati, export avanzati e integrazione Hevy.';

  @override
  String get landingFaqBetaQ => 'Come accedo alla beta?';

  @override
  String get landingFaqBetaA =>
      'Registrati gratis, poi vai in Abbonamento e richiedi un codice invito oppure attiva Pro con il codice che ricevi.';

  @override
  String get landingFaqBrowserQ =>
      'Cosa succede se cancello i dati del browser?';

  @override
  String get landingFaqBrowserA =>
      'I dati locali possono andare persi. Esporta un backup JSON (o salva uno snapshot cloud) da Impostazioni prima di pulire cache o cookie.';

  @override
  String get landingFaqBillingQ => 'Come funziona il pagamento?';

  @override
  String get landingFaqBillingA =>
      'Pro si attiva via Stripe sul web. Puoi gestire rinnovo e fatturazione dalla schermata Abbonamento.';

  @override
  String get landingPwaTitle => 'Usa PowerCoach come app';

  @override
  String get landingPwaMessage =>
      'Su Chrome/Edge: menu del browser → Installa app. Su iPhone: Condividi → Aggiungi a Home.';

  @override
  String landingFooterCopyright(int year) {
    return '© $year PowerCoach Studio';
  }

  @override
  String get landingFooterPrivacy => 'Privacy';

  @override
  String get landingFooterTerms => 'Termini';

  @override
  String get subscriptionCheckoutCancel => 'Pagamento annullato.';

  @override
  String get headerLogin => 'Accedi';

  @override
  String get headerJoinNow => 'Iscriviti';

  @override
  String get registrationTitle => 'Registrati';

  @override
  String get registrationEmail => 'Email';

  @override
  String get registrationPassword => 'Password';

  @override
  String get registrationConfirmPassword => 'Conferma password';

  @override
  String get registrationSubmit => 'Registrati';

  @override
  String get registrationSuccessMessage =>
      'Controlla la tua email per confermare l\'account.';

  @override
  String get registrationSuccessReady => 'Account creato. Accesso in corso…';

  @override
  String get registrationCheckEmailTitle => 'Controlla la tua email';

  @override
  String registrationCheckEmailBody(String email) {
    return 'Abbiamo inviato un link di conferma a $email. Clicca il link, poi accedi.';
  }

  @override
  String get registrationCheckEmailSpamHint =>
      'Non trovi l\'email? Controlla anche la cartella spam.';

  @override
  String get registrationResendEmail => 'Reinvia email di conferma';

  @override
  String get registrationResendEmailSuccess => 'Email inviata di nuovo.';

  @override
  String get registrationResendEmailError =>
      'Impossibile reinviare l\'email. Riprova tra qualche minuto.';

  @override
  String get registrationGoToLogin => 'Vai al login';

  @override
  String get registrationErrorAlreadyRegistered =>
      'Esiste già un account con questa email. Prova ad accedere.';

  @override
  String get registrationErrorPasswordWeak => 'Scegli una password più sicura.';

  @override
  String get registrationErrorInvalidEmail => 'Inserisci un\'email valida.';

  @override
  String get registrationErrorPasswordMismatch => 'Le password non coincidono.';

  @override
  String get registrationErrorPasswordEmpty => 'Inserisci una password.';

  @override
  String get registrationErrorGeneric => 'Registrazione fallita. Riprova.';

  @override
  String get registrationAlreadyHaveAccount => 'Hai già un account?';

  @override
  String get registrationLoginLink => 'Accedi';

  @override
  String get registrationHeadline => 'Crea il tuo account';

  @override
  String get loginTitle => 'Accedi';

  @override
  String get loginHeadline => 'Bentornato!';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Accedi';

  @override
  String get loginForgotPassword => 'Password dimenticata?';

  @override
  String get loginNoAccount => 'Non hai un account?';

  @override
  String get loginRegisterLink => 'Registrati';

  @override
  String get loginErrorInvalidEmail => 'Inserisci un\'email valida.';

  @override
  String get loginErrorPasswordEmpty => 'Inserisci la password.';

  @override
  String get loginErrorGeneric => 'Accesso fallito. Riprova.';

  @override
  String get loginErrorInvalidCredentials =>
      'Email o password non corretti. Riprova.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Conferma l\'email prima di accedere.';

  @override
  String get loginErrorTooManyRequests =>
      'Troppi tentativi. Riprova più tardi.';

  @override
  String get loginSuccessMessage => 'Bentornato!';

  @override
  String get forgotPasswordTitle => 'Reimposta password';

  @override
  String get forgotPasswordInstruction =>
      'Inserisci la tua email e ti invieremo un link per reimpostare la password.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordSubmit => 'Invia link';

  @override
  String get forgotPasswordSuccessMessage =>
      'Controlla la tua email per il link di reset.';

  @override
  String get forgotPasswordBackToLogin => 'Torna al login';

  @override
  String get forgotPasswordError => 'Impossibile inviare l\'email. Riprova.';

  @override
  String get headerProfile => 'Profilo';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profileComingSoon => 'Pagina profilo in arrivo.';

  @override
  String get profileDisplayName => 'Nome visualizzato';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Telefono';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileAvatarUrl => 'URL avatar';

  @override
  String get profileWebsite => 'Sito web';

  @override
  String get profileSave => 'Salva';

  @override
  String get profileSavedMessage => 'Profilo salvato.';

  @override
  String get profileLoadError => 'Impossibile caricare il profilo.';

  @override
  String get profileSaveError => 'Impossibile salvare il profilo.';

  @override
  String get profileSignOut => 'Esci';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsPersonalInfo => 'Informazioni personali';

  @override
  String get settingsSubscription => 'Abbonamento';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsPersonalInfoTitle => 'Informazioni personali';

  @override
  String get settingsSubscriptionTitle => 'Abbonamento';

  @override
  String get subscriptionCurrentPlan => 'Piano attuale';

  @override
  String get subscriptionPlanFree => 'Gratuito';

  @override
  String get subscriptionPlanPro => 'Pro';

  @override
  String get subscriptionUpgrade => 'Passa a Pro';

  @override
  String get subscriptionManage => 'Gestisci abbonamento';

  @override
  String get subscriptionUpgradeMonthly => 'Pro — 12 €/mese';

  @override
  String get subscriptionUpgradeYearly => 'Pro — 99 €/anno';

  @override
  String get subscriptionCheckoutSuccess => 'Abbonamento aggiornato. Grazie!';

  @override
  String get subscriptionCheckoutError =>
      'Impossibile avviare il pagamento. Riprova.';

  @override
  String get subscriptionPortalError =>
      'Impossibile aprire il portale abbonamento.';

  @override
  String get subscriptionWebOnlyHint =>
      'La gestione abbonamento Stripe è disponibile solo sulla versione web.';

  @override
  String get subscriptionStatusActive => 'Attivo';

  @override
  String get subscriptionStatusTrialing => 'In prova';

  @override
  String get subscriptionStatusPastDue => 'Pagamento in sospeso';

  @override
  String get subscriptionStatusPastDueDetail =>
      'Aggiorna il metodo di pagamento dal portale abbonamento per evitare l\'interruzione del servizio.';

  @override
  String get subscriptionStatusGrace => 'In cancellazione';

  @override
  String subscriptionStatusGraceUntil(String date) {
    return 'Accesso Pro fino al $date.';
  }

  @override
  String subscriptionStatusRenewsOn(String date) {
    return 'Prossimo rinnovo: $date.';
  }

  @override
  String get subscriptionStatusExpired => 'Scaduto';

  @override
  String get subscriptionStatusExpiredDetail =>
      'Il tuo abbonamento Pro non è più attivo.';

  @override
  String get subscriptionStatusFree => 'Gratuito';

  @override
  String get subscriptionStatusFreeDetail =>
      'Richiedi un codice invito o inserisci quello che hai ricevuto per sbloccare Pro.';

  @override
  String get subscriptionUsageTitle => 'Utilizzo piano Gratuito';

  @override
  String subscriptionUsageCustomers(int current, int max) {
    return '$current / $max clienti attivi';
  }

  @override
  String get subscriptionUsageNearLimit =>
      'Stai per raggiungere il limite del piano Gratuito.';

  @override
  String get subscriptionUsageAtLimit =>
      'Hai raggiunto il limite di clienti attivi. Passa a Pro per aggiungerne altri.';

  @override
  String get subscriptionCompareTitle => 'Cosa include ogni piano';

  @override
  String get subscriptionCompareFeatureColumn => 'Funzione';

  @override
  String get subscriptionCompareCustomers => 'Clienti attivi';

  @override
  String subscriptionCompareCustomersFree(int max) {
    return 'Fino a $max';
  }

  @override
  String get subscriptionCompareProgressExport => 'Export CSV progressi';

  @override
  String get subscriptionCompareHevy => 'Integrazione Hevy';

  @override
  String get subscriptionCompareWorkoutExport => 'Export PDF/Excel allenamenti';

  @override
  String get subscriptionCompareNotIncluded => '—';

  @override
  String get subscriptionPromoHint =>
      'Hai un codice invito? Inseriscilo qui sotto.';

  @override
  String get subscriptionPromoCardTitle => 'Accedi a Pro con invito';

  @override
  String get subscriptionPromoCardSubtitle =>
      'Durante l\'accesso anticipato Pro è gratuito con un codice invito.';

  @override
  String get subscriptionPromoCodeLabel => 'Codice invito';

  @override
  String get subscriptionPromoCodeHint => 'Es. POWERCOACH-2026';

  @override
  String get subscriptionPromoCodeEmpty => 'Inserisci un codice invito.';

  @override
  String get subscriptionPromoRedeemButton => 'Attiva Pro';

  @override
  String get subscriptionPromoRedeemSuccess => 'Pro attivato. Buon lavoro!';

  @override
  String get subscriptionPromoRedeemError =>
      'Impossibile attivare il codice. Riprova.';

  @override
  String get subscriptionPromoAlreadyPro => 'Hai già accesso Pro.';

  @override
  String get subscriptionPromoProActiveHint =>
      'Il tuo accesso Pro è attivo tramite codice invito.';

  @override
  String get subscriptionStatusPromoActive => 'Pro (invito)';

  @override
  String get subscriptionStatusPromoActiveDetail =>
      'Accesso Pro attivato con codice invito.';

  @override
  String get subscriptionCouponRequestIntro =>
      'Non hai un codice? Puoi richiedere l\'accesso Pro.';

  @override
  String get subscriptionCouponRequestButton => 'Richiedi codice invito';

  @override
  String get subscriptionCouponRequestMessageLabel => 'Messaggio (facoltativo)';

  @override
  String get subscriptionCouponRequestMessageHint =>
      'Es. quanti clienti gestisci, come usi l\'app…';

  @override
  String get subscriptionCouponRequestSubmit => 'Invia richiesta';

  @override
  String get subscriptionCouponRequestSuccess =>
      'Richiesta inviata. Ti contatteremo via email.';

  @override
  String get subscriptionCouponRequestError =>
      'Impossibile inviare la richiesta. Riprova.';

  @override
  String get subscriptionCouponRequestPending =>
      'Hai già una richiesta in attesa. Ti risponderemo via email.';

  @override
  String get subscriptionBillingDetailsTitle => 'Fatturazione';

  @override
  String get subscriptionBillingCycleLabel => 'Ciclo';

  @override
  String get subscriptionBillingAmountLabel => 'Importo';

  @override
  String get subscriptionBillingRenewalLabel => 'Rinnovo';

  @override
  String get subscriptionBillingIntervalMonthly => 'Mensile';

  @override
  String get subscriptionBillingIntervalYearly => 'Annuale';

  @override
  String subscriptionBillingPriceMonthly(String amount) {
    return '$amount/mese';
  }

  @override
  String subscriptionBillingPriceYearly(String amount) {
    return '$amount/anno';
  }

  @override
  String get subscriptionProActionsTitle => 'Gestisci abbonamento';

  @override
  String get subscriptionProActionPaymentMethod =>
      'Aggiorna metodo di pagamento';

  @override
  String get subscriptionProActionSwitchYearly => 'Passa al piano annuale';

  @override
  String get subscriptionProActionSwitchYearlyHint =>
      'Risparmia circa 45 €/anno rispetto al mensile.';

  @override
  String get subscriptionProActionSwitchMonthly => 'Passa al piano mensile';

  @override
  String get subscriptionProActionInvoices => 'Visualizza fatture';

  @override
  String get subscriptionProActionCancel => 'Cancella abbonamento';

  @override
  String get billingAlertPastDue =>
      'Il pagamento dell\'abbonamento Pro non è andato a buon fine.';

  @override
  String get billingAlertUpdatePayment => 'Aggiorna il pagamento';

  @override
  String billingAlertGraceEnding(int days) {
    return 'L\'accesso Pro termina tra $days giorni.';
  }

  @override
  String get billingAlertManageSubscription => 'Gestisci abbonamento';

  @override
  String paywallMessageCustomersAtLimit(int current, int max) {
    return 'Hai raggiunto il limite di $current/$max clienti attivi. Passa a Pro per aggiungerne altri.';
  }

  @override
  String paywallMessageCustomersNearLimit(int current, int max) {
    return 'Hai $current/$max clienti attivi. Con Pro puoi gestirne quanti ne vuoi.';
  }

  @override
  String customerListUpgradeAtLimit(int current, int max) {
    return 'Limite raggiunto ($current/$max clienti). Passa a Pro per aggiungerne altri.';
  }

  @override
  String customerListUpgradeNearLimit(int current, int max) {
    return 'Stai per raggiungere il limite Free ($current/$max clienti). Passa a Pro.';
  }

  @override
  String get paywallTitle => 'Funzione Pro';

  @override
  String paywallMessageCustomers(int maxCustomers) {
    return 'Il piano Gratuito include fino a $maxCustomers clienti attivi. Passa a Pro per clienti illimitati.';
  }

  @override
  String get paywallMessageExport =>
      'L\'export CSV del progresso cliente è incluso in PowerCoach Pro.';

  @override
  String get paywallMessageHevy =>
      'L\'integrazione Hevy è inclusa in PowerCoach Pro.';

  @override
  String get paywallMessageWorkoutExport =>
      'L\'export PDF ed Excel degli allenamenti è incluso in PowerCoach Pro.';

  @override
  String get paywallUpgradeCta => 'Passa a Pro';

  @override
  String get paywallNotNow => 'Non ora';

  @override
  String get settingsNotificationsDescription =>
      'Promemoria locali per sessioni e clienti';

  @override
  String get settingsNotificationPermissionDenied =>
      'Le notifiche sono disattivate. Abilitale nelle impostazioni di sistema per attivare questa opzione.';

  @override
  String get reminderWebNotSupported =>
      'I promemoria non sono supportati nella versione web dell\'app.';

  @override
  String get reminderPlatformNotSupported =>
      'I promemoria non sono supportati su questa piattaforma.';

  @override
  String get reminderEnableNotificationsFirst =>
      'Attiva prima le notifiche in Impostazioni.';

  @override
  String get reminderPastTimeError => 'Scegli un orario nel futuro.';

  @override
  String get reminderSaved => 'Promemoria salvato.';

  @override
  String get reminderScheduleError =>
      'Impossibile programmare il promemoria. Riprova.';

  @override
  String reminderNotificationTitle(String customerName) {
    return 'Promemoria: $customerName';
  }

  @override
  String get reminderNotificationBody => 'Promemoria cliente programmato';

  @override
  String get reminderDashboardSessionTitle => 'Promemoria sessione';

  @override
  String get customerReminderAction => 'Imposta promemoria';

  @override
  String get settingsLanguageDescription => 'Lingua dell\'app';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSaved => 'Lingua aggiornata.';

  @override
  String get settingsBackupSectionTitle => 'Backup offline';

  @override
  String get settingsBackupSectionSubtitle =>
      'Esporta o sostituisci tutti i dati locali di questo account come file JSON — i tuoi dati restano tuoi. Utile per spostare i dati tra dispositivi; la tua chiave API Hevy non viene mai inclusa.';

  @override
  String get settingsBackupExport => 'Esporta backup';

  @override
  String get settingsBackupImport => 'Importa backup';

  @override
  String get settingsBackupImportConfirmTitle => 'Sostituire i dati locali?';

  @override
  String get settingsBackupImportConfirmMessage =>
      'Elimina tutti i dati offline per il tuo account su questo dispositivo e li sostituisce con il file di backup. Gli altri dispositivi non vengono aggiornati automaticamente. Il file deve appartenere all’account con cui hai effettuato l’accesso.';

  @override
  String get settingsBackupImportConfirmReplace => 'Sostituisci dati locali';

  @override
  String get settingsBackupExportSuccess =>
      'Backup pronto per la condivisione.';

  @override
  String get settingsBackupImportSuccess =>
      'Dati locali ripristinati dal backup.';

  @override
  String get settingsBackupErrorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get settingsBackupErrorNotSignedIn =>
      'Accedi per esportare o importare un backup.';

  @override
  String get settingsBackupErrorWrongAccount =>
      'Questo backup appartiene a un altro account.';

  @override
  String get settingsBackupErrorUnsupportedSchema =>
      'Questo formato di backup non è supportato da questa versione dell’app.';

  @override
  String get settingsBackupSectionSubtitleWeb =>
      'I dati del coach sono salvati in questo browser — restano tuoi. Esporta regolarmente un backup JSON per ripristinarli o spostarli su un altro dispositivo; la tua chiave API Hevy non viene mai inclusa.';

  @override
  String get settingsBackupErrorInvalidFile => 'File di backup non valido.';

  @override
  String get settingsCloudBackupSectionTitle => 'Backup cloud (opzionale)';

  @override
  String get settingsCloudBackupSectionSubtitle =>
      'Salva o ripristina uno snapshot manuale su Supabase Storage, visibile solo dal tuo account. Non è una sincronizzazione automatica.';

  @override
  String get settingsCloudBackupUpload => 'Salva in cloud';

  @override
  String get settingsCloudBackupRestore => 'Ripristina da cloud';

  @override
  String get settingsCloudBackupHevyNote =>
      'La chiave API Hevy resta solo su questo dispositivo e non viene mai salvata nel backup, locale o cloud.';

  @override
  String get settingsCloudBackupUploadSuccess => 'Backup caricato su cloud.';

  @override
  String get settingsCloudBackupEmpty =>
      'Nessun backup cloud trovato per questo account.';

  @override
  String get settingsCloudBackupErrorGeneric =>
      'Impossibile completare l’operazione cloud. Riprova.';

  @override
  String get settingsCloudBackupListTitle => 'Scegli un backup da ripristinare';

  @override
  String get settingsCloudBackupListEmpty => 'Nessun backup cloud disponibile.';

  @override
  String get settingsCloudBackupDeleteTooltip => 'Elimina questo backup cloud';

  @override
  String get settingsCloudBackupDeleted => 'Backup cloud eliminato.';

  @override
  String get settingsLegalSectionTitle => 'Legale e privacy';

  @override
  String get settingsLegalPrivacy => 'Informativa privacy';

  @override
  String get settingsLegalTerms => 'Termini di servizio';

  @override
  String get settingsLegalAccountDeletion => 'Cancellazione account';

  @override
  String get signOutConfirmTitle => 'Uscire e rimuovere i dati locali?';

  @override
  String get signOutConfirmMessage =>
      'Uscendo elimini clienti, piani workout e impostazioni salvati su questo dispositivo per il tuo account. Esporta un backup prima se vuoi conservarne una copia.';

  @override
  String get signOutConfirmCancel => 'Annulla';

  @override
  String get signOutConfirmExportFirst => 'Esporta backup';

  @override
  String get signOutConfirmUploadCloud => 'Carica in cloud prima di uscire';

  @override
  String get signOutConfirmProceed => 'Esci comunque';

  @override
  String get backupOnboardingTitle => 'Proteggi i tuoi dati da coach';

  @override
  String get backupOnboardingMessage =>
      'PowerCoach Studio salva clienti e piani workout su questo dispositivo. Se cancelli i dati del browser o esci, le informazioni vengono rimosse salvo backup.';

  @override
  String get backupOnboardingWebHint =>
      'Consigliamo di esportare un backup JSON da Impostazioni dopo la prima sessione e quando fai modifiche importanti.';

  @override
  String get backupOnboardingDeskGymHint =>
      'Programma da desktop, poi porta lo stesso account in sala dal telefono — un backup ti permette di portare con te i tuoi dati, senza un account cloud.';

  @override
  String get backupOnboardingOpenSettings => 'Apri impostazioni';

  @override
  String get backupOnboardingExportNow => 'Esporta backup ora';

  @override
  String get backupOnboardingGotIt => 'Ho capito';

  @override
  String get customerCreationLocalDataHint =>
      'I dati del cliente sono salvati localmente su questo dispositivo. Non viene inviata alcuna email di benvenuto.';

  @override
  String get customersTitle => 'Clienti';

  @override
  String get exerciseLibraryTitle => 'Libreria esercizi';

  @override
  String get exerciseLibraryBack => 'Indietro';

  @override
  String get exerciseLibraryImport => 'Importa';

  @override
  String get exerciseLibraryExport => 'Esporta';

  @override
  String get exerciseLibraryImportSourceTitle => 'Importa esercizi';

  @override
  String get exerciseLibraryImportSourceDefault =>
      'Importa catalogo predefinito';

  @override
  String get exerciseLibraryImportSourceDefaultSubtitle =>
      'Carica 200 esercizi comuni con varianti e gerarchia.';

  @override
  String get exerciseLibraryImportSourceCustom => 'Importa JSON personalizzato';

  @override
  String get exerciseLibraryImportSourceCustomSubtitle =>
      'Carica esercizi dal tuo file JSON.';

  @override
  String get exerciseLibraryAddExercise => 'Aggiungi esercizio';

  @override
  String get exerciseLibraryEditExercise => 'Modifica esercizio';

  @override
  String get exerciseLibraryEdit => 'Modifica';

  @override
  String get exerciseLibraryDelete => 'Elimina';

  @override
  String get exerciseLibraryPin => 'Fissa';

  @override
  String get exerciseLibraryUnpin => 'Rimuovi fissato';

  @override
  String get exerciseLibraryCancel => 'Annulla';

  @override
  String get exerciseLibrarySave => 'Salva';

  @override
  String get exerciseLibraryRetry => 'Riprova';

  @override
  String get exerciseLibraryEmpty => 'Nessun esercizio custom ancora.';

  @override
  String get exerciseLibraryEmptyHint =>
      'Aggiungi esercizi e varianti (es. Squat → Squat low bar) per usarli nei piani.';

  @override
  String get exerciseLibraryTabExercises => 'Esercizi';

  @override
  String get exerciseLibraryTabMobilityExercises => 'Esercizi di mobilità';

  @override
  String get exerciseLibraryEmptyMobility =>
      'Nessun esercizio di mobilità ancora.';

  @override
  String get exerciseLibraryEmptyMobilityHint =>
      'Aggiungi esercizi di mobilità per usarli nelle routine di mobilità.';

  @override
  String get exerciseLibraryExportEmpty =>
      'Niente da esportare. Aggiungi prima degli esercizi.';

  @override
  String get exerciseLibraryImportInvalidFormat =>
      'File non valido. Usa un array JSON di esercizi.';

  @override
  String get exerciseLibraryImportSuccess => 'Importazione completata.';

  @override
  String exerciseLibraryImportSuccessCount(int count) {
    return 'Importazione completata: $count elementi.';
  }

  @override
  String get exerciseLibraryDeleteTitle => 'Elimina esercizio';

  @override
  String exerciseLibraryDeleteConfirm(Object name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get exerciseLibraryDeleteHasChildren =>
      'Rimuovi prima le varianti (figli), poi elimina questo.';

  @override
  String get exerciseLibraryNameHint => 'Nome esercizio';

  @override
  String get exerciseLibraryDescriptionHint => 'Descrizione (opzionale)';

  @override
  String get exerciseLibraryMobilityToggle => 'Esercizio di mobilità';

  @override
  String get exerciseLibraryParentLabel => 'Esercizio padre (variante di)';

  @override
  String get exerciseLibraryParentNone => 'Nessuno';

  @override
  String get exerciseLibraryAddVariant => 'Aggiungi variante';

  @override
  String get placeholderBackToDashboard => 'Torna alla Dashboard';

  @override
  String get customersEmptyTitle => 'Nessun cliente ancora';

  @override
  String get customersEmptyMessage =>
      'Facciamo crescere il tuo studio! Inizia aggiungendo il tuo primo cliente per tracciare i progressi e gestire gli allenamenti.';

  @override
  String get customersAddCustomer => 'Aggiungi cliente';

  @override
  String get customersAddFirstClient => 'Aggiungi il tuo primo cliente';

  @override
  String get customersImportContacts => 'Importa dai contatti';

  @override
  String get customersImportContactsDenied =>
      'È necessario il permesso contatti per importare.';

  @override
  String get customersNewCustomer => 'Nuovo cliente';

  @override
  String get customerName => 'Nome';

  @override
  String get customerNameRequired => 'Il nome è obbligatorio';

  @override
  String get customerEmail => 'Email';

  @override
  String get customerPhone => 'Telefono';

  @override
  String get customerDateOfBirth => 'Data di nascita';

  @override
  String get customerHeight => 'Altezza (cm)';

  @override
  String get customerWeight => 'Peso (kg)';

  @override
  String get customerNotes => 'Note';

  @override
  String get customerGoals => 'Obiettivi';

  @override
  String get customerSave => 'Salva';

  @override
  String get customerCancel => 'Annulla';

  @override
  String get customerEdit => 'Modifica';

  @override
  String get customerDelete => 'Elimina';

  @override
  String get customerDeleteConfirmTitle => 'Eliminare il cliente?';

  @override
  String get customerDeleteConfirmMessage =>
      'Questa azione non può essere annullata.';

  @override
  String get customersLoadError => 'Impossibile caricare i clienti.';

  @override
  String get customerSaveError => 'Impossibile salvare il cliente.';

  @override
  String get customerDeleteError => 'Impossibile eliminare il cliente.';

  @override
  String get customersSessionExpired => 'Sessione scaduta. Accedi di nuovo.';

  @override
  String get customersRetry => 'Riprova';

  @override
  String get customerDeletedMessage => 'Cliente eliminato.';

  @override
  String get workoutExport => 'Esporta';

  @override
  String get workoutExportPdf => 'Esporta in PDF';

  @override
  String get workoutExportExcel => 'Esporta in Excel';

  @override
  String get workoutExportJson => 'Esporta JSON';

  @override
  String get workoutImportJson => 'Importa JSON';

  @override
  String get workoutImportJsonSuccess => 'Piano importato dal file JSON.';

  @override
  String get workoutImportJsonError => 'File JSON non valido o non supportato.';

  @override
  String get workoutExportSuccess => 'Download avviato.';

  @override
  String get workoutExportError => 'Esportazione fallita. Riprova.';

  @override
  String get workoutExportPdfSheetTitle => 'Esporta PDF';

  @override
  String get workoutPdfLayoutCanonical => 'Completo (per settimana)';

  @override
  String get workoutPdfLayoutDense => 'Denso (consigliato)';

  @override
  String get workoutPdfLayoutDenseDescription =>
      'Layout compatto per giorno con colonne per settimana, meno pagine e prescrizioni su una riga.';

  @override
  String get workoutExportPdfGenerateAndDownload => 'Genera e scarica';

  @override
  String get workoutPdfIncludeMobility => 'Includi mobilità / riscaldamento';

  @override
  String get workoutPdfSheetSubtitle =>
      'Scegli il layout del documento. Il PDF usa intestazione coach e tabelle ottimizzate per la stampa.';

  @override
  String get pdfBrandName => 'PowerCoach Studio';

  @override
  String get pdfCoachPrefix => 'Coach:';

  @override
  String get pdfColExercise => 'Esercizio';

  @override
  String get pdfColSets => 'Ser.';

  @override
  String get pdfColReps => 'Rip.';

  @override
  String get pdfColLoadRpe => 'Carico';

  @override
  String get pdfColNotes => 'Note';

  @override
  String get pdfMobilitySection => 'Mobilità';

  @override
  String get pdfSuperset => 'Superset';

  @override
  String pdfDayNumber(int day) {
    return 'Giorno $day';
  }

  @override
  String get pdfEmptyValue => '-';

  @override
  String get pdfFooterDisclaimer =>
      'Documento riservato al cliente indicato. Consultare un medico prima di iniziare un nuovo programma di esercizio.';

  @override
  String pdfPageOf(int current, int total) {
    return 'Pagina $current di $total';
  }

  @override
  String pdfGeneratedOn(String date) {
    return 'Generato il $date';
  }

  @override
  String get pdfExportGenerating => 'Generazione PDF in corso…';

  @override
  String pdfMeasurementRecordCount(int count) {
    return '$count rilevazioni';
  }

  @override
  String pdfDenseWeekShort(int n) {
    return 'S$n';
  }

  @override
  String get pdfDenseAllWeeks => 'tutte';

  @override
  String get pdfDenseDitto => '\"';

  @override
  String pdfDenseWeekLegendEntry(int n, String name) {
    return 'S$n = $name';
  }

  @override
  String pdfDenseWeeksSpan(int first, int last) {
    return 'S$first-S$last';
  }

  @override
  String get pdfDenseLegend =>
      'S1-S4 = tutte le settimane | \" = stessa prescrizione';

  @override
  String pdfClientPlanFor(String name) {
    return 'Piano per: $name';
  }

  @override
  String pdfPlanPeriod(String start, String end) {
    return '$start - $end';
  }

  @override
  String pdfPlanPeriodOpen(String start) {
    return 'Dal $start';
  }

  @override
  String get workoutExerciseShortNameLabel => 'Nome PDF (facoltativo)';

  @override
  String get workoutExerciseScopeAllWeeks =>
      'Stessa prescrizione tutte le settimane';

  @override
  String get mobilityShortTitleLabel => 'Titolo breve PDF (facoltativo)';

  @override
  String get mobilitySectionScheduleHintLabel =>
      'Frequenza / orario (facoltativo)';

  @override
  String get workoutShare => 'Condividi';

  @override
  String get workoutStartingWeek => 'Settimana iniziale';

  @override
  String get workoutStartingWeekHint => 'Settimana 1, 2, 3...';

  @override
  String get workoutRoutineStartDate => 'Data di inizio';

  @override
  String get workoutRoutineStartDatePlaceholder => 'Tocca per scegliere';

  @override
  String get workoutRoutineEndDate => 'Data di fine';

  @override
  String get workoutRoutineEndDatePlaceholder => 'Tocca per scegliere';

  @override
  String get workoutRoutineCurrentWeek => 'Settimana corrente';

  @override
  String get workoutRoutineCurrentWeekHint => 'Seleziona settimana';

  @override
  String get workoutPlanPhaseLabel => 'Fase';

  @override
  String get workoutPlanPhaseHint => 'es. Ipertrofia, Forza, Deload';

  @override
  String get workoutPlanTagsLabel => 'Tag';

  @override
  String get workoutPlanTagsHint => 'es. upper body, rehab spalla';

  @override
  String get workoutPlanNotesLabel => 'Note piano';

  @override
  String get workoutPlanNotesHint => 'Note interne per questo piano';

  @override
  String get workoutBuilderDetailsOptionsSection => 'Opzioni';

  @override
  String get workoutBuilderDetailsDatesSection => 'Date e settimana';

  @override
  String get workoutBuilderDetailsMetadataSection => 'Metadati';

  @override
  String get workoutBuilderAddSheetExerciseSection => 'Esercizio';

  @override
  String get workoutBuilderAddSheetSetsSection => 'Serie';

  @override
  String get workoutBuilderAddSheetNotesSection => 'Note';

  @override
  String get workoutCreateNewFromThis => 'Crea nuovo workout da questo';

  @override
  String get workoutDuplicateTitle => 'Duplica workout';

  @override
  String get workoutDuplicateNameHint => 'Nome della copia';

  @override
  String get workoutDuplicateAction => 'Duplica';

  @override
  String get workoutFollowUpTitle => 'Crea workout follow-up';

  @override
  String get workoutFollowUpNameHint => 'Nome workout';

  @override
  String get workoutFollowUpStartDateOptional => 'Data inizio opzionale';

  @override
  String get workoutFollowUpStartDateClear => 'Rimuovi data';

  @override
  String get workoutFollowUpCreateAction => 'Crea follow-up';

  @override
  String get workoutFollowUpCreatedMessage => 'Workout follow-up creato.';

  @override
  String get workoutFollowUpDefaultSuffix => 'Follow-up';

  @override
  String workoutDuplicateOf(Object name) {
    return 'Copia di $name';
  }

  @override
  String get workoutDuplicatedMessage => 'Workout creato.';

  @override
  String get workoutNewPlanName => 'Nuovo workout';

  @override
  String get workoutDelete => 'Elimina workout';

  @override
  String get workoutDeleteConfirmTitle => 'Eliminare il workout?';

  @override
  String get workoutDeleteConfirmMessage =>
      'Questa azione non può essere annullata.';

  @override
  String get workoutDeletedMessage => 'Workout eliminato.';

  @override
  String get workoutDeleteError => 'Impossibile eliminare il workout.';

  @override
  String get workoutPlanArchiveAction => 'Archivia';

  @override
  String get workoutPlanUnarchiveAction => 'Ripristina';

  @override
  String get workoutPlanCompleteAction => 'Segna completato';

  @override
  String get workoutPlanStatusArchived => 'Archiviato';

  @override
  String get workoutPlanStatusCompleted => 'Completato';

  @override
  String get workoutPlanStatusActive => 'Attivo';

  @override
  String get workoutPlanStatusDraft => 'Bozza';

  @override
  String get mobilityAddExercise => 'Aggiungi esercizio mobilità';

  @override
  String get mobilityCreateNew => 'Crea nuovo';

  @override
  String get mobilityFromMobilityLibrary => 'Da library mobilità';

  @override
  String get mobilityFromExerciseLibrary => 'Da library esercizi';

  @override
  String get mobilitySaveToLibrary => 'Salva nella library mobilità';

  @override
  String get mobilityTitle => 'Titolo';

  @override
  String get mobilitySubtitle => 'Sottotitolo';

  @override
  String get customerDetailOverview => 'Panoramica';

  @override
  String get customerDetailMeasurements => 'Misure';

  @override
  String get customerDetailRecords => 'Record';

  @override
  String get recordsEmpty => 'Nessun record esercizi ancora.';

  @override
  String get recordsEmptyHint =>
      'Registra un valore per un esercizio custom (es. 1RM, ripetizioni) e aggiungi aggiornamenti nel tempo.';

  @override
  String get recordAdd => 'Aggiungi record';

  @override
  String get recordAddUpdate => 'Aggiungi aggiornamento';

  @override
  String get recordValue => 'Valore';

  @override
  String get recordUnit => 'Unità';

  @override
  String get recordDate => 'Data';

  @override
  String get recordNote => 'Nota (opzionale)';

  @override
  String get recordUnitKg => 'kg';

  @override
  String get recordUnitReps => 'rip';

  @override
  String get recordUnitSec => 'sec';

  @override
  String get recordUnitMin => 'min';

  @override
  String get recordUnitOther => 'Altro';

  @override
  String get recordDeleteConfirm => 'Eliminare questo record?';

  @override
  String get recordSaved => 'Record salvato.';

  @override
  String get recordSaveError => 'Impossibile salvare il record.';

  @override
  String get recordDeleted => 'Record eliminato.';

  @override
  String get recordDeleteError => 'Impossibile eliminare il record.';

  @override
  String get recordSelectExercise => 'Seleziona esercizio';

  @override
  String get recordSearchExerciseHint => 'Cerca per nome...';

  @override
  String get recordDeleteButton => 'Elimina record';

  @override
  String get workoutBuilderClientRecord => 'Record cliente';

  @override
  String get workoutBuilderNoExerciseRecord =>
      'Nessun record per questo esercizio.';

  @override
  String get workoutBuilderLoadPercentGuideTitle =>
      'Intensità tipiche powerlifting';

  @override
  String get workoutBuilderLoadPercentGuideIntroMass =>
      'Carico per ogni percentuale dell’ultimo record.';

  @override
  String get workoutBuilderLoadPercentGuideIntroReps =>
      'Ripetizioni indicative per serie a ogni % del massimo registrato (orientamento).';

  @override
  String workoutBuilderLoadPercentGuideRow(
    String percent,
    String weight,
    String unit,
  ) {
    return '$percent% — $weight $unit';
  }

  @override
  String get workoutBuilderLoadPercentGuideBody =>
      '100% — massimale / ~1 rip\n95% — ~2 rip\n90% — ~4 rip\n85% — ~6 rip\n80% — ~8 rip\n75% — ~10 rip\n70% — ~12 rip\n65% — ~15 rip\n60% — ~18+ rip\n55% — lavoro accessori\n50% — recupero / tecnica';

  @override
  String get workoutBuilderLoadPercentCalculator => 'Carico da percentuale';

  @override
  String get workoutBuilderLoadPercentFieldLabel => 'Percentuale';

  @override
  String get workoutBuilderLoadPercentFieldHint => 'es. 77,5';

  @override
  String get workoutBuilderLoadPercentInvalid =>
      'Inserisci un numero tra 1 e 100.';

  @override
  String get workoutBuilderLoadPercentMassOnly =>
      'Registra un peso (kg o lb) per usare il calcolatore percentuali.';

  @override
  String workoutBuilderLoadPercentResult(
    String weight,
    String unit,
    String percent,
  ) {
    return '$weight $unit ($percent% del record)';
  }

  @override
  String get workoutBuilderTitle => 'Editor scheda';

  @override
  String get workoutBuilderPlanSaved => 'Piano salvato';

  @override
  String get workoutBuilderRoutineSaved => 'Routine salvata';

  @override
  String get workoutEditorUnsavedTitle => 'Modifiche non salvate';

  @override
  String get workoutEditorUnsavedMessage =>
      'Hai modifiche non salvate. Vuoi salvarle prima di uscire?';

  @override
  String get workoutEditorSaveAndExit => 'Salva ed esci';

  @override
  String get workoutEditorDiscard => 'Esci senza salvare';

  @override
  String get workoutEditorCancel => 'Annulla';

  @override
  String get workoutEditorAutosaving => 'Salvataggio...';

  @override
  String get workoutEditorSavedState => 'Salvato';

  @override
  String get workoutEditorUnsavedState => 'Non salvato';

  @override
  String get workoutEditorSaveFailedState => 'Salvataggio fallito';

  @override
  String get workoutEditorRetrySave => 'Riprova';

  @override
  String get workoutEditorAutosaveFailed =>
      'Salvataggio automatico non riuscito. Puoi continuare a modificare e riprovare.';

  @override
  String get workoutEditorAutosaveHint =>
      'Le modifiche vengono salvate automaticamente. Usa Salva per forzare il salvataggio.';

  @override
  String get workoutBuilderWeekMenuTooltip =>
      'Azioni sulla settimana selezionata';

  @override
  String get workoutBuilderDayMenuTooltip => 'Azioni sul giorno selezionato';

  @override
  String get workoutBuilderExerciseMenuTooltip => 'Azioni sull\'esercizio';

  @override
  String get workoutBuilderEditSectionTitle => 'Modifica sezione';

  @override
  String get workoutBuilderDeleteSection => 'Elimina sezione';

  @override
  String get workoutBuilderSectionNameLabel => 'Nome sezione';

  @override
  String get workoutBuilderDeleteWeekTitle => 'Eliminare la settimana?';

  @override
  String get workoutBuilderDeleteWeekMessage =>
      'Verranno rimossi questa settimana, tutti i giorni e gli esercizi. Operazione irreversibile.';

  @override
  String get workoutBuilderRenameDayTitle => 'Rinomina giorno';

  @override
  String get workoutBuilderDayNameLabel => 'Nome giorno';

  @override
  String get workoutBuilderRenameWeekTitle => 'Rinomina settimana';

  @override
  String get workoutBuilderWeekNameLabel => 'Nome settimana';

  @override
  String get workoutBuilderDuplicateWeekTitle => 'Duplica settimana';

  @override
  String get workoutBuilderDuplicateWeekHint => 'Nome della nuova settimana';

  @override
  String get workoutBuilderEditMobilityExerciseTitle =>
      'Modifica esercizio mobilità';

  @override
  String get workoutBuilderAddMobilityExerciseTitle =>
      'Aggiungi esercizio mobilità';

  @override
  String workoutBuilderWeekNumbered(int n) {
    return 'Settimana $n';
  }

  @override
  String workoutBuilderDayNumbered(int n) {
    return 'Giorno $n';
  }

  @override
  String workoutBuilderSectionNumbered(int n) {
    return 'Sezione $n';
  }

  @override
  String get workoutBuilderNewExerciseDefault => 'Nuovo esercizio';

  @override
  String get workoutBuilderNameCopySuffix => ' (copia)';

  @override
  String get workoutBuilderRoutineNameLabel => 'NOME ROUTINE';

  @override
  String get workoutBuilderRoutineNameHint => 'Aggiungi titolo routine';

  @override
  String get workoutBuilderMobilityRoutineTitle => 'Routine di mobilità';

  @override
  String get workoutBuilderAddShort => 'Aggiungi';

  @override
  String get workoutBuilderSectionHeading => 'Sezione';

  @override
  String get workoutBuilderAddExercise => 'Aggiungi esercizio';

  @override
  String get workoutBuilderAddSet => 'Aggiungi serie';

  @override
  String get workoutBuilderPrescriptionPlaceholder => 'Aggiungi serie';

  @override
  String get workoutBuilderAddExerciseTitle => 'Aggiungi esercizio';

  @override
  String get workoutBuilderEditExerciseTitle => 'Modifica esercizio';

  @override
  String get workoutBuilderExerciseLabel => 'Esercizio';

  @override
  String get workoutBuilderExerciseLoadError =>
      'Impossibile caricare la libreria esercizi.';

  @override
  String get workoutBuilderExerciseRetry => 'Riprova';

  @override
  String get workoutBuilderFromLibrary => 'Da libreria';

  @override
  String get workoutBuilderCreateNew => 'Crea nuovo';

  @override
  String get workoutBuilderCouldNotCreateExercise =>
      'Impossibile creare l’esercizio. Riprova o aggiungi senza salvare in libreria.';

  @override
  String get workoutBuilderEnterNameOrSelect =>
      'Inserisci un nome o seleziona un esercizio.';

  @override
  String get workoutBuilderSelectLibraryExercise =>
      'Seleziona un esercizio dalla libreria, oppure digita il nome esatto.';

  @override
  String get workoutBuilderMultiSetBlockHeader => 'Serie (Set × Rip + Carico)';

  @override
  String get workoutBuilderSetLabel => 'Set';

  @override
  String get workoutBuilderSetsLabel => 'Serie';

  @override
  String get workoutBuilderRepsLabel => 'Rip';

  @override
  String get workoutBuilderLoadLabel => 'Carico';

  @override
  String get workoutBuilderRpeOrLoadLabel => 'RPE / Carico';

  @override
  String get workoutBuilderNoteOptionalLabel => 'Note (facoltative)';

  @override
  String get workoutBuilderNameLabel => 'Nome';

  @override
  String get workoutBuilderNoteLabel => 'Note';

  @override
  String get workoutBuilderEditSetTitle => 'Modifica serie';

  @override
  String get workoutBuilderTrainingProgram => 'Programma di allenamento';

  @override
  String get workoutBuilderNewWeek => 'Nuova settimana';

  @override
  String get workoutBuilderDuplicateWeek => 'Duplica settimana';

  @override
  String get workoutBuilderRenameWeekMenu => 'Rinomina settimana';

  @override
  String get workoutBuilderDeleteWeekMenu => 'Elimina settimana';

  @override
  String get workoutBuilderClone => 'Clona';

  @override
  String workoutBuilderAddDayToWeek(int n) {
    return 'Aggiungi giorno alla settimana $n';
  }

  @override
  String get workoutBuilderNoWeeksYet =>
      'Ancora nessuna settimana. Aggiungine una sopra.';

  @override
  String get workoutBuilderSuperSetHeading => 'SUPER SET';

  @override
  String get builderSupersetPanelTitle => 'Gestisci superset';

  @override
  String get builderSupersetAddExercise => 'Aggiungi esercizio al superset';

  @override
  String get builderSupersetEmpty => 'Nessun esercizio in questo superset.';

  @override
  String get builderSupersetPrescriptionLabel =>
      'Prescrizione (esercizio guida)';

  @override
  String get builderSupersetManage => 'Gestisci';

  @override
  String get workoutBuilderDeleteDayMenu => 'Elimina giorno';

  @override
  String get workoutBuilderNewSuperset => 'Nuovo superset';

  @override
  String get workoutBuilderRemoveFromSuperset => 'Rimuovi dal superset';

  @override
  String get workoutBuilderTabTraining => 'Allenamento';

  @override
  String get workoutBuilderTabMobility => 'Mobilità';

  @override
  String get workoutBuilderTabDetails => 'Dettagli';

  @override
  String get workoutBuilderNotePlaceholder => 'Aggiungi nota…';

  @override
  String get workoutBuilderMoreActions => 'Altre azioni';

  @override
  String get workoutBuilderMoveUp => 'Sposta su';

  @override
  String get workoutBuilderMoveDown => 'Sposta giù';

  @override
  String get workoutBuilderEditExercise => 'Modifica esercizio';

  @override
  String get workoutBuilderDeleteExercise => 'Elimina esercizio';

  @override
  String get workoutBuilderDuplicateExercise => 'Duplica esercizio';

  @override
  String get workoutBuilderExerciseRemoved => 'Esercizio eliminato';

  @override
  String get workoutBuilderUndo => 'Annulla';

  @override
  String get workoutBuilderWeekRemoved => 'Settimana rimossa';

  @override
  String get workoutBuilderSupersetUnlinked => 'Rimosso dal superset';

  @override
  String get workoutBuilderMobilityItemRemoved => 'Elemento mobilità rimosso';

  @override
  String get workoutBuilderOnboardingTitle => 'Primi passi nel workout builder';

  @override
  String get workoutBuilderOnboardingStep1 =>
      'Scegli settimana e giorno nella tab Allenamento.';

  @override
  String get workoutBuilderOnboardingStep2 =>
      'Aggiungi esercizi dalla libreria o creane di nuovi.';

  @override
  String get workoutBuilderOnboardingStep3 =>
      'Imposta date inizio/fine in Dettagli per il calendario.';

  @override
  String get workoutBuilderOnboardingDismiss => 'Ho capito';

  @override
  String get workoutBuilderCompactAddSearchHint => 'Cerca esercizi…';

  @override
  String get workoutBuilderCompactAddRecent => 'Recenti e pin';

  @override
  String get workoutBuilderCompactAddEmpty =>
      'Nessun esercizio corrisponde alla ricerca.';

  @override
  String get workoutBuilderCompactAddFullEditor => 'Modifica prescrizione';

  @override
  String get workoutBuilderIncludeMobilityTab => 'Includi tab Mobilità';

  @override
  String get workoutBuilderIncludeMobilityTabHint =>
      'Mostra la sezione mobilità insieme ad allenamento e dettagli.';

  @override
  String get workoutBuilderDayHistory => 'Storico';

  @override
  String get workoutBuilderSessionActionsTooltip => 'Azioni sessione';

  @override
  String get workoutBuilderSessionMenuLabel => 'Sessione';

  @override
  String workoutBuilderRoutineTitleFromCustomer(String name) {
    return 'Aggiungi titolo · $name';
  }

  @override
  String get workoutDiarySessionFilterActive =>
      'Sessioni per questo giorno del piano';

  @override
  String get workoutBuilderNavLibrary => 'Libreria';

  @override
  String get workoutBuilderNavBuilder => 'Builder';

  @override
  String get workoutBuilderNavDiary => 'Diario';

  @override
  String get workoutBuilderNavStats => 'Statistiche';

  @override
  String get workoutBuilderWeeksLabel => 'Settimane';

  @override
  String get workoutBuilderDaysLabel => 'Giorni';

  @override
  String get workoutBuilderCalendarWeekdayLabel => 'Giorno calendario';

  @override
  String get workoutBuilderCalendarWeekdayHint =>
      'Giorno della settimana usato per pianificare questa sessione nel calendario.';

  @override
  String get workoutBuilderScheduledWeekdayFlexible => 'Libero';

  @override
  String get workoutBuilderScheduledWeekdayFlexibleHint =>
      'Nessun giorno fisso — l\'atleta può allenarsi quando preferisce.';

  @override
  String get workoutBuilderAddDayChip => 'Giorno';

  @override
  String get workoutBuilderNoDaysInWeek => 'Nessun giorno in questa settimana.';

  @override
  String get workoutBuilderDeleteDayTitle => 'Eliminare il giorno?';

  @override
  String get workoutBuilderDeleteDayMessage =>
      'Verranno rimossi tutti gli esercizi di questo giorno.';

  @override
  String get workoutBuilderSwipeDayHint =>
      'Scorri un giorno verso l\'alto per eliminarlo';

  @override
  String workoutBuilderExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esercizi',
      one: '1 esercizio',
      zero: 'Nessun esercizio',
    );
    return '$_temp0';
  }

  @override
  String get workoutBuilderSaveToPersistHint =>
      'Salva la scheda per associarla al cliente. Fino ad allora le modifiche restano solo in memoria.';

  @override
  String get workoutBuilderSaveNowAction => 'Salva ora';

  @override
  String get customerNewWorkoutSheetTitle => 'Nuova scheda';

  @override
  String get customerNewWorkoutBlank => 'Scheda vuota';

  @override
  String get customerNewWorkoutBlankHint => 'Parti da zero nel builder';

  @override
  String get customerNewWorkoutFromTemplate => 'Da template libreria';

  @override
  String get customerNewWorkoutFromTemplateHint => 'Usa un modello salvato';

  @override
  String get customerNewWorkoutDuplicateExisting => 'Duplica piano esistente';

  @override
  String get customerNewWorkoutDuplicateExistingHint =>
      'Copia una scheda di questo cliente';

  @override
  String get customerNewWorkoutNoPlansToDuplicate =>
      'Nessuna scheda da duplicare per questo cliente.';

  @override
  String get customerNewWorkoutDuplicatePickTitle =>
      'Scegli la scheda da duplicare';

  @override
  String get customerNewWorkoutGuided => 'Guida guidata';

  @override
  String get customerNewWorkoutGuidedHint =>
      'Nome, settimane, giorni e split preimpostato';

  @override
  String get workoutNewPlanWizardTitle => 'Crea scheda guidata';

  @override
  String get workoutNewPlanWizardBack => 'Indietro';

  @override
  String get workoutNewPlanWizardNext => 'Avanti';

  @override
  String get workoutNewPlanWizardCreate => 'Crea scheda';

  @override
  String get workoutNewPlanWizardNameRequired =>
      'Inserisci un nome per la scheda.';

  @override
  String get workoutNewPlanWizardNameLabel => 'Nome scheda';

  @override
  String get workoutNewPlanWizardStepNameTitle => 'Come si chiama la scheda?';

  @override
  String get workoutNewPlanWizardStepNameHint =>
      'Es. Ipertrofia estate, Pre-gara, Mesociclo 1…';

  @override
  String get workoutNewPlanWizardStepWeeksTitle => 'Quante settimane?';

  @override
  String get workoutNewPlanWizardStepWeeksHint =>
      'Puoi aggiungerne o rimuoverne anche dopo nel builder.';

  @override
  String get workoutNewPlanWizardStepDaysTitle => 'Quanti giorni a settimana?';

  @override
  String get workoutNewPlanWizardStepDaysHint =>
      'Scegli quanti slot allenamento vuoi per ogni settimana.';

  @override
  String get workoutNewPlanWizardStepPresetTitle => 'Che tipo di split?';

  @override
  String get workoutNewPlanWizardStepPresetHint =>
      'Generiamo giorni vuoti con nomi suggeriti; potrai rinominarli.';

  @override
  String get workoutNewPlanWizardPresetFullBody => 'Full body';

  @override
  String get workoutNewPlanWizardPresetFullBodyHint =>
      'Giorni A/B/C… tutto il corpo';

  @override
  String get workoutNewPlanWizardPresetUpperLower => 'Upper / Lower';

  @override
  String get workoutNewPlanWizardPresetUpperLowerHint =>
      'Alternanza parte alta e bassa';

  @override
  String get workoutNewPlanWizardPresetPpl => 'Push / Pull / Legs';

  @override
  String get workoutNewPlanWizardPresetPplHint =>
      'Ciclo spinta, trazione, gambe';

  @override
  String get workoutPdfPreviewTitle => 'Anteprima PDF';

  @override
  String get workoutPdfPreviewMessage =>
      'Il PDF è pronto. Apri l\'anteprima in una nuova scheda o scaricalo.';

  @override
  String get workoutPdfPreviewOpen => 'Apri anteprima';

  @override
  String get workoutPdfPreviewDownload => 'Scarica';

  @override
  String get workoutPdfPreviewOpened =>
      'Anteprima PDF aperta in una nuova scheda.';

  @override
  String get customerTabWorkouts => 'Workout';

  @override
  String get dashboardWorkoutBuilderDraft => 'Builder bozza';

  @override
  String get workoutBuilderSandboxBanner =>
      'Bozza locale — non assegnata a un cliente';

  @override
  String get workoutBuilderSandboxBannerHint =>
      'Salva su un cliente per usarla nel programma.';

  @override
  String get workoutBuilderAssignToCustomer => 'Assegna a cliente';

  @override
  String get workoutBuilderAssignDraftSuccess => 'Scheda assegnata al cliente.';

  @override
  String get workoutBuilderLogSession => 'Registra sessione';

  @override
  String get workoutBuilderLogSessionSuccess => 'Sessione registrata.';

  @override
  String get workoutBuilderCloneDayToTarget => 'Duplica su…';

  @override
  String get workoutBuilderCloneDayTargetTitle => 'Duplica giorno su';

  @override
  String get workoutBuilderDayCoachingNoteTitle => 'Nota coaching';

  @override
  String get workoutBuilderDayCoachingNoteLabel => 'Nota per questo giorno';

  @override
  String get workoutBuilderDayCoachingNoteHint =>
      'es. focus, cue, indicazioni riscaldamento';

  @override
  String workoutBuilderProgressionIncreaseLoad(String value) {
    return 'Suggerimento: aumenta il carico a $value';
  }

  @override
  String get workoutBuilderProgressionIncreaseLoadGeneric =>
      'Suggerimento: valuta un piccolo aumento di carico';

  @override
  String workoutBuilderProgressionIncreaseReps(String value) {
    return 'Suggerimento: punta a $value ripetizioni';
  }

  @override
  String get workoutBuilderProgressionApply => 'Applica';

  @override
  String get workoutBuilderReadOnlyBanner =>
      'Solo lettura — duplica la scheda per modificarla.';

  @override
  String get planScheduleEmptyHint => 'Imposta data di inizio';

  @override
  String get workoutBuilderEmptyDayCta => 'Aggiungi esercizio';

  @override
  String get workoutActionFailed => 'Operazione non riuscita. Riprova.';

  @override
  String get workoutPlansLoadError =>
      'Impossibile caricare le schede del cliente.';

  @override
  String get workoutDiaryLoadError =>
      'Impossibile caricare il diario allenamenti.';

  @override
  String get workoutTemplateOpenPlanAction => 'Apri piano';

  @override
  String get measurementsEmpty => 'Nessuna misura ancora';

  @override
  String get measurementsEmptyHint =>
      'Aggiungi una misura per tracciare 1RM, composizione corporea e circonferenze.';

  @override
  String get measurementAdd => 'Aggiungi misura';

  @override
  String get measurementEdit => 'Modifica misura';

  @override
  String get measurementDate => 'Data';

  @override
  String get measurement1RM => '1RM (kg)';

  @override
  String get measurementSquat => 'Squat';

  @override
  String get measurementBench => 'Panca piana';

  @override
  String get measurementDeadlift => 'Stacco';

  @override
  String get measurementSkinfolds => 'Pliche (mm)';

  @override
  String get measurementBodyFat => 'Massa grassa %';

  @override
  String get measurementMuscleMass => 'Massa muscolare (kg)';

  @override
  String get measurementCircumferences => 'Circonferenze (cm)';

  @override
  String get measurementChest => 'Petto';

  @override
  String get measurementWaist => 'Vita';

  @override
  String get measurementArms => 'Braccia';

  @override
  String get measurementThighs => 'Cosce';

  @override
  String get measurementNotes => 'Note';

  @override
  String get measurementSaved => 'Misura salvata.';

  @override
  String get measurementSaveError => 'Impossibile salvare la misura.';

  @override
  String get measurementDeleted => 'Misura eliminata.';

  @override
  String get measurementDeleteError => 'Impossibile eliminare la misura.';

  @override
  String get measurementDeleteConfirm => 'Eliminare questa misura?';

  @override
  String get measurementHistoryTitle => 'Storico misurazioni';

  @override
  String get measurementHistoryMetricLabel => 'Metrica';

  @override
  String get measurementHistoryNoMetricData =>
      'Nessun valore registrato per questa metrica.';

  @override
  String get measurementHistoryLoadError =>
      'Impossibile caricare lo storico misurazioni.';

  @override
  String get measurementHistoryCompareTitle => 'Confronto periodi';

  @override
  String get measurementHistoryCompareSubtitle =>
      'Ultimi 30 giorni vs 30 giorni precedenti';

  @override
  String get measurementHistoryCompareRecent => 'Ultimi 30 giorni';

  @override
  String get measurementHistoryComparePrevious => '30 giorni precedenti';

  @override
  String get measurementHistoryCompareInsufficient =>
      'Aggiungi altre misure per confrontare i periodi.';

  @override
  String get measurementHistoryCompareNoData => 'Nessun dato';

  @override
  String measurementHistoryCompareDelta(String metric, String delta) {
    return 'Variazione $metric: $delta';
  }

  @override
  String measurementHistoryCompareSampleCount(int count) {
    return '$count rilevazioni';
  }

  @override
  String get measurementHistoryOpen => 'Apri storico';

  @override
  String get customerNotesTitle => 'Note cliente';

  @override
  String customerNotesTitleFor(String customerName) {
    return 'Note — $customerName';
  }

  @override
  String get customerNotesHint => 'Scrivi una nota per questo cliente…';

  @override
  String get customerNotesEmpty =>
      'Nessuna nota ancora. Aggiungi follow-up, infortuni o preferenze.';

  @override
  String get customerNotesSend => 'Invia';

  @override
  String get customerNotesOpen => 'Apri note';

  @override
  String get customerNotesEmptyBody => 'Il messaggio non può essere vuoto.';

  @override
  String get customerNotesSendError => 'Impossibile salvare la nota.';

  @override
  String get customerNotesLoadError => 'Impossibile caricare le note.';

  @override
  String get customerNotesAttachPhoto => 'Allega foto';

  @override
  String get customerNotesAttachSoon =>
      'Gli allegati foto arriveranno in un aggiornamento successivo.';

  @override
  String get measurementExportCsv => 'Esporta CSV';

  @override
  String get measurementExportPdf => 'Esporta PDF';

  @override
  String get measurementExportSuccess => 'Download avviato.';

  @override
  String get measurementExportError => 'Impossibile esportare le misure.';

  @override
  String measurementHistoryExportPdfTitle(String customerName) {
    return 'Misure — $customerName';
  }

  @override
  String get syncConflictTitle => 'Conflitto di sincronizzazione rilevato';

  @override
  String get syncConflictMessage =>
      'Ci sono modifiche locali e remote in conflitto. Scegli se mantenere la versione locale o accettare quella remota.';

  @override
  String syncConflictMessageWithEntity(String entityType) {
    return 'Conflitto per $entityType. Mantieni le modifiche locali o usa la copia sul server.';
  }

  @override
  String get syncConflictUseRemote => 'Usa remota';

  @override
  String get syncConflictUseLocal => 'Usa locale';

  @override
  String get syncInProgress => 'Sincronizzazione in corso...';

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String syncPending(int count) {
    return 'Sincronizzazione in coda: $count';
  }

  @override
  String syncFailed(int count) {
    return 'Sincronizzazione fallita: $count in coda';
  }

  @override
  String get settingsSyncSectionTitle => 'Sincronizzazione';

  @override
  String settingsSyncSectionSubtitle(int pending, int failed) {
    return '$pending in coda, $failed da rivedere';
  }

  @override
  String get settingsSyncRetryFailed => 'Riprova operazioni fallite';

  @override
  String get syncIssuesScreenTitle => 'Problemi di sincronizzazione';

  @override
  String get syncIssueDetailTitle => 'Dettaglio problema sync';

  @override
  String get syncIssueLocalVersion => 'Versione locale';

  @override
  String get syncIssueRemoteVersion => 'Versione remota';

  @override
  String get syncIssuePathLabel => 'Percorso';

  @override
  String get syncNoIssues => 'Nessun problema di sincronizzazione da risolvere';

  @override
  String get syncRetry => 'Riprova';

  @override
  String get syncIssueDiscard => 'Elimina operazione';

  @override
  String syncRetryStarted(int count) {
    return 'Riprova avviata per $count operazioni';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardWeeklyProgress => 'Progressi settimanali';

  @override
  String get dashboardPlansUpdatedThisWeek =>
      'Piani aggiornati questa settimana';

  @override
  String get dashboardTotalClients => 'Clienti totali';

  @override
  String get dashboardActivePrograms => 'Programmi attivi';

  @override
  String get dashboardCreateProgram => 'Crea programma';

  @override
  String get dashboardTodaySchedule => 'Programma di oggi';

  @override
  String get dashboardSeeAll => 'Vedi tutto';

  @override
  String get dashboardNoScheduleToday =>
      'Nessun elemento in programma per oggi.';

  @override
  String get dashboardNoScheduledWorkoutsYet =>
      'Nessun allenamento pianificato.';

  @override
  String get dashboardUnknownClient => 'Cliente sconosciuto';

  @override
  String get dashboardUntitledWorkout => 'Workout senza titolo';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarEmptyMonth => 'Nessuna sessione in questo giorno.';

  @override
  String get calendarLoadError => 'Impossibile caricare il calendario.';

  @override
  String get calendarUpdateError =>
      'Impossibile aggiornare lo stato della sessione.';

  @override
  String get calendarUpcomingSessions => 'Prossime sessioni';

  @override
  String get sessionCompleted => 'Completata';

  @override
  String get sessionSkipped => 'Saltata';

  @override
  String get sessionPlanned => 'Pianificata';

  @override
  String get sessionMarkPlanned => 'Segna come pianificata';

  @override
  String get sessionDetailOpenBuilder => 'Apri nel builder';

  @override
  String sessionDetailExercisesCount(int count) {
    return '$count esercizi';
  }

  @override
  String get sessionReschedule => 'Riprogramma sessione';

  @override
  String get sessionSkipDate => 'Salta questa data';

  @override
  String get sessionOverrideClear => 'Rimuovi override data';

  @override
  String get dashboardWorkoutBuilder => 'Builder workout';

  @override
  String get dashboardSessionTitle => 'Sessione';

  @override
  String get dashboardDetailHint =>
      'I dettagli si basano sulla data di inizio del piano selezionato.';

  @override
  String get dashboardReminderTooltip => 'Imposta promemoria';

  @override
  String get dashboardSectionToday => 'Oggi';

  @override
  String get dashboardSectionAttention => 'Richiede attenzione';

  @override
  String get dashboardSectionStalePlans => 'Programmi da aggiornare';

  @override
  String get dashboardSectionCustomersNoPlan => 'Clienti senza programma';

  @override
  String get dashboardCoachToolsTitle => 'Strumenti coach';

  @override
  String get dashboardDiaryAction => 'Diario allenamenti';

  @override
  String get dashboardStatsAction => 'Statistiche coach';

  @override
  String dashboardDiarySubtitle(int count) {
    return '$count sessioni (30 gg)';
  }

  @override
  String dashboardStatsSubtitle(int percent) {
    return '$percent% aderenza (7 gg)';
  }

  @override
  String get customerOpenDiary => 'Vedi diario';

  @override
  String get dashboardNoPending =>
      'Al momento non c\'è nulla che richieda attenzione.';

  @override
  String get dashboardBackupHint =>
      'I dati restano su questo dispositivo. Esporta un backup da Impostazioni prima di reinstallare o cambiare dispositivo.';

  @override
  String get dashboardOpenBackupSettings => 'Apri backup';

  @override
  String get dashboardBackupReminderMessage =>
      'Ultimo backup di oltre 7 giorni fa. Esporta o carica una copia recente per sicurezza.';

  @override
  String get dashboardBackupReminderCta => 'Apri backup nelle impostazioni';

  @override
  String get dashboardBackupReminderSnooze => 'Ricordamelo tra 3 giorni';

  @override
  String get dashboardLoadError =>
      'Impossibile caricare la dashboard. Scorri verso il basso per riprovare.';

  @override
  String dashboardNoStalePlans(int days) {
    return 'Tutti i programmi sono stati aggiornati negli ultimi $days giorni.';
  }

  @override
  String get dashboardNoCustomersWithoutPlan =>
      'Ogni cliente ha almeno un programma.';

  @override
  String get dashboardPendingDetailTitle => 'Operazione di sincronizzazione';

  @override
  String dashboardPendingStatusLabel(String status) {
    return 'Stato: $status';
  }

  @override
  String dashboardPendingEntityLabel(String entity) {
    return 'Entità: $entity';
  }

  @override
  String dashboardPendingPathLabel(String path) {
    return 'Percorso: $path';
  }

  @override
  String get dashboardSyncStatusPending => 'In coda';

  @override
  String get dashboardSyncStatusSyncing => 'Sincronizzazione in corso';

  @override
  String get dashboardSyncStatusFailed => 'Fallita';

  @override
  String get dashboardSyncStatusConflict => 'Conflitto';

  @override
  String get dashboardSyncStatusCompleted => 'Completata';

  @override
  String get dashboardSyncStatusDeadLetter => 'Non sincronizzabile';

  @override
  String get dashboardSyncStatusBlockedAuth => 'Accesso richiesto';

  @override
  String get dashboardSemanticTodayList => 'Programmi che iniziano oggi';

  @override
  String get dashboardSemanticAttentionList =>
      'Coda di sincronizzazione ed errori';

  @override
  String get dashboardSemanticNoPlanList => 'Clienti senza programma';

  @override
  String get dashboardSemanticStaleList => 'Programmi da aggiornare';

  @override
  String get customerEditProfile => 'Modifica profilo';

  @override
  String get customerAssignWorkout => 'Assegna workout';

  @override
  String get customerGoalLabel => 'Obiettivo';

  @override
  String get customerCurrentWeight => 'Peso attuale';

  @override
  String get customerMuscleMass => 'Massa muscolare';

  @override
  String get customerOverviewNoMeasurements =>
      'Nessuna misura ancora. Aggiungine una per seguire i progressi.';

  @override
  String customerOverviewLastMeasurement(String date) {
    return 'Ultima misura: $date';
  }

  @override
  String get customerOverviewViewHistory => 'Vedi storico misure';

  @override
  String get customerOverviewFromProfile => 'Dal profilo';

  @override
  String get customerOverviewProfileWeightHint =>
      'Peso dal profilo. Aggiungi una misura per seguire l\'andamento nel tempo.';

  @override
  String get customerOverviewNoSecondaryData => 'Nessun dato';

  @override
  String get customerWorkoutPlans => 'Piani di allenamento';

  @override
  String get customerViewAll => 'Vedi tutti';

  @override
  String get customerNoWorkoutPlansYet => 'Nessun piano di allenamento';

  @override
  String get customerUnnamedPlan => 'Piano senza nome';

  @override
  String get workoutsTitle => 'Workout';

  @override
  String get workoutsNoWorkoutsYet => 'Nessun workout';

  @override
  String get workoutsAssignHint =>
      'Assegna un workout a questo cliente dalla schermata dettaglio cliente.';

  @override
  String get customerWorkoutsSearchHint => 'Cerca per nome, fase o tag';

  @override
  String get customerWorkoutsFilterAll => 'Tutti';

  @override
  String get customerWorkoutsFilterActive => 'In corso';

  @override
  String get customerWorkoutsFilterScheduled => 'Con date';

  @override
  String get customerWorkoutsFilterUnscheduled => 'Senza data';

  @override
  String get customerWorkoutsFilterEnded => 'Terminati';

  @override
  String get customerWorkoutsFilterArchived => 'Archiviati';

  @override
  String get customerWorkoutsFilterStale => 'Da aggiornare';

  @override
  String get customerWorkoutsSortTitle => 'Ordina per';

  @override
  String get customerWorkoutsSortStartDateDesc => 'Data inizio (recente)';

  @override
  String get customerWorkoutsSortStartDateAsc => 'Data inizio (meno recente)';

  @override
  String get customerWorkoutsSortUpdatedDesc => 'Ultima modifica (recente)';

  @override
  String get customerWorkoutsSortUpdatedAsc => 'Ultima modifica (meno recente)';

  @override
  String get customerWorkoutsSortNameAsc => 'Nome (A-Z)';

  @override
  String get customerWorkoutsSortNameDesc => 'Nome (Z-A)';

  @override
  String get customerWorkoutsNoMatch =>
      'Nessun piano corrisponde ai filtri selezionati.';

  @override
  String get workoutLibraryTitle => 'Libreria';

  @override
  String get workoutTemplatesTitle => 'Template allenamento';

  @override
  String get workoutTemplatesEmpty =>
      'Nessun template. Salva un piano cliente come template o creane uno qui.';

  @override
  String get workoutTemplatesNew => 'Nuovo template';

  @override
  String get workoutTemplatesAssign => 'Assegna a cliente';

  @override
  String get workoutTemplatesDuplicate => 'Duplica template';

  @override
  String get workoutTemplatesEdit => 'Modifica';

  @override
  String get workoutTemplatesDelete => 'Elimina';

  @override
  String get workoutTemplatesAssignTitle => 'Scegli un cliente';

  @override
  String get workoutTemplatesSaveAsTemplate => 'Salva come template';

  @override
  String get workoutTemplatesSaveAsTemplateTitle => 'Nome template';

  @override
  String get workoutTemplatesNameHint => 'Nome';

  @override
  String get workoutTemplatesDuplicateTitle => 'Duplica template';

  @override
  String get workoutTemplatesDuplicateHint => 'Nome della copia';

  @override
  String get workoutTemplatesAssignedSnack => 'Piano aggiunto al cliente.';

  @override
  String get workoutTemplatesDuplicateSnack => 'Template creato.';

  @override
  String get workoutTemplatesDeleteConfirmTitle => 'Eliminare il template?';

  @override
  String get workoutTemplatesDeleteConfirmMessage =>
      'Il template verrà rimosso da questo dispositivo.';

  @override
  String get workoutTemplatesDrawerLabel => 'Template allenamento';

  @override
  String get workoutTemplatesCustomersLoadError =>
      'Impossibile caricare l\'elenco clienti. Riprova.';

  @override
  String get workoutTemplatesSemanticList => 'Elenco template allenamento';

  @override
  String get workoutTemplatesAssignSearchHint => 'Cerca per nome…';

  @override
  String get workoutTemplatesAssignNoMatch =>
      'Nessun cliente corrisponde alla ricerca.';

  @override
  String get workoutTemplatesSearchHint => 'Cerca per nome, fase o tag';

  @override
  String get workoutTemplatesSortTitle => 'Ordina template';

  @override
  String get workoutTemplatesSortNameAsc => 'Nome (A-Z)';

  @override
  String get workoutTemplatesSortUpdatedDesc => 'Ultima modifica';

  @override
  String get workoutTemplatesSortWeekCountDesc => 'Più settimane';

  @override
  String get workoutTemplatesNoMatch =>
      'Nessun template corrisponde alla ricerca.';

  @override
  String get workoutTemplatesPreviewTitle => 'Anteprima template';

  @override
  String get workoutTemplatesPreviewEmpty =>
      'Nessuna struttura disponibile per questo template.';

  @override
  String workoutTemplatesStructureSummary(int weeks, int days, int exercises) {
    return '$weeks sett. · $days giorni · $exercises esercizi';
  }

  @override
  String workoutTemplatesPreviewExercisesMore(int count) {
    return '+$count altri esercizi';
  }

  @override
  String get workoutTemplatesAssignStartDate => 'Data di inizio opzionale';

  @override
  String get workoutTemplatesAssignStartDateHint =>
      'Tocca per scegliere una data di inizio';

  @override
  String get workoutTemplatesAssignStartDateSkip => 'Salta';

  @override
  String get workoutDiaryTitle => 'Diario allenamenti';

  @override
  String get workoutStatsTitle => 'Statistiche';

  @override
  String get placeholderComingSoon => 'In arrivo';

  @override
  String get placeholderSectionNotImplemented =>
      'Questa sezione non è ancora implementata.';

  @override
  String get placeholderBackToBuilder => 'Torna al builder';

  @override
  String get customerDetailTitle => 'Dettaglio cliente';

  @override
  String get actionsTitle => 'Azioni';

  @override
  String updatedDaysAgo(int count) {
    return 'Aggiornato ${count}g fa';
  }

  @override
  String updatedHoursAgo(int count) {
    return 'Aggiornato ${count}h fa';
  }

  @override
  String updatedMinutesAgo(int count) {
    return 'Aggiornato ${count}m fa';
  }

  @override
  String get updatedJustNow => 'Appena adesso';

  @override
  String get exerciseLibraryTabHevy => 'Hevy';

  @override
  String get exerciseLibraryImportSourceHevy =>
      'Sincronizza catalogo Hevy completo';

  @override
  String get exerciseLibraryImportSourceHevySubtitle =>
      'Importa tutti gli esercizi dal tuo account Hevy Pro con ID già mappati.';

  @override
  String get hevySettingsSectionTitle => 'Integrazione Hevy';

  @override
  String get hevySettingsSectionSubtitle =>
      'Richiede Hevy Pro. API key da hevy.com/settings (Developer).';

  @override
  String get hevySettingsApiKeyLabel => 'API key Hevy';

  @override
  String get hevySettingsApiKeyHint => 'Incolla la tua API key';

  @override
  String get hevySettingsSaveKey => 'Salva key';

  @override
  String get hevySettingsTestConnection => 'Test connessione';

  @override
  String get hevySettingsSyncCatalog => 'Sincronizza tutti gli esercizi';

  @override
  String get hevySettingsKeySaved => 'API key Hevy salvata.';

  @override
  String get hevySettingsTestSuccess => 'Connesso a Hevy.';

  @override
  String hevySettingsTestFailed(String message) {
    return 'Connessione Hevy fallita: $message';
  }

  @override
  String get hevyImportInProgress => 'Sincronizzazione catalogo Hevy…';

  @override
  String hevyImportSuccessCount(int count) {
    return 'Sincronizzazione Hevy completata: $count nuovi elementi.';
  }

  @override
  String hevyImportFailed(String message) {
    return 'Sincronizzazione Hevy fallita: $message';
  }

  @override
  String get workoutExportHevy => 'Esporta giornata su Hevy';

  @override
  String get hevyExportSheetTitle => 'Esporta su Hevy';

  @override
  String get hevyExportConfirm => 'Crea routine su Hevy';

  @override
  String get hevyExportConfirmRoutine => 'Crea routine su Hevy';

  @override
  String get hevyExportConfirmWorkout => 'Crea allenamento su Hevy';

  @override
  String get hevyExportWorkoutHint =>
      'L\'allenamento viene registrato nel diario Hevy con inizio adesso e fine stimata tra 90 minuti.';

  @override
  String get hevyExportSuccessRoutine => 'Routine creata su Hevy.';

  @override
  String get hevyExportSuccessWorkout => 'Allenamento creato su Hevy.';

  @override
  String get hevyExportAllMapped =>
      'Tutti gli esercizi sono mappati. Pronto per l\'export.';

  @override
  String hevyExportUnmappedIntro(int count) {
    return '$count esercizi richiedono una mappatura Hevy prima dell\'export.';
  }

  @override
  String get hevyExportMapExercise => 'Mappa';

  @override
  String get hevyExportUnmappedBlock =>
      'Mappa tutti gli esercizi prima di esportare.';

  @override
  String get hevyExportSuccess => 'Routine creata su Hevy.';

  @override
  String get hevyExportError => 'Export Hevy fallito. Riprova.';

  @override
  String get hevyExportNoCatalogHint =>
      'Sincronizza prima il catalogo Hevy da Impostazioni o Libreria esercizi.';

  @override
  String get calendarExportHevy => 'Esporta su Hevy';

  @override
  String get workoutDiaryEmpty =>
      'Nessuna sessione registrata. Segna una sessione come completata dal calendario per iniziare il diario.';

  @override
  String get workoutDiaryFilterAll => 'Tutti i clienti';

  @override
  String get coachStatsTitle => 'Statistiche coach';

  @override
  String get coachStatsAdherence => 'Aderenza';

  @override
  String get coachStatsCompletedSessions => 'Sessioni completate';

  @override
  String get coachStatsSkippedSessions => 'Sessioni saltate';

  @override
  String get coachStatsActiveClients => 'Clienti attivi';

  @override
  String get coachStatsPeriod7d => 'Ultimi 7 giorni';

  @override
  String get coachStatsPeriod30d => 'Ultimi 30 giorni';

  @override
  String get coachStatsChartTitle => 'Sessioni completate per giorno';

  @override
  String get coachStatsChartEmpty =>
      'Nessuna sessione completata in questo periodo.';

  @override
  String coachStatsChartDaySummary(String date, int count) {
    return '$date: $count completate';
  }

  @override
  String get coachStatsExportCsv => 'Esporta CSV';

  @override
  String get coachStatsExportCsvSubject => 'Statistiche PowerCoach';

  @override
  String get workoutDiaryFilterDate => 'Intervallo date';

  @override
  String get workoutDiaryFilterDateAll => 'Sempre';

  @override
  String get workoutDiaryFilterStatusAll => 'Tutti gli stati';

  @override
  String get workoutDiaryDetailTitle => 'Dettaglio sessione';

  @override
  String get workoutDiaryEntryNotFound =>
      'Sessione non trovata o non più disponibile.';

  @override
  String get workoutDiaryOpenPlan => 'Apri piano workout';

  @override
  String get workoutDiaryOpenSession => 'Apri in calendario';

  @override
  String get workoutDiaryNoExercisesLogged =>
      'Nessun esercizio registrato per questa sessione.';

  @override
  String get sessionLogTitle => 'Registra sessione';

  @override
  String get sessionLogNotesHint => 'Note sessione (opzionale)';

  @override
  String get sessionLogSave => 'Salva sessione';

  @override
  String get sessionLogExercisesLabel => 'Esercizi eseguiti';

  @override
  String get sessionLogSetReps => 'Reps';

  @override
  String get sessionLogSetLoad => 'Carico';

  @override
  String get sessionLogAddSet => 'Aggiungi set';

  @override
  String sessionLogSetLabel(int number) {
    return 'Set $number';
  }

  @override
  String get sessionLogExpandSets => 'Mostra set';

  @override
  String get sessionLogCollapseSets => 'Nascondi set';

  @override
  String get sessionLogCheckInTitle => 'Com\'è andata? (opzionale)';

  @override
  String get sessionLogRpeLabel => 'RPE sessione (1-10)';

  @override
  String get sessionLogPainLabel => 'Livello di dolore (0-10)';

  @override
  String get sessionLogPainLocationHint => 'Dove? (opzionale)';

  @override
  String sessionLogRpeChipLabel(int value) {
    return 'RPE $value/10';
  }

  @override
  String sessionLogPainChipLabel(int value) {
    return 'Dolore $value/10';
  }

  @override
  String sessionLogPainChipLabelWithLocation(int value, String location) {
    return 'Dolore $value/10 · $location';
  }

  @override
  String get customerProgressTitle => 'Progresso allenamento';

  @override
  String get customerProgressAdherence => 'Aderenza (30 giorni)';

  @override
  String get customerProgressLastSession => 'Ultima sessione';

  @override
  String get customerProgressRecentPrs => 'PR recenti';

  @override
  String get customerProgressNoData =>
      'Nessun dato di allenamento. Assegna un piano e registra le sessioni per vedere il progresso.';

  @override
  String get customerProgressNoSession => 'Nessuna sessione registrata';

  @override
  String customerProgressDaysAgo(int count) {
    return '$count giorni fa';
  }

  @override
  String get customerProgressToday => 'Oggi';

  @override
  String get customerProgressYesterday => 'Ieri';

  @override
  String get customerProgressLast4Weeks => 'Ultime 4 settimane';

  @override
  String get customerProgressThisWeek => 'Questa sett.';

  @override
  String customerProgressWeeksAgo(int count) {
    return '$count sett. fa';
  }

  @override
  String get customerProgressExport => 'Esporta progresso';

  @override
  String get customerProgressExportSuccess => 'Progresso esportato';

  @override
  String get customerProgressExportFailed =>
      'Esportazione progresso non riuscita';

  @override
  String get settingsCalendarRemindersTitle => 'Promemoria sessioni';

  @override
  String get settingsCalendarRemindersSubtitle =>
      'Notifica prima delle sessioni pianificate';

  @override
  String get settingsCalendarReminderLead => 'Avvisami';

  @override
  String settingsCalendarReminderLeadHours(int hours) {
    return '$hours ore prima';
  }

  @override
  String get workoutFollowUpFromExecution =>
      'Usa i carichi dell\'ultima esecuzione';

  @override
  String workoutFollowUpFromExecutionHint(int count) {
    return 'Basato su $count sessioni registrate';
  }

  @override
  String get workoutFollowUpNoExecutionData =>
      'Nessun dato di esecuzione — verrà copiata solo la struttura.';

  @override
  String get localDataQueueTitle => 'Coda dati locale';

  @override
  String get localDataQueueSubtitle => 'Operazioni locali in sospeso';

  @override
  String get backupImportPreviewTitle => 'Importa backup';

  @override
  String get backupImportReplaceAll => 'Sostituisci tutti i dati locali';

  @override
  String get backupImportMerge => 'Unisci per id (mantieni il più recente)';

  @override
  String get backupImportConfirm => 'Importa';

  @override
  String backupImportCounts(int customers, int plans, int executions) {
    return '$customers clienti · $plans piani · $executions log sessioni';
  }

  @override
  String backupImportMetadata(String date, String version) {
    return 'Backup del $date · app $version';
  }

  @override
  String get backupImportSelectGroups => 'Scegli cosa importare';

  @override
  String get backupImportPartialReplaceHint =>
      'I gruppi deselezionati restano invariati su questo dispositivo.';

  @override
  String backupImportGroupCustomers(int count) {
    return 'Clienti e dati correlati ($count)';
  }

  @override
  String backupImportGroupPlans(int count) {
    return 'Piani workout ($count)';
  }

  @override
  String backupImportGroupExerciseLibrary(int count) {
    return 'Libreria esercizi ($count)';
  }

  @override
  String backupImportGroupReminders(int count) {
    return 'Promemoria ($count)';
  }

  @override
  String get backupImportGroupPreferences => 'Profilo e preferenze';

  @override
  String get backupImportTypeConfirm =>
      'Digita IMPORT per confermare la sostituzione di tutti i dati';

  @override
  String get backupImportTypeConfirmHint => 'IMPORT';

  @override
  String get releaseNotesTitle => 'Novità';

  @override
  String releaseNotesInstalledVersion(String version) {
    return 'Versione installata: $version';
  }

  @override
  String releaseNotesSettingsSubtitle(String version) {
    return 'Versione $version';
  }

  @override
  String get releaseNotesHighlightsLabel => 'In evidenza';

  @override
  String get releaseNotesCurrentVersionBadge => 'Corrente';

  @override
  String get releaseNotesV1071 =>
      'Hub coach: card Diario e Statistiche dalla dashboard; menu su agenda completa';

  @override
  String get releaseNotesV1072 =>
      'Da scheda cliente: apri diario filtrato per cliente';

  @override
  String get releaseNotesV1073 =>
      'Export CSV riepilogo progresso (aderenza, PR, misure) da overview cliente';

  @override
  String get releaseNotesV1074 =>
      'Pannello superset dedicato nel workout builder (anteprima compatta + editor)';

  @override
  String get releaseNotesV1075 =>
      'Session log arricchito: reps e carico per serie nel foglio sessione';

  @override
  String get releaseNotesV1061 =>
      'Backup: restore selettivo per categorie + metadata export (data export, conteggi entità)';

  @override
  String get releaseNotesV1062 =>
      'Diario workout v2: filtri data/stato, dettaglio sessione navigabile';

  @override
  String get releaseNotesV1063 =>
      'Statistiche coach: grafico aderenza giornaliera + export CSV KPI';

  @override
  String get releaseNotesV1064 =>
      'Miglioramenti presentation-split builder (sheet esercizi, tab training)';

  @override
  String get releaseNotesV1051 =>
      'Modello esecuzione sessione (completata / saltata / pianificata) persistito in locale';

  @override
  String get releaseNotesV1052 => 'Diario workout e statistiche coach (MVP)';

  @override
  String get releaseNotesV1053 =>
      'Pannello progresso cliente: aderenza 30 giorni, PR recenti, strip 4 settimane';

  @override
  String get releaseNotesV1054 =>
      'Promemoria sessioni collegati al calendario piani';

  @override
  String get releaseNotesV1055 =>
      'Follow-up cliente basato su dati di esecuzione reali';

  @override
  String get releaseNotesV1041 =>
      'Overview cliente con metriche reali da misure (sparkline, trend 30 gg)';

  @override
  String get releaseNotesV1042 =>
      'Picker esercizi: recenti e preferiti in libreria';

  @override
  String get releaseNotesV1043 =>
      'Dettaglio sessione calendario con dati piano reali';

  @override
  String get releaseNotesV1044 =>
      'Override per singola occorrenza sessione (ripianifica senza mutare il piano)';

  @override
  String get releaseNotesV1045 =>
      'Ciclo di vita piano (bozza, attivo, completato, archiviato)';

  @override
  String get releaseNotesV1031 =>
      'Dati business solo locali (Drift); Supabase solo autenticazione';

  @override
  String get releaseNotesV1032 =>
      'Rimozione UX sync cloud obsoleta; test backfill tier 2/3';

  @override
  String get releaseNotesV1033 => 'Repository prefs e profilo coach locali';

  @override
  String get releaseNotesV1034 => 'Migrazione offline store modulare';

  @override
  String get releaseNotesV1021 => 'Libreria template piani workout';

  @override
  String get releaseNotesV1022 =>
      'Autosave editor piano + guard uscita con modifiche non salvate';

  @override
  String get releaseNotesV1023 => 'Export piano PDF / JSON / Excel';

  @override
  String get releaseNotesV1024 =>
      'Integrazione Hevy (export verso calendario / libreria)';

  @override
  String get releaseNotesV1011 => 'Dashboard \"Oggi\" e agenda sessioni';

  @override
  String get releaseNotesV1012 => 'Gestione clienti, misure, record esercizi';

  @override
  String get releaseNotesV1013 =>
      'Workout builder (settimane/giorni/esercizi, superset base)';

  @override
  String get releaseNotesV1014 => 'Calendario coach e assegnazione piani';

  @override
  String get releaseNotesV1015 => 'Notifiche locali e promemoria';

  @override
  String get releaseNotesV1016 => 'Localizzazione IT/EN end-to-end';

  @override
  String get releaseNotesV1017 => 'Backup export/import JSON account';
}
