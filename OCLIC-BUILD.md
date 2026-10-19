# Oclic Assistance 0.1.2

RustDesk 1.5.0 with a Windows receive-only Oclic interface.
Built from fada664df7a294d1d1a9ca3e7cd3637069122f17.
Server: remote.oclic.online. Only its public key is compiled into this client.
Click confirmation is required for every connection. No unattended password,
installation, clipboard, terminal, camera, tunnel or recording.
File transfer is available after a visible client approval. One screen-control
connection and one file-transfer connection may coexist only for the same peer.
The application uses an OclicAssistance configuration namespace, separate from RustDesk.
Closing the Oclic window shuts down the native engine and all its sessions.

Modified runtime paths: src/lib.rs/core_main.rs load the Windows Oclic configuration;
src/oclic.rs defines server settings and native shutdown; flutter_ffi.rs exposes shutdown;
desktop_tab_page.dart and server_page.dart render the Oclic views while retaining
the native connection-manager models; consts.dart sets the connection-window size;
pubspec.yaml and Windows resources load the supplied branding assets.
ui_cm_interface.rs allows one screen-control channel plus one file-transfer channel
from the same peer, and refuses additional peers or duplicate channels;
Oclic approval and stop controls stay visible even in a short window.
main.dart and server_model.dart leave Oclic connection windows out of the topmost layer.
The Oclic interface minimizes each window once after native stream confirmation,
keeps manual minimize controls available and restores a new incoming request.
Session state is confirmed by native peer records and the active stream count,
not the cached Dart authorization flag. The connection window's system close
control requests native shutdown while a peer is present.
Other source changes are limited to the build workflow and licence/font notices.

This file-transfer change requires the complete Windows build. The interface-only
workflow correctly rejects reuse of the previous engine, which disabled files.
The new engine, configuration policy and Flutter approval state are tested in CI.

Source and upstream licence: https://github.com/Jun-cod/oclic-assistance/tree/oclic-v1
This source-built executable is unsigned. No RustDesk vendor signature is claimed.
