use hbb_common::{config, log};

pub fn configure() {
    *config::APP_NAME.write().unwrap() = "OclicAssistance".to_owned();
    let mut hard = config::HARD_SETTINGS.write().unwrap();
    for (key, value) in [
        ("conn-type", "incoming"),
        ("disable-settings", "Y"),
        ("disable-installation", "Y"),
        ("disable-account", "Y"),
        ("disable-ab", "Y"),
    ] {
        hard.insert(key.to_owned(), value.to_owned());
    }
    drop(hard);
    let mut settings = config::OVERWRITE_SETTINGS.write().unwrap();
    for (key, value) in [
        ("custom-rendezvous-server", "remote.oclic.online"),
        ("relay-server", "remote.oclic.online:21117"),
        ("key", "Du5PFn3DvUJMyvoVi3aIoxdhAraBM70bpjf5eg7niDQ="),
        ("api-server", ""),
        ("approve-mode", "click"),
        ("enable-keyboard", "Y"),
        ("enable-clipboard", "N"),
        ("enable-file-transfer", "Y"),
        ("enable-file-copy-paste", "N"),
        ("enable-audio", "N"),
        ("enable-camera", "N"),
        ("enable-terminal", "N"),
        ("enable-tunnel", "N"),
        ("enable-record-session", "N"),
        ("enable-privacy-mode", "N"),
        ("enable-block-input", "N"),
        ("direct-server", "N"),
        ("allow-remote-config-modification", "N"),
    ] {
        settings.insert(key.to_owned(), value.to_owned());
    }
    drop(settings);
    let mut local = config::OVERWRITE_LOCAL_SETTINGS.write().unwrap();
    local.insert("lang".to_owned(), "fr".to_owned());
    local.insert("dark-theme".to_owned(), "N".to_owned());
    local.insert("allow-remote-cm-modification".to_owned(), "N".to_owned());
    drop(local);
    if std::env::args().len() == 1 {
        config::Config::set_option("stop-service".to_owned(), "".to_owned());
    }
}

pub fn shutdown() -> bool {
    match crate::ipc::set_data(&crate::ipc::Data::Close) {
        Ok(()) => true,
        Err(error) => {
            log::error!("Oclic could not send shutdown: {}", error);
            false
        }
    }
}

pub fn can_pair_channels(peer_id: &str, file_transfer: bool, other_peer_id: &str, other_file_transfer: bool) -> bool {
    peer_id == other_peer_id && file_transfer != other_file_transfer
}

#[cfg(test)]
mod tests {
    #[test]
    fn oclic_server_and_approval_are_built_in() {
        super::configure();
        assert_eq!(hbb_common::config::Config::get_option("custom-rendezvous-server"), "remote.oclic.online");
        assert_eq!(hbb_common::config::Config::get_option("approve-mode"), "click");
        assert!(hbb_common::config::is_incoming_only());
        assert!(hbb_common::config::is_disable_installation());
        assert_eq!(hbb_common::config::Config::get_option("enable-file-transfer"), "Y");
        for key in ["enable-clipboard", "enable-terminal", "enable-tunnel", "enable-privacy-mode", "enable-block-input"] {
            assert_eq!(hbb_common::config::Config::get_option(key), "N");
        }
    }

    #[test]
    fn file_transfer_can_accompany_only_the_same_technician() {
        assert!(super::can_pair_channels("technician", true, "technician", false));
        assert!(super::can_pair_channels("technician", false, "technician", true));
        assert!(!super::can_pair_channels("other", true, "technician", false));
        assert!(!super::can_pair_channels("technician", false, "technician", false));
        assert!(!super::can_pair_channels("technician", true, "technician", true));
    }
}
