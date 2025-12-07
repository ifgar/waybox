/// Represents a single menu entry in Waybox.
///
/// Each menu item consists of:
/// - a visible `name` displayed in the UI,
/// - an optional `command` that is executed when the user clicks the item.
///
/// The command is executed through `bash -c`, allowing users to run any
/// shell command or script from the menu.
///
/// Example XML:
/// ```xml
/// <menu name="Open Terminal" command="alacritty" />
/// <menu name="Shutdown" command="systemctl poweroff" />
/// ```
class Menu {
  /// Visible label shown to the user.
  final String name;

  /// Shell command executed on click.
  ///
  /// This value can be `null` if the item is decorative or intentionally inert.
  final String? command;

  const Menu({required this.name, this.command});
}
