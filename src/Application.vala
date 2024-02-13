/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
 using Gtk;
 using Gdk;
 using GLib;
 using Larawan.Views;
 
 public class Larawan.Application : Gtk.Application {
  public Application () {
    Object (
        application_id: "io.github.xchan14.larawan",
        flags: ApplicationFlags.FLAGS_NONE
    );
  }

  protected override void activate () {
    // Call the parent class's activate method
    base.activate();

    Granite.init();

    // Create a new window
    stdout.printf("Starting Larawan...");
    var main_window = new MainWindow(this);

    var style_context = main_window.get_style_context();
    var css_provider = new CssProvider();
    css_provider.load_from_resource("io/github/xchan14/larawan/application.css");

    StyleContext.add_provider_for_display(
            Display.get_default(),
            css_provider, 
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    main_window.present ();
  }

  public static int main (string[] args) {
    var app = new Larawan.Application ();

    return app.run (args);
  }
    
}