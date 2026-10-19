# Oclic Assistance 0.1.0

RustDesk 1.5.0 with a Windows receive-only Oclic interface.
Built from fada664df7a294d1d1a9ca3e7cd3637069122f17.
Server: remote.oclic.online. Only its public key is compiled into this client.
Click confirmation is required for every connection. No unattended password,
installation, file transfer, clipboard, terminal, camera, tunnel or recording.
The application uses an OclicAssistance configuration namespace, separate from RustDesk.
Closing the Oclic window shuts down the native engine and all its sessions.

Modified runtime paths: src/lib.rs/core_main.rs load the Windows Oclic configuration;
src/oclic.rs defines server settings and native shutdown; flutter_ffi.rs exposes shutdown;
desktop_tab_page.dart and server_page.dart render the Oclic views while retaining
the native connection-manager models; consts.dart sets the connection-window size;
pubspec.yaml and Windows resources load the supplied branding assets.
ui_cm_interface.rs enforces a single native screen-control connection;
Oclic approval and stop controls stay visible even in a short window.
server_model.dart skips automatic minimization for Oclic; the connection window's
system close control requests native shutdown while a peer is present.
Other source changes are limited to the build workflow and licence/font notices.

Source and upstream licence: https://github.com/Jun-cod/oclic-assistance/tree/oclic-v1
This source-built executable is unsigned. No RustDesk vendor signature is claimed.
